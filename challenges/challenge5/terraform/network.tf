resource "azurerm_public_ip" "gateway" {
  name                = "gateway"
  resource_group_name = data.azurerm_resource_group.participant.name
  location            = data.azurerm_resource_group.participant.location
  allocation_method   = "Static"
}