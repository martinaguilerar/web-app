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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "resource_group" {
  name     = "app-service-rg"
  location = "East US"
}

resource "azurerm_key_vault" "azurerm_keyvault" {
  name                            = "mywebappmaarkvdev"
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set"
    ]
  }
}

resource "azurerm_key_vault_secret" "keyvault_secret_container_name" {
  name         = "containerName"
  value        = ""
  key_vault_id = azurerm_key_vault.azurerm_keyvault.id
  lifecycle {
    ignore_changes = [value, version]
  }
}

resource "azurerm_key_vault_secret" "keyvault_secret_account_name" {
  name         = "accountName"
  value        = ""
  key_vault_id = azurerm_key_vault.azurerm_keyvault.id
  lifecycle {
    ignore_changes = [value, version]
  }
}

resource "azurerm_key_vault_secret" "keyvault_secret_sas" {
  name         = "sas"
  value        = ""
  key_vault_id = azurerm_key_vault.azurerm_keyvault.id
  lifecycle {
    ignore_changes = [value, version]
  }
}

resource "azurerm_service_plan" "azurerm_service_plan" {
  name                = "myappservice-plan"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "azurerm_linux_webapp" {
  name                = "mywebapp-maar"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_service_plan.azurerm_service_plan.location
  service_plan_id     = azurerm_service_plan.azurerm_service_plan.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "app_service_slot_dev" {
  name           = "dev"
  app_service_id = azurerm_linux_web_app.azurerm_linux_webapp.id
  identity {
      type = "SystemAssigned"
  }

  app_settings = {
    "sa_container_name"  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.keyvault_secret_container_name.versionless_id})",
    "sa_account_name"  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.keyvault_secret_account_name.versionless_id})",
    "sa_sas" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.keyvault_secret_sas.versionless_id})"
  }

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}

resource "azurerm_key_vault_access_policy" "azurerm_access_policy" {
  key_vault_id = azurerm_key_vault.azurerm_keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  object_id = azurerm_linux_web_app_slot.app_service_slot_dev.identity.0.principal_id

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_storage_account" "resources_storage_account" {
  name                     = "appmaarsadev"
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