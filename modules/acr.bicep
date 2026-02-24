param registryName string
param location string
param userAssignedIdentityId string
param tags object = {}

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
  }
}

output registryId string = registry.id
