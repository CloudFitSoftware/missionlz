param location string
param storageAccountName string
param storageAccountId string
param privateEndpointName string ='pep-${storageAccountName}'
param subnetId string
param privateLinkGroupId string
param privateDnsZoneId string



resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            privateLinkGroupId
          ]
        }
      }
    ]
  }
}

resource privateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: 'DnsPrivate'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateLinkGroupId
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
