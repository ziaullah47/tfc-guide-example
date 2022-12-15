terraform {
  required_version = ">= 0.12.6"
  required_providers {
    azurerm = {
      version = "~> 2.53.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id            = var.subscription_id
  skip_provider_registration = true
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "example" {
}

resource "azurerm_role_definition" "example" {
  role_definition_id = "00000000-0000-0000-0000-000000000000"
  name               = "my-custom-role-definition"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = ["Microsoft.Authorization/policyassignments/*", "Microsoft.Authorization/policydefinitions/*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

resource "azurerm_role_assignment" "example" {
  name               = "00000000-0000-0000-0000-000000000000"
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.example.role_definition_resource_id
  principal_id       = data.azurerm_client_config.example.object_id
}

resource "azurerm_policy_definition" "policy" {
  name         = "accTestPolicy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "acceptance test policy definition"

  metadata = <<METADATA
    {
    "category": "Cosmos DB"
    }

METADATA


  policy_rule = <<POLICY_RULE
 {
    "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.DocumentDB/databaseAccounts"
          },
          {
            "field": "Microsoft.DocumentDB/databaseAccounts/disableLocalAuth",
            "notEquals": true
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "roleDefinitionIds": [
            "/providers/Microsoft.Authorization/roleDefinitions/5bd9cd88-fe45-4216-938b-f97437e15450"
          ],
          "conflictEffect": "audit",
          "operations": [
            {
              "condition": "[greaterOrEquals(requestContext().apiVersion, '2021-06-15')]",
              "operation": "addOrReplace",
              "field": "Microsoft.DocumentDB/databaseAccounts/disableLocalAuth",
              "value": true
            }
          ]
        }
      }
  }
POLICY_RULE


  parameters = <<PARAMETERS
 {
    "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "Modify",
          "Disabled"
        ],
        "defaultValue": "Modify"
      }
  }
PARAMETERS

}
