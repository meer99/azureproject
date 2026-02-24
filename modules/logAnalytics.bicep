@description('Name of the Log Analytics workspace')
param logAnalyticsName string

@description('Location for the resource')
param location string

@description('Tags for the resource')
param tags object

@description('SKU for the Log Analytics workspace')
param sku string = 'PerGB2018'

@description('Retention in days')
param retentionInDays int = 30

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

@description('The resource ID of the Log Analytics workspace')
output logAnalyticsId string = logAnalytics.id

@description('The customer ID of the Log Analytics workspace')
output logAnalyticsCustomerId string = logAnalytics.properties.customerId
