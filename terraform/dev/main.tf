terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  backend "azurerm" {
    key = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
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
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "mywebapp-maar-dev"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
}

resource "azurerm_app_service_slot" "app_service_slot_dev" {
  name                = "mywebapp-maar-slot-dev"
  app_service_name    = azurerm_app_service.app_service.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
}