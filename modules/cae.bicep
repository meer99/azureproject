param environmentName string
param privateEndpointName string
param location string
param infrastructureSubnetResourceId string
param subnetResourceId string
param vnetResourceId string
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

var privateDnsZoneName = 'privatelink.${location}.azurecontainerapps.io'

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: tags
}

resource dnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: dnsZone
  name: uniqueString(vnetResourceId, privateEndpointName)
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetResourceId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: 'caeConnection'
        properties: {
          privateLinkServiceId: managedEnvironment.id
          groupIds: [
            'managedEnvironments'
          ]
        }
      }
    ]
  }
}

resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'caeZoneConfig'
        properties: {
          privateDnsZoneId: dnsZone.id
        }
      }
    ]
  }
}

output environmentId string = managedEnvironment.id
