param appInsightsInstrumentationKey string

param storageAccountAccessKey string

param storageAccountName string 

param functionAppName string

param functionAppStagingSlotName string

param appConfiguration_appConfigLabel_value_production string = 'production'
param appConfiguration_appConfigLabel_value_staging string = 'staging'

param additionalAppSettings object = {}

var commonAppSettings = {
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
  APPLICATIONINSIGHTS_CONNECTIONSTRING: 'InstrumentationKey=${appInsightsInstrumentationKey}'
  AzureWebJobStorage: 'DefaultsEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountAccessKey}'
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'powershell'
  WEBSITE_CONTENTSHARE: toLower(storageAccountName)
  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountAccessKey}'
}

var allAppSettings = union(commonAppSettings, additionalAppSettings)

resource createdStagingSlot 'Microsoft.Web/sites/slots@2022-09-01' existing = {
  name: '${functionAppName}/${functionAppStagingSlotName}'
}


var prodSlotSettings = {
  APP_CONFIGURATION_LABEL: appConfiguration_appConfigLabel_value_production
}

resource functionAppSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: '${functionAppName}/appSettings'
  properties: union(allAppSettings, prodSlotSettings)
}

var stagingSlotSettings = {
  APP_CONFIGURATION_LABEL: appConfiguration_appConfigLabel_value_staging
}

resource functionAppSettingsStage 'Microsoft.Web/sites/slots/config@2022-09-01' = {
  name: 'appsettings'
  parent: createdStagingSlot
  properties: union(allAppSettings, stagingSlotSettings)
}


