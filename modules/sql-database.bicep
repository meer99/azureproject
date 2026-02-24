param serverName string
param databaseName string
param location string
param tags object = {}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: '${serverName}/${databaseName}'
  location: location
  tags: tags
  sku: {
    name: 'S0'
    tier: 'Standard'
    capacity: 10
  }
  properties: {
    maxSizeBytes: 5368709120
  }
}

output databaseId string = sqlDatabase.id
