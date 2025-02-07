param location string
param prefix string
param vmName string = '${prefix}-vm'
param logicAppName string = '${prefix}-logicapp'
param actionGroupName string = '${prefix}-actionGroup'
param signalRName string = '${prefix}-signalr'
param logAnalyticsWorkspaceName string = '${prefix}-loganalytics'

// Recurso existente: Máquina virtual a monitorear
resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' existing = {
  name: vmName
  scope: resourceGroup('dgenerative-chaos')
}

// Recurso: Log Analytics Workspace para almacenar señales de monitorización
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {}
}

// Recurso: Diagnostic Setting para enviar logs y métricas de la VM al Log Analytics Workspace
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vmName}-diag'
  dependsOn: [
    vm
  ]
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'AuditLogs'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'PerformanceCounters'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}

// Nota: Las máquinas virtuales no soportan el recurso "Microsoft.Insights/diagnosticSettings" de forma nativa.
// Para que la VM envíe sus métricas y logs, se recomienda instalar la extensión de diagnóstico.
// A continuación, se agrega un recurso de extensión para una VM Linux (ajusta según el SO y requerimientos).
resource vmDiagnostics 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: 'LinuxDiagnostics'
  parent: vmName // Referencia al recurso de la VM
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'LinuxDiagnostics'
    typeHandlerVersion: '3.0'
    autoUpgradeMinorVersion: true
    settings: {
      // Configuración de ejemplo; asegúrate de ajustarla según tus necesidades.
      ladCfg: {
        diagnosticMonitorConfiguration: {
          metrics: {
            // Configura la transferencia de métricas según lo requerido.
            aggregation: [
              {
                scheduledTransferPeriod: 'PT1M'
                enabled: true
              }
            ]
          }
          performanceCounters: [
            {
              counterSpecifier: '% Processor'
              sampleRate: 'PT1M'
              unit: 'Percent'
            }
          ]
        }
      }
    }
    protectedSettings: {}
  }
}

// Recurso: Servicio SignalR
resource signalR 'Microsoft.SignalRService/signalr@2022-02-01' = {
  name: signalRName
  location: location
  sku: {
    name: 'Standard_S1'
    capacity: 1
  }
  properties: {
    cors: {
      allowedOrigins: [
        '*'  // Ajusta según tus necesidades
      ]
    }
    // Configuramos el servicio en modo Serverless (puedes cambiar si es necesario)
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
      }
    ]
  }
}

// Recurso: Logic App que recibe el webhook y lo reenvía a SignalR
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {}
          }
        }
      }
      actions: {
        SendToSignalR: {
          type: 'Http'
          inputs: {
            method: 'POST'
            uri: 'https://${signalR.properties.hostName}/api/alerts'
            body: '@triggerBody()'
          }
        }
      }
      outputs: {}
    }
    parameters: {}
  }
}

// Recurso: Action Group que envía su alerta a la Logic App mediante webhook
resource actionGroup 'Microsoft.Insights/actionGroups@2019-06-01' = {
  name: actionGroupName
  location: location
  properties: {
    groupShortName: substring(prefix, 0, 12)
    enabled: true
    webhookReceivers: [
      {
        name: 'LogicAppReceiver'
        serviceUri: listCallbackUrl(logicApp.id, '2019-05-01').value
        useCommonAlertSchema: true
      }
    ]
  }
}

// Alerta de métricas (CPU) para la VM
resource cpuOverloadAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'CPU_Overload'
  location: 'global'
  properties: {
    description: 'ALERTA: Uso de CPU sospechosamente bajo. ¿Hackeo en proceso?'
    severity: 3
    enabled: true
    scopes: [
      vm.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT1M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'CpuOverloadCriteria'
          criterionType: 'StaticThresholdCriterion'
          timeAggregation: 'Average'
          operator: 'GreaterThan'
          threshold: 1
          metricName: 'Percentage CPU'
        }
      ]
    }
  }
}
