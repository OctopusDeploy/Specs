Actions {
  ActionType = "Octopus.KubernetesDeployContainers"
  CanBeUsedForProjectVersioning = true
  Channels = []
  Environments = []
  ExcludedEnvironments = []
  Id = "f2648a96-9dd2-4f55-b3b6-fbde0fe8dd48"
  IsDisabled = false
  IsRequired = false
  Links {}
  Name = "Deploy Octopus Server"
  Packages {
    AcquisitionLocation = "NotAcquired"
    FeedId = "Feeds-1042"
    Id = "9d6f4b70-b62a-4c8c-ad4b-af710bb0a54d"
    Name = "octopus"
    PackageId = "octopusdeploy/linuxoctopus"
    Properties {
      Extract = "true"
    }
  }
  Properties {
    "Octopus.Action.EnabledFeatures" = "Octopus.Features.KubernetesService,Octopus.Features.KubernetesConfigMap,Octopus.Features.KubernetesSecret,Octopus.Features.KubernetesCustomResource"
    "Octopus.Action.KubernetesContainers.CombinedVolumes" = <<EOF 
              [
            {
              "Items": [],
              "Name": "azure-file-share",
              "ReferenceName": "",
              "ReferenceNameType": "Custom",
              "EmptyDirMedium": "",
              "HostPathType": "Directory",
              "HostPathPath": "",
              "LocalPath": "",
              "Type": "RawYaml",
              "RawYaml": "azureFile:\
                secretName: volume-azurefile-storage-secret\
                shareName: #{InstanceId}\
                readOnly: false",
              "Repository": "",
              "Revision": ""
            },
            {
              "Items": [],
              "Name": "octopus-logs",
              "ReferenceName": "",
              "ReferenceNameType": "Custom",
              "EmptyDirMedium": "",
              "HostPathType": "Directory",
              "HostPathPath": "",
              "LocalPath": "",
              "Type": "EmptyDir",
              "RawYaml": "",
              "Repository": "",
              "Revision": ""
            },
            {
              "Items": [],
              "Name": "octopus-nlog-config",
              "ReferenceName": "octopus-nlog-config-#{Octopus.Deployment.Id | ToLower }",
              "ReferenceNameType": "CustomResource",
              "EmptyDirMedium": "",
              "HostPathType": "Directory",
              "HostPathPath": "",
              "LocalPath": "",
              "Type": "ConfigMap",
              "RawYaml": "",
              "Repository": "",
              "Revision": ""
            }
          ]
        "
    EOF
    "Octopus.Action.KubernetesContainers.ConfigMapName" = "octopus"
    "Octopus.Action.KubernetesContainers.ConfigMapValues" = <<EOF 
                        {
            "octopus-auth-providers-to-install": "#{AuthProvidersToInstall}",
            "octopus-octopusid-clientid": "#{OctopusIdClientId}",
            "octopus-octopusid-issuer": "#{OctopusIdIssuer}"
          }
        "
    EOF
    "Octopus.Action.KubernetesContainers.Containers" = <<EOF 
                        [
            {
              "Name": "octopus",
              "Ports": [
                {
                  "key": "tentacle",
                  "keyError": null,
                  "value": "10943",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "web8080",
                  "keyError": null,
                  "value": "8080",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "web443",
                  "keyError": null,
                  "value": "443",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                }
              ],
              "EnvironmentVariables": [
                {
                  "key": "ADMIN_USERNAME",
                  "keyError": null,
                  "value": "#{AdminUsername}",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "ACCEPT_EULA",
                  "keyError": null,
                  "value": "Y",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "ADMIN_EMAIL",
                  "keyError": null,
                  "value": "devops@octopus.com",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "HAS_STATIC_IP",
                  "keyError": null,
                  "value": "#{HasStaticIp}",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                }
              ],
              "SecretEnvironmentVariables": [
                {
                  "key": "MASTER_KEY",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedSecretName}",
                  "valueError": null,
                  "option": "octopus-masterkey",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "ADMIN_API_KEY",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedSecretName}",
                  "valueError": null,
                  "option": "octopus-api-key",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "CONNSTRING",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedSecretName}",
                  "valueError": null,
                  "option": "octopus-connstring",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "OCTOPUSID_CLIENT_SECRET",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedSecretName}",
                  "valueError": null,
                  "option": "octopus-octopusid-clientsecret",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "CERTIFICATE",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedSecretName}",
                  "valueError": null,
                  "option": "octopus-certificate",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "CERTIFICATE_KEY",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedSecretName}",
                  "valueError": null,
                  "option": "octopus-certificate-key",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                }
              ],
              "ConfigMapEnvironmentVariables": [
                {
                  "key": "AUTH_PROVIDERS_TO_INSTALL",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedConfigMapName}",
                  "valueError": null,
                  "option": "octopus-auth-providers-to-install",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "OCTOPUSID_CLIENT_ID",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedConfigMapName}",
                  "valueError": null,
                  "option": "octopus-octopusid-clientid",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "OCTOPUSID_ISSUER",
                  "keyError": null,
                  "value": "#{Octopus.Action.KubernetesContainers.ComputedConfigMapName}",
                  "valueError": null,
                  "option": "octopus-octopusid-issuer",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                }
              ],
              "VolumeMounts": [
                {
                  "key": "azure-file-share",
                  "keyError": null,
                  "value": "/taskLogs",
                  "valueError": null,
                  "option": "tasklogs",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "azure-file-share",
                  "keyError": null,
                  "value": "/repository",
                  "valueError": null,
                  "option": "repository",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "azure-file-share",
                  "keyError": null,
                  "value": "/artifacts",
                  "valueError": null,
                  "option": "artifacts",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "azure-file-share",
                  "keyError": null,
                  "value": "/cache",
                  "valueError": null,
                  "option": "cache",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "azure-file-share",
                  "keyError": null,
                  "value": "/diagnostics",
                  "valueError": null,
                  "option": "diagnostics",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "octopus-logs",
                  "keyError": null,
                  "value": "/mnt/c/OctopusDev/OctopusServer/Server/Logs",
                  "valueError": null,
                  "option": "",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                },
                {
                  "key": "octopus-nlog-config",
                  "keyError": null,
                  "value": "/Octopus/Octopus.Server.exe.nlog",
                  "valueError": null,
                  "option": "Octopus.Server.exe.nlog",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                }
              ],
              "Resources": {
                "requests": {
                  "memory": "#{MemoryRequest}",
                  "cpu": "#{CPURequest}"
                },
                "limits": {
                  "memory": "#{MemoryLimit}",
                  "cpu": "#{CPULimit}"
                }
              },
              "LivenessProbe": {
                "failureThreshold": "10",
                "initialDelaySeconds": "1800",
                "periodSeconds": "30",
                "successThreshold": "",
                "timeoutSeconds": "5",
                "type": "Command",
                "exec": {
                  "command": [
                    "/bin/bash",
                    "-c",
                    "HAS_STATIC_IP=#{hasstaticip}; if [[ $HAS_STATIC_IP == \"True\" ]]; then URL=https://localhost:443; else URL=http://localhost:8080; fi; response=$(/usr/bin/curl -k $URL/api/octopusservernodes/ping --write-out %{http_code} --silent --output /dev/null); /usr/bin/test \"$response\" -ge 200 \u0026\u0026 /usr/bin/test \"$response\" -le 299 || /usr/bin/test \"$response\" -eq 418"
                  ]
                }
              },
              "ReadinessProbe": {
                "failureThreshold": "60",
                "initialDelaySeconds": "30",
                "periodSeconds": "30",
                "successThreshold": "",
                "timeoutSeconds": "5",
                "type": "Command",
                "exec": {
                  "command": [
                    "/bin/bash",
                    "-c",
                    "HAS_STATIC_IP=#{hasstaticip}; if [[ $HAS_STATIC_IP == \"True\" ]]; then URL=https://localhost:443; else URL=http://localhost:8080; fi; response=$(/usr/bin/curl -k $URL/api/octopusservernodes/ping --write-out %{http_code} --silent --output /dev/null); /usr/bin/test \"$response\" -ge 200 \u0026\u0026 /usr/bin/test \"$response\" -le 299 || /usr/bin/test \"$response\" -eq 418"
                  ]
                }
              },
              "Command": [],
              "Args": [],
              "SecurityContext": {
                "allowPrivilegeEscalation": "",
                "privileged": "",
                "readOnlyRootFilesystem": "",
                "runAsGroup": "",
                "runAsNonRoot": "",
                "runAsUser": "",
                "capabilities": {
                  "add": [
                    "CAP_SYS_PTRACE"
                  ],
                  "drop": []
                },
                "seLinuxOptions": {
                  "level": "",
                  "role": "",
                  "type": "",
                  "user": ""
                }
              },
              "Lifecycle": {
                "PreStop": {
                  "Exec": {
                    "command": [
                      "dotnet",
                      "/Octopus/Octopus.Server.dll",
                      "node",
                      "--instance=OctopusServer",
                      "--drain=true",
                      "--wait=600",
                      "--cancel-tasks"
                    ]
                  }
                }
              }
            }
          ]
        "
    EOF
    "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: octopus
  name: octopus-nlog-config
