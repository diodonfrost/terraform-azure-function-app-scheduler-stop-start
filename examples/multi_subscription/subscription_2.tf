resource "azurerm_resource_group" "subscription_2" {
  provider = azurerm.subscription_2

  name     = "test-sub-2-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_virtual_network" "subscription_2" {
  provider = azurerm.subscription_2

  name                = "test-sub-2-${random_pet.suffix.id}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.subscription_2.location
  resource_group_name = azurerm_resource_group.subscription_2.name
}

resource "azurerm_subnet" "subscription_2" {
  provider = azurerm.subscription_2

  name                 = "test-sub-2-${random_pet.suffix.id}"
  resource_group_name  = azurerm_resource_group.subscription_2.name
  virtual_network_name = azurerm_virtual_network.subscription_2.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "subscription_2" {
  provider = azurerm.subscription_2

  name                = "test-to-stop-sub-2-${random_pet.suffix.id}"
  location            = azurerm_resource_group.subscription_2.location
  resource_group_name = azurerm_resource_group.subscription_2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subscription_2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "subscription_2" {
  provider = azurerm.subscription_2

  name                = "test-to-stop-sub-2-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.subscription_2.name
  location            = azurerm_resource_group.subscription_2.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.subscription_2.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.test.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    tostop = "true"
  }
}
