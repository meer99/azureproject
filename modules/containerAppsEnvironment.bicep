@description('Name of the Container Apps Environment')
param containerAppsEnvironmentName string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object

@description('Resource ID of the Log Analytics workspace')
param logAnalyticsId string

@description('Name of the private endpoint')
param privateEndpointName string

@description('Resource ID of the subnet for the private endpoint')
param subnetId string

@description('Resource ID of the subnet for the Container Apps Environment infrastructure')
param infrastructureSubnetId string

@description('Resource ID of the virtual network for DNS zone link')
param vnetId string

@description('Region short name used to construct the private DNS zone (e.g. australiaeast)')
param regionName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: last(split(logAnalyticsId, '/'))
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppsEnvironmentName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      internal: true
      infrastructureSubnetId: infrastructureSubnetId
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${regionName}.azurecontainerapps.io'
  location: 'global'
  tags: tags
}

resource aRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: containerAppsEnvironment.properties.staticIp
      }
    ]
  }
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${containerAppsEnvironmentName}-dns-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: containerAppsEnvironment.id
          groupIds: [
            'managedEnvironments'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-cae'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

@description('The resource ID of the Container Apps Environment')
output containerAppsEnvironmentId string = containerAppsEnvironment.id

@description('The default domain of the Container Apps Environment')
output defaultDomain string = containerAppsEnvironment.properties.defaultDomain

@description('The static IP of the Container Apps Environment')
output staticIp string = containerAppsEnvironment.properties.staticIp
