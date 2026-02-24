param serverName string
param location string
param administratorLogin string
@secure()
param administratorPassword string
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    publicNetworkAccess: 'Disabled'
    version: '12.0'
    minimalTlsVersion: '1.2'
  }
}

output serverId string = sqlServer.id
