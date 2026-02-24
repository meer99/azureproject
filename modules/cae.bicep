param environmentName string
param location string
param infrastructureSubnetResourceId string
param tags object = {}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Disabled'
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]
    vnetConfiguration: {
      infrastructureSubnetId: infrastructureSubnetResourceId
      internal: true
    }
  }
}

output environmentId string = managedEnvironment.id
