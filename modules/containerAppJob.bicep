@description('Name of the Container App Job')
param containerAppJobName string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object

@description('Resource ID of the Container Apps Environment')
param containerAppsEnvironmentId string

@description('Resource ID of the user-assigned managed identity')
param managedIdentityId string

@description('Container image to use')
param containerImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('CPU cores for the container')
param cpu string = '0.25'

@description('Memory for the container')
param memory string = '0.5Gi'

@description('Cron expression for the job schedule')
param cronExpression string = '0 */6 * * *'

resource containerAppJob 'Microsoft.App/jobs@2023-05-01' = {
  name: containerAppJobName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    environmentId: containerAppsEnvironmentId
    configuration: {
      triggerType: 'Schedule'
      replicaTimeout: 1800
      replicaRetryLimit: 1
      scheduleTriggerConfig: {
        cronExpression: cronExpression
      }
    }
    template: {
      containers: [
        {
          name: containerAppJobName
          image: containerImage
          resources: {
            cpu: json(cpu)
            memory: memory
          }
        }
      ]
    }
  }
}

@description('The resource ID of the Container App Job')
output containerAppJobId string = containerAppJob.id
