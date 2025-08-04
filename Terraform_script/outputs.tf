# File: outputs.tf
output "function_app_url" {
  value = azurerm_linux_function_app.archive_fn.default_hostname
}

output "blob_container_url" {
  value = "https://${azurerm_storage_account.archive.name}.blob.core.windows.net/${azurerm_storage_container.billing.name}"
}
