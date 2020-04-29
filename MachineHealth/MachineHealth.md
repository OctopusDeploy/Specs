# Machine Health
## Problem
Customers have asked us for some quality of life improvements with machine health. They mostly relate to auto-deploy and how we surface the health of a machine. The three main scenarios are:
 
 1. Customers with fleets of occasionally connected polling Tentacles do not want the overhead of a health check in order to trigger an auto-deploy. Health checks can take a long time and do not actually add value for them. They want auto-deploy to trigger shortly after a Tentacle connects regardless of it's health.
 1. The transitions between states (mainly to and from `with Warnings`) causes auto-deploy to unnecessarily (and sometimes suprising) trigger. It's very common to have all machine run auto-deploy after server upgrade due to out of date Calamari. Although rarer, it would be strange for a machine to auto-deploy when a machine no longer has low disk space. The customer expects that auto-deploy would not trigger for transitioning between `healthy` states if they have both configured.
 1. Performance is negatively impacted for customers who have a large number of machines. Health checks invalidate both the internal cache and the "etag" on the API causing lots of data to be loaded.

 ## Proposed Investment
 **Small Batch** - 2 people 2 weeks
 
 The "occasionally connected" scenario is the **must have** for this pitch. This `Health Status` and `Change health via API` changes should accomplish this.

 The rest of the items are presented in priority order.

## Health Overview
The health information of a machine is currently changed via
- Health Check task
- Health Check step in a deployment/runbook 
- Being uncontactable during a deployment (and the option to exclude is enabled)

There are two types of health checks
1. Connectivity only, that runs an empty script
1. Full check, that runs a script that:
    - Collects the required information (versions, shell, os, etc) and returns it via output variables (notably service messages are not used)
    - Whether there is enough disk space
    - The user provided script configured on the `MachinePolicy`

If a health check task or step completes for a machine, it records a range of information (The connectivity only check only records the `HealthStatus`):
- On Machine.[MachineHealth](https://github.com/OctopusDeploy/OctopusDeploy/blob/80da6cae6ddeb139613a270b834e70f2e442013d/source/Octopus.Core/Model/Machines/MachineHealth.cs#L29)
    - `HealthStatus` (aka [`MachineStatus`](https://github.com/OctopusDeploy/OctopusDeploy/blob/a1252cd06d6ff22773b63f2b30a26749c3031afb/source/Octopus.Core/Model/Machines/MachineStatus.cs#L8))
    - Tentacle Version
    - Whether a Tentacle upgrade is required
    - Whether it has the latest Calamari
    - When it was last checked
    - The certificate signature algorithm
    - How long it has been unavailable
- On `Machine` itself
    - Operating System
    - Shell Name
    - Shell Version
- On the machine state change event
    - The [details](https://github.com/OctopusDeploy/OctopusDeploy/blob/e5f36b43537d4bce59ffc43285512d2a849b2102/source/Octopus.Server/Orchestration/ServerTasks/HealthCheck/HealthResultRecorder.cs#L100), generally warnings and errors that occured

## Health Status
### Overview
The health status of a machine is one of `Healthy`, `Healthy with Warnings`, `Unhealthy`, `Unavailable`. The state can transition straight from one state to another. The state is determined by the outcome of the last health interaction as outlined above.

The `Healthy` state is set when a health check completes without any warnings, errors, exceptions and return code of 0. 

It may also be marked as `Healthy` if it is set to auto-upgrade Calamari and does so successfully. This is likely a bug as it ignores other warnings that may have occured.

The `Healthy with Warnings` state is set when a health check completes with warnings and return code of 0 and without exceptions. Warnings are raised for:
- The `Calamari` version being older than that shipped with server
- Low disk space
- A warning from a user defined script

The `Unavailable` state is set if the health check or deployment step fails with an exception that indicates a network error (e.g. failure on SSH connect, `HalibutException`). In the code this is described as a `Transient` exception. The code also uses the term `Offline` for this state.

The `Unhealthy` state is set if the health check or deployment step fails with an exception that is not classed as `Unavailable`.

### Proposed change
When a machine transitions from `Healthy` to `Unavailable`, the customer expects it to transition back to `Healthy` once any kind of communication was established. The assumption is that a network error does not change the healthyness of a machine.

The concepts of connectivity and healthyness should be seperated. A new property `Connectivity` with values `Available` and `Unavailable` should be added, and the `HealthStatus.Unavailable` state removed.

Anytime a connection is established (outgoing or incomming), the `Connectivity` flag should be updated. A callback on successful connection should be added to `Halibut` to make this happen. Performance should be considered as it is not unusual for 1000's of tentacles to open polling connections at once (e.g. server starts up). The solution should not make 1000's of calls to the database, particularly if nothing has changed.

A event will need to be recorded whenever the `Connectivity` flag changes so that customers can setup auto-deploy to that machine.

## Change health via API
Currently the health of a machine cannot be directly changes. An API should be added to allow changing the health so that customers can integrate it with external system. For example AWS health monitoring.

We should also consider allowing the connectivity status to be change. This would allow customers to kick off auto-deploys on external stimulus, particularly for listening tentacles.

## Remove Warning for Calamari
If the Calamari version is out of date, the machine is marked as `Healthy with Warnings`. This is a regular occurance after a server upgrade. Anecdotally this is rarely manually actioned by the customer. Those who care about it have set Calamari to auto-upgrade. Out of date Calamari is automatically resolved the next time a step runs on the target. The addition of Calamari flavours also reduces it's importance.

The warning should be removed, but the check and auto-upgrade functionality kept.

## Change Health Warnings
In almost all cases, the server treats `Healthy` and `Healthy with Warnings` the same.

The `Healthy with Warnings` state should be removed and replaced with a seperate flag, or metadata if implemented (see below).

## Metadata for machines
It would also be good to have an easily accessable set of errors, warnings and messages on a machine. Customer could add to these messages during health check, a deployment or via the API. This would allow then to track extra metadata (e.g. actual free disk space).

 A list of `Metadata` should be added to the machine. A `Metadata` would be:
 - `ID` - ID of the message, unique. It identifies the metadata and used to lookup, remove or replace the metadata. e.g. `FreeDiskSpace`, `HasLatestCalamari`


## Rework Health Events
We will likely need to keep the existing machine health events so we don't break customers. To take full advantage of the changes to `Unavailable` and `Warnings` outline above, the customer would need differentiate between them for auto-deploy.

We should investigate and implement how we can improve auto-deploy in light of these changes.

## Separate Machine and Health
The `Machine` configuration and it's health state have significantly different update frequencies. This causes the `Machine` API to be invalidated much more than it needs to be. It also affects internal caching since the machine health is often not required. It also complicates the code as health changes are not recorded in the audit log (other than state transitions).

The `Machine` configuration and health should be seperated into different documents and tables. APIs should be added to reflact this.

## OS/Shell/ShellVersion
The `OS`, `Shell` and `ShellVersion` are in a `OperatingSystemDetails` [property](https://github.com/OctopusDeploy/OctopusDeploy/blob/7424b74f437244f123157aa201242b1b5ddf7f93/source/Octopus.Server/Orchestration/ServerTasks/HealthCheck/MachineHealthResult.cs#L23) on `Machine`. They are [updated](https://github.com/OctopusDeploy/OctopusDeploy/blob/e5f36b43537d4bce59ffc43285512d2a849b2102/source/Octopus.Server/Orchestration/ServerTasks/HealthCheck/HealthResultRecorder.cs#L155) on every health check, but would rarely change.

We should consider whether they go with `Health` or stay on the machine.
