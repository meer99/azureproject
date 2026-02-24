@description('Environment name (dev, uat, prod)')
param environment string

@description('Location for all resources')
param location string

@description('Name of the managed identity')
param managedIdentityName string

@description('Name of the Log Analytics workspace')
param logAnalyticsName string

@description('Name of the container registry')
param containerRegistryName string

@description('Name of the Container Apps Environment')
param containerAppsEnvironmentName string

@description('Name of Container App Job 1')
param containerAppJob1Name string

@description('Name of Container App Job 2')
param containerAppJob2Name string

@description('Name of the SQL Server')
param sqlServerName string

@description('SQL Server administrator login')
param sqlAdminLogin string

@description('SQL Server administrator login password')
@secure()
param sqlAdminPassword string

@description('Name of the SQL Database')
param sqlDatabaseName string

@description('Name of the private endpoint for Container Registry')
param crPrivateEndpointName string

@description('Name of the private endpoint for Container Apps Environment')
param caePrivateEndpointName string

@description('Name of the private endpoint for SQL Server')
param sqlPrivateEndpointName string

@description('Resource group name for networking')
param networkResourceGroupName string

@description('Virtual network name')
param vnetName string

@description('Subnet name')
param subnetName string

@description('Tags for the resources')
param tags object

// Reference existing networking resources
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
  scope: resourceGroup(networkResourceGroupName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: subnetName
  parent: vnet
}

// Module: Managed Identity
module managedIdentity 'modules/managedIdentity.bicep' = {
  name: 'deploy-managed-identity-${environment}'
  params: {
    managedIdentityName: managedIdentityName
    location: location
    tags: tags
  }
}

// Module: Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'deploy-log-analytics-${environment}'
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
    tags: tags
  }
}

// Module: Container Registry with Private Endpoint
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'deploy-container-registry-${environment}'
  params: {
    containerRegistryName: containerRegistryName
    location: location
    tags: tags
    managedIdentityId: managedIdentity.outputs.managedIdentityId
    privateEndpointName: crPrivateEndpointName
    subnetId: subnet.id
    vnetId: vnet.id
  }
}

// Module: Container Apps Environment with Private Endpoint
module containerAppsEnvironment 'modules/containerAppsEnvironment.bicep' = {
  name: 'deploy-cae-${environment}'
  params: {
    containerAppsEnvironmentName: containerAppsEnvironmentName
    location: location
    tags: tags
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    privateEndpointName: caePrivateEndpointName
    subnetId: subnet.id
    infrastructureSubnetId: subnet.id
    vnetId: vnet.id
    regionName: location
  }
}

// Module: Container App Job 1
module containerAppJob1 'modules/containerAppJob.bicep' = {
  name: 'deploy-caj-bill-${environment}'
  params: {
    containerAppJobName: containerAppJob1Name
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.containerAppsEnvironmentId
    managedIdentityId: managedIdentity.outputs.managedIdentityId
  }
}

// Module: Container App Job 2
module containerAppJob2 'modules/containerAppJob.bicep' = {
  name: 'deploy-caj-data-${environment}'
  params: {
    containerAppJobName: containerAppJob2Name
    location: location
    tags: tags
    containerAppsEnvironmentId: containerAppsEnvironment.outputs.containerAppsEnvironmentId
    managedIdentityId: managedIdentity.outputs.managedIdentityId
  }
}

// Module: SQL Server with Private Endpoint
module sqlServer 'modules/sqlServer.bicep' = {
  name: 'deploy-sql-server-${environment}'
  params: {
    sqlServerName: sqlServerName
    location: location
    tags: tags
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    privateEndpointName: sqlPrivateEndpointName
    subnetId: subnet.id
    vnetId: vnet.id
  }
}

// Module: SQL Database
module sqlDatabase 'modules/sqlDatabase.bicep' = {
  name: 'deploy-sql-database-${environment}'
  params: {
    sqlDatabaseName: sqlDatabaseName
    location: location
    tags: tags
    sqlServerName: sqlServerName
    skuName: 'Standard'
    dtuCapacity: 10
    maxSizeBytes: 5368709120
  }
  dependsOn: [
    sqlServer
  ]
}
