# Setup SQL server:
resource "azurerm_mssql_server" "fj1sqlserver" {
  name                         = "fj1sqlserver-${random_string.random_storage_account.result}"
  resource_group_name          = azurerm_resource_group.framework_rg.name
  location                     = azurerm_resource_group.framework_rg.location
  version                      = "12.0"
  # Hard code user
  administrator_login          = "junior_admin"
  # Hard code password
  administrator_login_password = "${random_string.random_password.result}"
  minimum_tls_version          = "1.2"
  public_network_access_enabled = true
  outbound_network_restriction_enabled = false
  tags = {
    environment = "dev"
  }
}


# FIREWALL RULES:
# Add firewall rule to allow connection from Azure services:
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id       = azurerm_mssql_server.fj1sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
# Add firewall rule to allow connection from personal ip address:
data "http" "my_ip" {
# This will dynamically grab the users IP address.
  url = "https://api.ipify.org"
}
# Create firewall rule with the individuals ip address:
resource "azurerm_mssql_firewall_rule" "allow_my_ip" {
  name             = "AllowMyIP"
  server_id        = azurerm_mssql_server.fj1sqlserver.id
  start_ip_address = data.http.my_ip.response_body
  end_ip_address   = data.http.my_ip.response_body
}

# Setup Totesys database:
resource "azurerm_mssql_database" "fj1_database_totesys" {
  name         = "fj1-totesys-uks"
  server_id    = azurerm_mssql_server.fj1sqlserver.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 1
  sku_name     = "S0"
  
  # Allow database to be destroyed
  lifecycle {
    prevent_destroy = false
  }
}

# Setup Metadata database:
resource "azurerm_mssql_database" "fj1_database_metadata" {
  name         = "fj1-metadata-uks"
  server_id    = azurerm_mssql_server.fj1sqlserver.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 1
  sku_name     = "S0"
  
  # Allow database to be destroyed
  lifecycle {
    prevent_destroy = false
  }
}