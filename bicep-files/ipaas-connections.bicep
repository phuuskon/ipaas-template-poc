param location string = 'westeurope'
param sa_name string = 'stelisaipaassystem'
param logicapp_si_tenantid string
param logicapp_si_objectid string
param servicebus_name string

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: sa_name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource stgContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${sa_name}/default/01-messages'
  dependsOn: [
    storageAccount
  ]
}

resource storageConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azureblob'
  kind: 'V2'
  location: location
  properties: {
    displayName: 'privatestorage'
    parameterValues: {
      accountName: '${sa_name}'
      accessKey: '${listKeys(storageAccount.id, '2019-06-01').keys[0].value}'
    }
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
    }
  }
  dependsOn: [
    storageAccount
  ]
}

resource stConnAccessPolicies 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: 'azureblob/${logicapp_si_objectid}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: '${logicapp_si_tenantid}'
        objectId: '${logicapp_si_objectid}'
      }
    }
  }
  dependsOn: [
    storageConnection
  ]
}
