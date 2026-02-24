param environmentName string
param location string
param tags object = {}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

output environmentId string = managedEnvironment.id
