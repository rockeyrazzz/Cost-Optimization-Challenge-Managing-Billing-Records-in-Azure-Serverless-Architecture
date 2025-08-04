# File: storage.tf
resource "azurerm_storage_account" "archive" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "billing" {
  name                  = "billing-records"
  storage_account_name  = azurerm_storage_account.archive.name
  container_access_type = "private"
}
