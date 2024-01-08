resource "azurerm_storage_account" "resources_storage_account" {
  name                     = "appmaarsaprod"
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
  source                 = "../../src/greeting_prod.png"
}