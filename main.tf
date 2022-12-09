resource "azurerm_resource_group" "main" {
  name     = "example-resources"
  location = "westeurope"
}

module "service_bus" {
  source = "innovationnorway/service-bus/azurerm"

  name = "example"

  resource_group_name = azurerm_resource_group.main.name

  topics = [
    {
      name = "example"
      enable_partitioning = true
      authorization_rules = [
        {
          name   = "example"
          rights = ["listen", "send"]
        }
      ]
    }
  ]
}