data:
  Octopus.Server.exe.nlog: |+
    <?xml version="1.0" encoding="utf-8"?>
        <nlog
          xmlns="http://www.nlog-project.org/schemas/NLog.xsd"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          autoReload="true"
          throwExceptions="false"
          internalLogLevel="Error"
          internalLogToConsole="true">
          <extensions>
            <add assembly="Octopus.Shared" />
            <add assembly="Octopus.Server" />
          </extensions>
          <variable name="appName" value="Octopus" />
          <variable name="messageLayout" value="${message}${onexception:${newline}${exception:format=ToString}}" />
          <variable name="normalLayout" value="${longdate}  ${processid:padding=5}  ${threadid:padding=5} ${uppercase:${level}:padding=5}  ${messageLayout}" />
          <variable name="metricLayout" value="{ &quot;logdatetime&quot;: &quot;${longdate:universalTime=true}&quot;, &quot;loglevel&quot;: &quot;${uppercase:${level}}&quot;, ${messageLayout} }" />
          <targets async="false">
            <target name="octopus-log-file" xsi:type="File" layout="${normalLayout}" fileName="${octopusLogsDirectory}/OctopusServer.txt" archiveFileName="${octopusLogsDirectory}/OctopusServer.{#}.txt" archiveEvery="Day" archiveNumbering="Rolling" maxArchiveFiles="7" concurrentWrites="true" keepFileOpen="false" />
            <target name="octopus-metrics-file" xsi:type="File" layout="${metricLayout}" fileName="${octopusLogsDirectory}/Metrics.txt" archiveFileName="${octopusLogsDirectory}/Metrics.{#}.txt" archiveEvery="Hour" archiveNumbering="Rolling" maxArchiveFiles="1" concurrentWrites="true" keepFileOpen="false" />
            <target xsi:type="ColoredConsole" name="stdout" layout="${messageLayout}" />
            <target xsi:type="ColoredConsole" name="stderr" errorStream="true" layout="${messageLayout}" />
            <target xsi:type="EventLog" name="eventlog" source="${appName}" layout="${normalLayout}" />
            <target xsi:type="RecentInMemory" name="recent" bufferSize="100" />
            <target name="seqbufferingwrapper" xsi:type="BufferingWrapper" bufferSize="1000" flushTimeout="2000">
              <target name="seq" xsi:type="Seq" serverUrl="#{Seq.Url}" apiKey="#{Seq.ApiKey}">
                <property name="Application" value="Octopus.Server.Instance" />
                <property name="ApplicationSet" value="Hostedv2" />
                <property name="Environment" value="#{Octopus.Environment.Name}" />
                <property name="Reef" value="#{Reef}" />
                <property name="InstanceId" value="#{InstanceId}" />
              </target>
            </target>
          </targets>
          <rules>
            <logger name="MetricsLogger" writeTo="octopus-metrics-file" final="true" />
            <logger name="LogFileOnlyLogger" writeTo="octopus-log-file" final="true" />
            <logger name="Halibut" minlevel="Info" writeTo="octopus-log-file" />
            <logger name="*" minlevel="Info" writeTo="octopus-log-file" />
            <logger name="*" minlevel="Fatal" writeTo="eventlog" />
            <logger name="*" minlevel="Warn" writeTo="recent" />
            <logger name="*" minlevel="Info" maxLevel="Warn" writeTo="stdout" />
            <logger name="*" minlevel="Error" writeTo="stderr" />
            <logger name="*" minlevel="Info" writeTo="seqbufferingwrapper" />
          </rules>
        </nlog>
    "Octopus.Action.KubernetesContainers.DeploymentLabels" = <<EOF 
          {
            "Hosted.Instance": "#{InstanceId}",
            "Hosted.OctopusServerVersion": "#{OctopusServerVersion}",
            "Hosted.DnsPrefix": "#{DnsPrefix}"
          }
    EOF
    "Octopus.Action.KubernetesContainers.DeploymentName" = "octopus-#{InstanceId}"
    "Octopus.Action.KubernetesContainers.DeploymentStyle" = "Recreate"
    "Octopus.Action.KubernetesContainers.DeploymentWait" = "Wait"
    "Octopus.Action.KubernetesContainers.NodeAffinity" = <<EOF 
           [
            {
              "Type": "Required",
              "Weight": "",
              "InMatch": [
                {
                  "key": "agentpool",
                  "keyError": null,
                  "value": "In",
                  "valueError": null,
                  "option": "linuxpool",
                  "optionError": null,
                  "option2": "",
                  "option2Error": null
                }
              ],
              "ExistMatch": []
            }
          ]
    EOF
    "Octopus.Action.KubernetesContainers.PodAnnotations" = <<EOF 
        [
            {
              "key": "cluster-autoscaler.kubernetes.io/safe-to-evict",
              "keyError": null,
              "value": "false",
              "valueError": null,
              "option": "",
              "optionError": null,
              "option2": "",
              "option2Error": null
            }
          ]
    EOF
    "Octopus.Action.KubernetesContainers.ProgressDeadlineSeconds" = "1500"
    "Octopus.Action.KubernetesContainers.Replicas" = "1"
    "Octopus.Action.KubernetesContainers.SecretName" = "octopus"
    "Octopus.Action.KubernetesContainers.SecretValues" = <<EOF 
                        {
            "octopus-api-key": "#{ApiKey}",
            "octopus-masterkey": "#{MasterKey}",
            "octopus-connstring": "#{DatabaseConnectionString}",
            "octopus-octopusid-clientsecret": "#{OctopusIdClientSecret}",
            "octopus-certificate": "#{Certificate}",
            "octopus-certificate-key": "#{CertificateKey}"
          }
    EOF
    "Octopus.Action.KubernetesContainers.ServiceName" = "octopus-#{InstanceId}"
    "Octopus.Action.KubernetesContainers.ServicePorts" = <<EOF 
        [
            {
              "name": "web",
              "port": "80",
              "targetPort": "8080",
              "nodePort": "",
              "protocol": "TCP"
            },
            {
              "name": "tentacle",
              "port": "10943",
              "targetPort": "",
              "nodePort": "",
              "protocol": "TCP"
            },
            {
              "name": "metrics",
              "port": "9273",
              "targetPort": "9273",
              "nodePort": "",
              "protocol": "TCP"
            }
          ]
    EOF
    "Octopus.Action.KubernetesContainers.ServiceType" = "ClusterIP"
    "Octopus.Action.KubernetesContainers.TerminationGracePeriodSeconds" = "610"
    "Octopus.Action.RunOnServer" = "true"
  }
  TenantTags = []
  WorkerPoolId = 
}