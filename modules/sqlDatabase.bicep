@description('Name of the SQL Database')
param sqlDatabaseName string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object

@description('Name of the SQL Server')
param sqlServerName string

@description('Service tier for the database')
param skuName string = 'Standard'

@description('DTU capacity')
param dtuCapacity int = 10

@description('Maximum data size in bytes (5 GB)')
param maxSizeBytes int = 5368709120

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: sqlServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuName
    capacity: dtuCapacity
  }
  properties: {
    maxSizeBytes: maxSizeBytes
  }
}

@description('The resource ID of the SQL Database')
output sqlDatabaseId string = sqlDatabase.id
