param privateEndpointName string
param location string
param subnetResourceId string
param privateLinkResourceId string
param vnetResourceId string
param tags object = {}

var privateDnsZoneName = 'privatelink.${location}.azurecontainerapps.io'

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: tags
}

resource dnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnsZone.name}/${uniqueString(vnetResourceId, privateEndpointName)}'
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
          privateLinkServiceId: privateLinkResourceId
          groupIds: [
            'managedEnvironments'
          ]
        }
      }
    ]
  }
}

resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: '${privateEndpoint.name}/default'
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
