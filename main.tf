# Set the Azure Provider source and version being used
#terraform {
 # required_version = ">= 0.14"

  #required_providers {
   # azurerm = {
    #  source  = "hashicorp/azurerm"
     # version = "~> 3.1.0"
    #}
  #}
#}

# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
}

data "azurerm_cosmosdb_account" "example" {
  name                = "tfex-cosmosdb-account1"
  resource_group_name = "tfex-cosmosdb-account-rg"
}

resource "azurerm_cosmosdb_mongo_database" "example" {
  name                = "tfex-cosmos-mongo-db"
  resource_group_name = data.azurerm_cosmosdb_account.example.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.example.name
  throughput          = 400
}
