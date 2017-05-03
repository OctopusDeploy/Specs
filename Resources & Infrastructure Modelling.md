---
status: half-baked
---

The goal of this proposal is to fix some fundamental design flaws in how Octopus models deployment targets. Specifically, I want a model that:

 - Works just as well for deployments to PaaS and serverless architectures, as it does for IaaS
 - Works just as well for targets that are ephemeral as for those that are long-lived
 - Works equally well for targets that are long-lived, for those that are ephemerally managed by the cloud (e.g., auto-scale up/down) and for those that are provisioned/de-provisioned during deployment from Octopus (e.g., blue-green deployment)

## Problem

Right now, the way we model environments and machines has advantages and disadvantages. When an Octopus server is used by a single team, and they deploy primarily to VM's, everything is peachy. For larger setups, or setups that are much more PaaS focussed, they fall down. 

**Messy environments**. When many teams use an Octopus server, environments get messy. Some teams either use a handful of environments and fill them with many machines, using roles to separate them between projects (e.g., project-acme-web-server). This makes it dangerously easy to accidentally deploy something to a machine. Others have lots of environments, and namespace them (e.g., Acme Production). This makes the environments page very messy. 

**IaaS only**. Environments and machines are good at modelling IaaS things that are shared between projects, but not good at modelling "PaaS" things - like Azure websites or databases. It might make sense to add a SQL Server to an environment, but not individual databases, as an example.  

**Permanent things only**. Our current model assumes things are somewhat permanent, and attempts to support machines that are automatically provisioned don't go so well. 

If you walked up to a team on any given project, and asked them to do a detailed drawing their application's infrastructure, their drawing would include:

 - The applications (web apps, services) and the app/web servers they run on
 - Their Azure websites
 - Their load balancer
 - Their SQL Server and the SQL databases that run on top of it
 - Their Kubernetes cluster and the docker container instances it runs

Right now we don't model these particularly well. Servers might be modelled as environments/machines. Everything else is modelled as variables in a variable set. This means we miss out on opportunities where we could really add value - particularly around health checking and monitoring. 

## Solution

First, imagine that the Environments tab was renamed to "Infrastructure". It's goal would be to give you a view across all the shared infrastructure used by more than one project. Ideally, it would show:

 - Your on-premises virtual machines
 - Virtual machines and other infrastructure discovered from your AWS subscription
 - Virtual machines and other infrastructure discovered from your Azure subscription

Second, what if we moved environments out of the global scope, and into each project. When projects share many virtual machines, this could be handled by having "groups" of virtual machines (or tags?). Environments could then contain different types of resources:

 - Virtual machines that are long-lived
 - Descriptors for machines that might be short-lived (e.g., the Azure subscription and an Azure tag filter)
 - Database instances
 - Certificates
 - Other things
 - Load balancers
 - Azure websites

Third, what if all steps let you specify a target resource in a very simple way:

 - As a specific machine, specifying a different one for each environment
 - As a combination of the resource tags & environment
 - Collections of both

For example, here's how we currently model deploying a package to a bunch of VM's running IIS:

![Package targets](https://cloud.githubusercontent.com/assets/47085/25664988/a328f408-305f-11e7-92b7-9a8fa91ddab3.png)

However, for Azure websites, we don't use the machines/roles indirection - we just let them specify a variable:

![Web app targets](https://cloud.githubusercontent.com/assets/47085/25664907/65daa8bc-305f-11e7-8f3e-fa3f831ad6a6.png)

Why do we do these differently? Originally we did model Azure web sites as "machines", but they had an annoying downside - you couldn't provision them during a deployment. With the variables approach, you could do that easily because it's just a name. 

There's got to be a way we can unify this, so that a step can either specify a target by binding a variable to a name, or to a role, or by specifying a name or role. 



We built Octopus to be quite agnostic of the cloud. Whether you use Azure, AWS, Rackspace or machines under Bert's desk, we model them as machines that belong to environments. 
