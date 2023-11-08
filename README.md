# terraform
https://github.com/vrk4opportunities/terra-demo-vm

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "myResourceGroup"
  location = "East US"  # Adjust the location as needed
}

resource "azurerm_linux_virtual_machine" "example" {
  name                  = "my-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  size                  = "Standard_DS2_v2"  # Adjust the VM size as needed
  admin_username        = "adminuser"
  admin_password        = "Password12345!"  # Replace with your own strong password
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"  # Adjust the OS version as needed
    version   = "latest"
  }
}


