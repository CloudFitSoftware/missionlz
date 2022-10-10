param zoneNames array
param vNetId string

output privateDnsZoneIds array = [for (zoneName, i) in zoneNames: privateDnsZone[i].id]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zoneName in zoneNames: {
  name: zoneName
  location: 'global'
}]


resource vNetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [ for (zoneName, i) in zoneNames: {
  name: last(split(vNetId, '/'))
  location: 'global'
  parent: privateDnsZone[i]
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNetId
    }
  }
}]

