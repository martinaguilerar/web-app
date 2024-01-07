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

resource "azurerm_service_plan" "azurerm_service_plan" {
  name                = "myappservice-plan-dev"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "azurerm_linux_webapp" {
  name                = "mywebapp-maar-dev"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_service_plan.azurerm_service_plan.location
  service_plan_id     = azurerm_service_plan.azurerm_service_plan.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "app_service_slot_dev" {
  name           = "dev"
  app_service_id = azurerm_linux_web_app.azurerm_linux_webapp.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}

resource "azurerm_storage_account" "resources_storage_account" {
  name                     = "webappmaarsadev"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "mywebappimages" {
  name                  = "mywebappimages"
  storage_account_name  = azurerm_storage_account.resources_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "greeting" {
  name                   = "greeting.png"
  storage_account_name   = azurerm_storage_account.resources_storage_account.name
  storage_container_name = azurerm_storage_container.mywebappimages.name
  type                   = "Block"
  source                 = "../../src/greeting.png"
}