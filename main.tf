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






#data "azurerm_client_config" "current" { }

resource "azurerm_cosmosdb_account" "acc" {

  name                      = var.cosmos_db_account_name
  location                  = var.resource_group_location
  resource_group_name       = var.resource_group_name
  offer_type                = "Standard"
  kind                      = "MongoDB"
  enable_automatic_failover = true

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 400
    max_staleness_prefix    = 200000
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }

  geo_location {
    location          = var.resource_group_location
    failover_priority = 0
  }
  
  
  tags = {
    primary = data.azurerm_subscription.primary.id,
     principal_id = data.azurerm_client_config.example.object_id    
  }
}

#data "azurerm_subscription" "primary" {
#}

#data "azurerm_client_config" "example" {
#}

#resource "azurerm_role_assignment" "test" {
 # scope                = data.azurerm_subscription.primary.id
 # role_definition_name = "Resource Policy Contributor"
 # principal_id         = data.azurerm_client_config.example.object_id
#}

resource "azurerm_cosmosdb_mongo_database" "mongodb" {
  name                = "cosmosmongodb"
  resource_group_name = azurerm_cosmosdb_account.acc.resource_group_name
  account_name        = azurerm_cosmosdb_account.acc.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "coll" {
  name                = "cosmosmongodbcollection"
  resource_group_name = azurerm_cosmosdb_account.acc.resource_group_name
  account_name        = azurerm_cosmosdb_account.acc.name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400

  lifecycle {
    ignore_changes = [index]
  }

  depends_on = [azurerm_cosmosdb_mongo_database.mongodb]
}
