param location string
param prefix string

// --- Recurso de Virtual Network y Subred ---
resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}
var subnetId = vnet.properties.subnets[0].id

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${prefix}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-All'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// --- Recurso de NIC1 ---
resource nic1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${prefix}-nic1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// --- Recurso de NIC2 (si se requiere) ---
resource nic2 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${prefix}-nic2'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// --- Parámetros para la VM ---
param adminUsername string = 'azureuser'
@secure()
param adminPassword string = 'Admin123!' // Nos encanta meter contraseñas en texto plano en el repositorio y si es publico en GitHub mejor ;)
param vmSize string = 'Standard_B2ms'
param osDiskType string = 'Standard_LRS'
param osDiskDeleteOption string = 'Detach'
param nicDeleteOption string = 'Delete'
param computerName string = 'D-GenerativeVM'
param patchAssessmentMode string = 'AutomaticByPlatform' // o el valor deseado
param hibernationEnabled bool = false
param vmZone string = '1' // Ajusta según la zona deseada

// --- Recurso de VM ---
resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: '${prefix}-vm'
  location: location
  zones: [
    vmZone
  ]
  plan: {
    name: 'kali-2024-2'
    publisher: 'kali-linux'
    product: 'kali'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'kali-linux'   // Imagen oficial de Kali Linux en Azure
        offer: 'kali'
        sku: 'kali-2024-2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: osDiskDeleteOption
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false  // Habilita la autenticación por contraseña
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    additionalCapabilities: {
      hibernationEnabled: hibernationEnabled
    }
  }
}

// --- Recurso de VM Extension para configuración custom en el SO ---
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: '${prefix}-vm/customScript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      // URL(s) de los scripts a ejecutar. Asegúrate de que sean accesibles públicamente o usa un almacenamiento propio.
      fileUris: [
        'https://raw.githubusercontent.com/Alejandrolmeida/d-generative-ai-azure-apocalypse/refs/heads/main/infrastructure/configure-vm.sh'
      ]
      // Comando a ejecutar en la VM. Por ejemplo, el script puede instalar paquetes o aplicar configuraciones.
      commandToExecute: 'bash configure-vm.sh'
    }
  }
  dependsOn: [
    vm
  ]
}

// --- Sección de Storage ---
resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${prefix}storageopen'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: false  // Permitimos HTTP para mayor inseguridad
    allowBlobPublicAccess: true
  }
}

// --- Sección de SQL ---
resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: '${prefix}-sqlserver'
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'Password123!' // Contraseña pública, porque confiamos en la humanidad
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${prefix}-sqldb'
  location: location
  parent: sqlServer
  properties: {
  }
}
