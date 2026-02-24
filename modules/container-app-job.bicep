param jobName string
param location string
param managedEnvironmentId string
param userAssignedIdentityId string
param tags object = {}

resource job 'Microsoft.App/jobs@2024-03-01' = {
  name: jobName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    environmentId: managedEnvironmentId
    configuration: {
      triggerType: 'Manual'
      manualTriggerConfig: {
        parallelism: 1
        replicaCompletionCount: 1
      }
      replicaRetryLimit: 0
      replicaTimeout: 1800
    }
    template: {
      containers: [
        {
          name: 'job-container'
          image: 'mcr.microsoft.com/k8se/quickstart-jobs:latest'
          resources: {
            cpu: 1
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}

output jobId string = job.id
