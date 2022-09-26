/*
Copyright (c) Microsoft Corporation.
Licensed under the MIT License.
*/

param storageAccountName string
param location string
param skuName string
param tags object = {}

param useCustomerManagedKey bool = false
param userAssignedIdentityName string = ''
param keyVaultName string = ''
param customerManagedKeyName string = ''

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if (useCustomerManagedKey) {
  scope: resourceGroup()
  name: userAssignedIdentityName
}
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = if (useCustomerManagedKey) {
  scope: resourceGroup()
  name: keyVaultName
}
resource kvKey 'Microsoft.KeyVault/vaults/keys@2021-10-01' existing = if (useCustomerManagedKey) {
  parent: keyVault
  name: customerManagedKeyName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  sku: {
    name: skuName
  }
  tags: tags
  properties: {
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
    encryption: {
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: kvKey.name
        keyvaulturi: keyVault.properties.vaultUri
      }
      requireInfrastructureEncryption: true
      identity: {
        userAssignedIdentity: userAssignedIdentity.id
      }
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }

}
output id string = storageAccount.id
