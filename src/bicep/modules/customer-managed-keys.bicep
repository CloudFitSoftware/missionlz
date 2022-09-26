/*
Copyright (c) Microsoft Corporation.
Licensed under the MIT License.
*/

param userAssignedIdentityName string
param keyVaultName string
param location string
param tags object = {}

param keyVaultKeyName string = 'cmkey'
// param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userAssignedIdentityName
  location: location
  tags: tags
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableSoftDelete: true
    enablePurgeProtection: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'unwrapKey'
            'wrapKey'
            'get'
          ]
        }
        objectId: userAssignedIdentity.properties.principalId
      }
    ]
  }
}

resource kvKey 'Microsoft.KeyVault/vaults/keys@2021-10-01' = {
  parent: keyVault
  name: keyVaultKeyName
  properties: {
    attributes: {
      enabled: true
      // exp: keyExpiration
    }
    keySize: 4096
    kty: 'RSA'

  }

}
