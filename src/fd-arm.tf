

################################################################################################################################################## locals

locals {
  arm_name       = format("arm%s%s", local.test_name, local.randombit)
  fd_name        = format("fd%s%s", local.test_name, local.randombit)
  fd_policy_name = format("fdpol%s%s", local.test_name, local.randombit)
}

################################################################################################################################################## FDARM-Premium
resource "azurerm_template_deployment" "frontdoor-arm-test1" {
  name                = local.arm_name
  resource_group_name = azurerm_resource_group.fd_test_rg.name

  template_body = <<EOF
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "input_fd_name": {
            "defaultValue": "temp-test-remove",
            "type": "String"
        },
        "fd_waf_policies_name": {
            "defaultValue": "testwafpolicy",
            "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Cdn/profiles",
            "apiVersion": "2020-09-01",
            "name": "[parameters('input_fd_name')]",
            "location": "Global",
            "tags": {
                "automated": "true"
            },
            "sku": {
                "name": "Premium_AzureFrontDoor"
            },
            "kind": "frontdoor",
            "properties": {}
        },
        {
            "type": "Microsoft.Network/frontdoorwebapplicationfirewallpolicies",
            "apiVersion": "2020-11-01",
            "name": "[parameters('fd_waf_policies_name')]",
            "location": "Global",
            "sku": {
                "name": "Premium_AzureFrontDoor"
            },
            "properties": {
                "policySettings": {
                    "enabledState": "Enabled",
                    "mode": "Detection",
                    "requestBodyCheck": "Enabled"
                },
                "customRules": {
                    "rules": []
                },
                "managedRules": {
                    "managedRuleSets": [
                        {
                            "ruleSetType": "DefaultRuleSet",
                            "ruleSetVersion": "1.0",
                            "ruleGroupOverrides": [],
                            "exclusions": []
                        },
                        {
                            "ruleSetType": "Microsoft_BotManagerRuleSet",
                            "ruleSetVersion": "1.0",
                            "ruleGroupOverrides": [],
                            "exclusions": []
                        }
                    ]
                }
            }
        },
        {
            "type": "Microsoft.Cdn/profiles/afdEndpoints",
            "apiVersion": "2020-09-01",
            "name": "[concat(parameters('input_fd_name'), '/', parameters('input_fd_name'))]",
            "location": "Global",
            "dependsOn": [
                "[resourceId('Microsoft.Cdn/profiles', parameters('input_fd_name'))]"
            ],
            "properties": {
                "originResponseTimeoutSeconds": 60,
                "enabledState": "Enabled"
            }
        },
        {
            "type": "Microsoft.Cdn/profiles/originGroups",
            "apiVersion": "2020-09-01",
            "name": "[concat(parameters('input_fd_name'), '/default-origin-group')]",
            "dependsOn": [
                "[resourceId('Microsoft.Cdn/profiles', parameters('input_fd_name'))]"
            ],
            "properties": {
                "loadBalancingSettings": {
                    "sampleSize": 4,
                    "successfulSamplesRequired": 3,
                    "additionalLatencyInMilliseconds": 50
                },
                "healthProbeSettings": {
                    "probePath": "/",
                    "probeRequestType": "HEAD",
                    "probeProtocol": "Http",
                    "probeIntervalInSeconds": 100
                },
                "sessionAffinityState": "Disabled"
            }
        },
        {
            "type": "Microsoft.Cdn/profiles/originGroups/origins",
            "apiVersion": "2020-09-01",
            "name": "[concat(parameters('input_fd_name'), '/default-origin-group/default-origin')]",
            "dependsOn": [
                "[resourceId('Microsoft.Cdn/profiles/originGroups', parameters('input_fd_name'), 'default-origin-group')]",
                "[resourceId('Microsoft.Cdn/profiles', parameters('input_fd_name'))]"
            ],
            "properties": {
                "hostName": "www.jonathanhardison.com",
                "httpPort": 80,
                "httpsPort": 443,
                "originHostHeader": "www.jonathanhardison.com",
                "priority": 1,
                "weight": 1000,
                "enabledState": "Enabled"
            }
        },
        {
            "type": "Microsoft.Cdn/profiles/afdEndpoints/routes",
            "apiVersion": "2020-09-01",
            "name": "[concat(parameters('input_fd_name'), '/', parameters('input_fd_name'), '/default-route')]",
            "dependsOn": [
                "[resourceId('Microsoft.Cdn/profiles/afdEndpoints', parameters('input_fd_name'), parameters('input_fd_name'))]",
                "[resourceId('Microsoft.Cdn/profiles', parameters('input_fd_name'))]",
                "[resourceId('Microsoft.Cdn/profiles/originGroups', parameters('input_fd_name'), 'default-origin-group')]"
            ],
            "properties": {
                "customDomains": [],
                "originGroup": {
                    "id": "[resourceId('Microsoft.Cdn/profiles/originGroups', parameters('input_fd_name'), 'default-origin-group')]"
                },
                "ruleSets": [],
                "supportedProtocols": [
                    "Http",
                    "Https"
                ],
                "patternsToMatch": [
                    "/*"
                ],
                "compressionSettings": {},
                "queryStringCachingBehavior": "IgnoreQueryString",
                "forwardingProtocol": "MatchRequest",
                "linkToDefaultDomain": "Enabled",
                "httpsRedirect": "Enabled",
                "enabledState": "Enabled"
            }
        },
        {
            "type": "Microsoft.Cdn/profiles/securitypolicies",
            "apiVersion": "2020-09-01",
            "name": "[concat(parameters('input_fd_name'), '/testwafpolicy-9da16f1f')]",
            "dependsOn": [
                "[resourceId('Microsoft.Cdn/profiles', parameters('input_fd_name'))]",
                "[resourceId('Microsoft.Network/frontdoorwebapplicationfirewallpolicies', parameters('fd_waf_policies_name'))]",
                "[resourceId('Microsoft.Cdn/profiles/afdEndpoints', parameters('input_fd_name'), parameters('input_fd_name'))]"
            ],
            "properties": {
                "parameters": {
                    "wafPolicy": {
                        "id": "[resourceId('Microsoft.Network/frontdoorwebapplicationfirewallpolicies', parameters('fd_waf_policies_name'))]"
                    },
                    "associations": [
                        {
                            "domains": [
                                {
                                    "id": "[resourceId('Microsoft.Cdn/profiles/afdEndpoints', parameters('input_fd_name'), parameters('input_fd_name'))]"
                                }
                            ],
                            "patternsToMatch": [
                                "/*"
                            ]
                        }
                    ],
                    "type": "WebApplicationFirewall"
                }
            }
        }
    ]
}
EOF


  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "input_fd_name"        = local.fd_name
    "fd_waf_policies_name" = local.fd_policy_name
  }


  #keep incremental or it will nuke rest of deployment without TF knowledge.
  deployment_mode = "Incremental"

  timeouts {
    create = "10h"
    delete = "10h"
    update = "10h"
    read   = "15m"
  }
}