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
    "sa_container_name" = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.azurerm_keyvault.name};SecretName=${azurerm_key_vault_secret.keyvault_secret_container_name.name})",
    "sa_account_name"   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.azurerm_keyvault.name};SecretName=${azurerm_key_vault_secret.keyvault_secret_account_name.name})",
    "sa_sas"            = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.azurerm_keyvault.name};SecretName=${azurerm_key_vault_secret.keyvault_secret_sas.name})",
  }

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}