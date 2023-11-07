# Specify your provider and authentication details
provider "azurerm" {
  features {}
}

# Define the resource group where your resources will be created
resource "azurerm_resource_group" "example" {
  name     = "myResourceGroup"
  location = "East US" # Change to your desired location
}

# Define the virtual network
resource "azurerm_virtual_network" "example" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define a subnet within the virtual network
resource "azurerm_subnet" "example" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define a public IP address for the Azure Load Balancer
resource "azurerm_public_ip" "lb" {
  name                = "load-balancer-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Define the Azure Load Balancer
resource "azurerm_lb" "example" {
  name                = "myLoadBalancer"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

# Define the back-end address pool for the Load Balancer
resource "azurerm_lb_backend_address_pool" "example" {
  name                = "myBackendAddressPool"
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
}

# Define the health probe for the Load Balancer
resource "azurerm_lb_probe" "example" {
  name                = "myProbe"
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  protocol            = "TCP"
  port                = 80
}

# Define a network security group to allow incoming traffic
resource "azurerm_network_security_group" "example" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define a rule to allow incoming traffic
resource "azurerm_network_security_rule" "example" {
  name                        = "AllowIncoming"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

# Define the Linux virtual machines
resource "azurerm_linux_virtual_machine" "control_center" {
  name                = "Control_Center"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.control_center.id]
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!" # Replace with your password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name = "controlcenter"
}

resource "azurerm_linux_virtual_machine" "kafka_connect" {
  name                = "Kafka_Connect"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.kafka_connect.id]
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!" # Replace with your password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name = "kafkaconnect"
}

resource "azurerm_linux_virtual_machine" "schema_registry" {
  name                = "Schema_Registry"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.schema_registry.id]
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!" # Replace with your password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name = "schemaregistry"
}

# Define the network interface for each VM
resource "azurerm_network_interface" "control_center" {
  name                = "control-center-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "control-center-ipconfig"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "kafka_connect" {
  name                = "kafka-connect-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "kafka-connect-ipconfig"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "schema_registry" {
  name                = "schema-registry-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "schema-registry-ipconfig"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the load balancer backend address pool association
resource "azurerm_network_interface_backend_address_pool_association" "control_center" {
  network_interface_id    = azurerm_network_interface.control_center.id
  ip_configuration_name   = azurerm_network_interface.control_center.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}

resource "azurerm_network_interface_backend_address_pool_association" "kafka_connect" {
  network_interface_id    = azurerm_network_interface.kafka_connect.id
  ip_configuration_name   = azurerm_network_interface.kafka_connect.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}

resource "azurerm_network_interface_backend_address_pool_association" "schema_registry" {
  network_interface_id    = azurerm_network_interface.schema_registry.id
  ip_configuration_name   = azurerm_network_interface.schema_registry.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}
