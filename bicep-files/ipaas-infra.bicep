param location string = 'westeurope'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'stelisaipaasinfra'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'kv-elisa-ipaas-infra'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: [
      
    ]
  }
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: 'sb-elisa-ipaas-infra'
  location: location
  sku: {
    name: 'Standard'
    capacity: 1
    tier: 'Standard'
  }
}

resource sbTopic 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' = {
  name: 'sb-elisa-ipaas-infra/01-testtopic'
}

