targetScope = 'resourceGroup'

@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string

param location string = resourceGroup().location
param networkResourceGroupName string = 'rg-ae-net'
param virtualNetworkName string = 'vnet-ae-net'
param subnetName string = 'snet-ae-revbcnet'
param managedIdentityName string = 'mi-ae-revbc'
param logAnalyticsName string = 'log-ae-revbc'
param acrName string = 'acraetestrevbc'
param caeName string = 'cae-ae-revbc'
param containerAppJobBillName string = 'caj-ae-bill'
param containerAppJobDataName string = 'caj-ae-data'
param containerAppJobBillImage string = 'mcr.microsoft.com/k8se/quickstart-jobs:latest'
param containerAppJobDataImage string = 'mcr.microsoft.com/k8se/quickstart-jobs:latest'
param sqlServerName string = 'sql-ae-revbc'
param sqlDatabaseName string = 'db-ae-revbc'
param acrPrivateEndpointName string = 'pe-ae-cr'
param caePrivateEndpointName string = 'pe-ae-cae'
param sqlPrivateEndpointName string = 'pe-ae-sql'
param sqlAdministratorLogin string = 'sqladminrevbc'
@secure()
param sqlAdministratorPassword string
param tags object = {}

var privateEndpointSubnetResourceId = resourceId(subscription().subscriptionId, networkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var networkVnetResourceId = resourceId(subscription().subscriptionId, networkResourceGroupName, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var caeInfrastructureSubnetResourceId = privateEndpointSubnetResourceId

module managedIdentityModule './modules/managed-identity.bicep' = {
  name: 'managedIdentity-${environment}'
  params: {
    identityName: managedIdentityName
    location: location
    tags: tags
  }
}

module logAnalyticsModule './modules/log-analytics.bicep' = {
  name: 'logAnalytics-${environment}'
  params: {
    workspaceName: logAnalyticsName
    location: location
    tags: tags
  }
}

module acrModule './modules/acr.bicep' = {
  name: 'acr-${environment}'
  params: {
    registryName: acrName
    privateEndpointName: acrPrivateEndpointName
    location: location
    subnetResourceId: privateEndpointSubnetResourceId
    userAssignedIdentityId: managedIdentityModule.outputs.identityId
    vnetResourceId: networkVnetResourceId
    tags: tags
  }
}

module caeModule './modules/cae.bicep' = {
  name: 'cae-${environment}'
  params: {
    environmentName: caeName
    privateEndpointName: caePrivateEndpointName
    location: location
    infrastructureSubnetResourceId: caeInfrastructureSubnetResourceId
    subnetResourceId: privateEndpointSubnetResourceId
    vnetResourceId: networkVnetResourceId
    tags: tags
  }
}

module billJobModule './modules/container-app-job.bicep' = {
  name: 'billJob-${environment}'
  params: {
    jobName: containerAppJobBillName
    location: location
    managedEnvironmentId: caeModule.outputs.environmentId
    userAssignedIdentityId: managedIdentityModule.outputs.identityId
    image: containerAppJobBillImage
    tags: tags
  }
}

module dataJobModule './modules/container-app-job.bicep' = {
  name: 'dataJob-${environment}'
  params: {
    jobName: containerAppJobDataName
    location: location
    managedEnvironmentId: caeModule.outputs.environmentId
    userAssignedIdentityId: managedIdentityModule.outputs.identityId
    image: containerAppJobDataImage
    tags: tags
  }
}

module sqlServerModule './modules/sql-server.bicep' = {
  name: 'sqlServer-${environment}'
  params: {
    serverName: sqlServerName
    privateEndpointName: sqlPrivateEndpointName
    location: location
    administratorLogin: sqlAdministratorLogin
    administratorPassword: sqlAdministratorPassword
    subnetResourceId: privateEndpointSubnetResourceId
    vnetResourceId: networkVnetResourceId
    tags: tags
  }
}

module sqlDatabaseModule './modules/sql-database.bicep' = {
  name: 'sqlDatabase-${environment}'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    serverName: sqlServerName
    databaseName: sqlDatabaseName
    location: location
    tags: tags
  }
}

output identityPrincipalId string = managedIdentityModule.outputs.principalId
output logAnalyticsWorkspaceId string = logAnalyticsModule.outputs.workspaceId
output containerRegistryId string = acrModule.outputs.registryId
output managedEnvironmentId string = caeModule.outputs.environmentId
output sqlServerId string = sqlServerModule.outputs.serverId
output sqlDatabaseId string = sqlDatabaseModule.outputs.databaseId
