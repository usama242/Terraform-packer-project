provider "azurerm" {
  features {}
}

# Get the custom packer image
data "azurerm_image" "udacity-image" {
  name                = "packer-image"
  resource_group_name = var.resource_group
}

# Get the resource group
data "azurerm_resource_group" "udacity-rg" {
  name = var.resource_group
}
# Create a virtual network
resource "azurerm_virtual_network" "udacity-vnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = data.azurerm_resource_group.udacity-rg.location
  resource_group_name = data.azurerm_resource_group.udacity-rg.name

  tags = { Name : "udacityproject1" }
}

# Create a subnet
resource "azurerm_subnet" "udacity-subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.udacity-rg.name
  virtual_network_name = azurerm_virtual_network.udacity-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "udacity-nsg" {
  name                = "${var.prefix}-nsg"
  location            = data.azurerm_resource_group.udacity-rg.location
  resource_group_name = data.azurerm_resource_group.udacity-rg.name

  tags = { Name : "udacityproject1" }
}

# Create security rules
resource "azurerm_network_security_rule" "udacity-deny-all" {
  name                        = "${var.prefix}-deny-all"
  description                 = "This rule denies all the inbound traffic."
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.udacity-rg.name
  network_security_group_name = azurerm_network_security_group.udacity-nsg.name
}

resource "azurerm_network_security_rule" "udacity-allow-internal-inbound" {
  name                        = "${var.prefix}-allow-internal-inbound"
  description                 = "This rule allows the inbound traffic within same virtual network."
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.udacity-rg.name
  network_security_group_name = azurerm_network_security_group.udacity-nsg.name
}

resource "azurerm_network_security_rule" "udacity-allow-internal-outbound" {
  name                        = "${var.prefix}-allow-internal-outbound"
  description                 = "This rule allows the outbound traffic within same virtual network."
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.udacity-rg.name
  network_security_group_name = azurerm_network_security_group.udacity-nsg.name
}

# Create network interface
resource "azurerm_network_interface" "udacity-nic" {
  count = var.no_vms
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = data.azurerm_resource_group.udacity-rg.name
  location            = data.azurerm_resource_group.udacity-rg.location

  ip_configuration {
    name                          = "${var.prefix}-ip"
    subnet_id                     = azurerm_subnet.udacity-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = { Name : "udacityproject1" }
}

# Create public IP
resource "azurerm_public_ip" "udacity-public-ip" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = data.azurerm_resource_group.udacity-rg.name
  location            = data.azurerm_resource_group.udacity-rg.location
  allocation_method   = "Static"

  tags = { Name : "udacityproject1" }
}

# Create load balancer
resource "azurerm_lb" "udacity-lb" {
  name                = "${var.prefix}-lb"
  location            = data.azurerm_resource_group.udacity-rg.location
  resource_group_name = data.azurerm_resource_group.udacity-rg.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-frontend-ip"
    public_ip_address_id = azurerm_public_ip.udacity-public-ip.id
  }

  tags = { Name : "udacityproject1" }
}

# Add a rule to the load balancer
resource "azurerm_lb_rule" "udacity-lb-rule" {
  name                 = "${var.prefix}-lb-rule"
  load_distribution    = "Default"
  frontend_port        = 80
  backend_port         = 80
  protocol             = "Tcp"
  loadbalancer_id     = azurerm_lb.udacity-lb.id
  frontend_ip_configuration_name = azurerm_lb.udacity-lb.frontend_ip_configuration[0].name
}

# The load balancer will use this backend pool
resource "azurerm_lb_backend_address_pool" "udacity-backend-pool" {
  loadbalancer_id = azurerm_lb.udacity-lb.id
  name            = "${var.prefix}-backend-pool"
}

# We associate the LB with the backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "udacity-backend-pool-association" {
  count = var.no_vms
  network_interface_id    = azurerm_network_interface.udacity-nic[count.index].id
  ip_configuration_name   = "${var.prefix}-ip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.udacity-backend-pool.id
}

# Create virtual machine availability set
resource "azurerm_availability_set" "udacity-availability-set" {
  name                = "${var.prefix}-availability-set"
  location            = data.azurerm_resource_group.udacity-rg.location
  resource_group_name = data.azurerm_resource_group.udacity-rg.name

  tags = { Name : "udacityproject1" }
}

# Create the virtual machines
resource "azurerm_linux_virtual_machine" "udacity-vm" {
  count                           = var.no_vms
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = data.azurerm_resource_group.udacity-rg.name
  location                        = data.azurerm_resource_group.udacity-rg.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids           = [element(azurerm_network_interface.udacity-nic.*.id, count.index)]
  availability_set_id             = azurerm_availability_set.udacity-availability-set.id

  source_image_id = data.azurerm_image.udacity-image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }


  tags = { Name : "udacityproject1" }
}