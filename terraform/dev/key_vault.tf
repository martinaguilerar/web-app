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

resource "azurerm_key_vault_access_policy" "azurerm_access_policy" {
  key_vault_id = azurerm_key_vault.azurerm_keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  object_id = azurerm_linux_web_app_slot.app_service_slot_dev.identity.0.principal_id

  secret_permissions = [
    "Get",
  ]
}