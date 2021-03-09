param location string = 'westeurope'
param sa_name string = 'stelisaipaasinfra'
param kv_name string = 'kv-elisa-ipaas-infra'
param sb_name string = 'sb-elisa-ipaas-infra'
param sf_name string = 'phbicebpocapp'
param site_name string = 'ph-bicep-poc-app'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: sa_name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kv_name
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
  name: sb_name
  location: location
  sku: {
    name: 'Standard'
    capacity: 1
    tier: 'Standard'
  }
}

resource sbTopic 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' = {
  name: '${sb_name}/01-testtopic'
}

resource sbTopicSub 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2017-04-01' = {
  name: '${sb_name}/01-testtopic/01-01-testsub'
}

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: sf_name
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
    size: 'F1'
    family: 'F'
    capacity: 0
  }
  kind: 'app'
}

resource site 'Microsoft.Web/sites@2020-06-01' = {
  name: site_name
  location: location
  dependsOn: [
    storageAccount
    serverFarm
  ]
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: serverFarm.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value:'[1.*, 2.0.0]'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${sa_name};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value:'~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${sa_name};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'ph-bicep-poc-app3'
        }
      ]
    }
  } 
}

resource siteconfig 'Microsoft.Web/sites/config@2020-09-01' = {
  name: '${site_name}/web'
  location: location
  dependsOn: [
    site
  ]
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    phpVersion: '5.6'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$${site_name}'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    cors: {
      allowedOrigins: [
        '*'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 23990
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    prewarmedInstanceCount: 0
  }
}

resource sitehostname 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  name: '${site_name}/${site_name}.azurewebsites.net'
  dependsOn: [
    site
  ]
  properties: {
    siteName: '${site_name}'
    hostNameType: 'Verified'
  }
}