terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "app-service-rg-dev"
  location = "East US"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "myappservice-plan-dev"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "mywebapp-maar-dev"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  #(Optional)
  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  #(Optional)
  app_settings = {
    "SOME_KEY" = "some-value"
  }

}
