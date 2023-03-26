#################################################################
#          Terraform file depends on variables.tf               #
#################################################################

#################################################################
#          Terraform file depends on locals.tf                  #
#################################################################

# Some remaining variables are still hardcoded. Such virtual
# machine details. There are only used once, and most likely they
# are not required to change


#################################################################
#################### MICROSOFT AZURE SECTION ####################
#################################################################
provider "azurerm" {
  subscription_id = local.azure_subscription_id
  client_id       = local.azure_client_id
  client_secret   = local.azure_client_secret
  tenant_id       = local.azure_tenant_id
  features {
  }
}

# Create a resource group
resource "azurerm_resource_group" "atlas-group1" {
    name     = local.resource_group_name1
    location = local.location1

    tags = {
        environment = "Atlas Demo - 1"
    }
}
resource "azurerm_resource_group" "atlas-group2" {
    name     = local.resource_group_name2
    location = local.location2

    tags = {
        environment = "Atlas Demo - 2"
    }
}
resource "azurerm_resource_group" "atlas-group3" {
    name     = local.resource_group_name3
    location = local.location3

    tags = {
        environment = "Atlas Demo - 3"
    }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "atlas-vn-group1" {
    name                = local.vnet_name1
    resource_group_name = azurerm_resource_group.atlas-group1.name
    location            = local.location1
    address_space       = local.address_space1

    tags = {
        environment = "Atlas Demo - 1"
    }
}
resource "azurerm_virtual_network" "atlas-vn-group2" {
    name                = local.vnet_name2
    resource_group_name = azurerm_resource_group.atlas-group2.name
    location            = local.location2
    address_space       = local.address_space2

    tags = {
        environment = "Atlas Demo - 2"
    }
}
resource "azurerm_virtual_network" "atlas-vn-group3" {
    name                = local.vnet_name3
    resource_group_name = azurerm_resource_group.atlas-group3.name
    location            = local.location3
    address_space       = local.address_space3

    tags = {
        environment = "Atlas Demo - 3"
    }
}

# Create a subnet in virtual network,
resource "azurerm_subnet" "atlas-subnet-group1" {
    name                 = local.subnet1
    address_prefixes     = [local.subnet_address_space1]
    resource_group_name  = azurerm_resource_group.atlas-group1.name
    virtual_network_name = azurerm_virtual_network.atlas-vn-group1.name

    enforce_private_link_service_network_policies = true
    enforce_private_link_endpoint_network_policies = true
}
# Create a subnet in virtual network,
resource "azurerm_subnet" "atlas-subnet-group2" {
    name                 = local.subnet2
    address_prefixes     = [local.subnet_address_space2]
    resource_group_name  = azurerm_resource_group.atlas-group2.name
    virtual_network_name = azurerm_virtual_network.atlas-vn-group2.name

    enforce_private_link_service_network_policies = true
    enforce_private_link_endpoint_network_policies = true
}
# Create a subnet in virtual network,
resource "azurerm_subnet" "atlas-subnet-group3" {
    name                 = local.subnet3
    address_prefixes     = [local.subnet_address_space3]
    resource_group_name  = azurerm_resource_group.atlas-group3.name
    virtual_network_name = azurerm_virtual_network.atlas-vn-group3.name

    enforce_private_link_service_network_policies = true
    enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "atlas-pe-group1" {
  name                = "endpoint-atlas1"
  location            = local.location1
  resource_group_name = azurerm_resource_group.atlas-group1.name
  subnet_id           = azurerm_subnet.atlas-subnet-group1.id
  private_service_connection {
    name                           = mongodbatlas_privatelink_endpoint.test1.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.test1.private_link_service_resource_id

    is_manual_connection           = true
    request_message = "Azure Private Link test 1"
  }

}
resource "azurerm_private_endpoint" "atlas-pe-group2" {
  name                = "endpoint-atlas2"
  location            = local.location2
  resource_group_name = azurerm_resource_group.atlas-group2.name
  subnet_id           = azurerm_subnet.atlas-subnet-group2.id
  private_service_connection {
    name                           = mongodbatlas_privatelink_endpoint.test2.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.test2.private_link_service_resource_id

    is_manual_connection           = true
    request_message = "Azure Private Link test 2"
  }

}
resource "azurerm_private_endpoint" "atlas-pe-group3" {
  name                = "endpoint-atlas3"
  location            = local.location3
  resource_group_name = azurerm_resource_group.atlas-group3.name
  subnet_id           = azurerm_subnet.atlas-subnet-group3.id
  private_service_connection {
    name                           = mongodbatlas_privatelink_endpoint.test3.private_link_service_name
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.test3.private_link_service_resource_id

    is_manual_connection           = true
    request_message = "Azure Private Link test 3"
  }

}



resource "azurerm_virtual_network_peering" "example-transitive-peering1" {
  name                      = "peer2to3"
  resource_group_name       = azurerm_resource_group.atlas-group2.name
  virtual_network_name      = azurerm_virtual_network.atlas-vn-group2.name
  remote_virtual_network_id = azurerm_virtual_network.atlas-vn-group3.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = false
}
resource "azurerm_virtual_network_peering" "example-transitive-peering2" {
  name                      = "peer3to2"
  resource_group_name       = azurerm_resource_group.atlas-group3.name
  virtual_network_name      = azurerm_virtual_network.atlas-vn-group3.name
  remote_virtual_network_id = azurerm_virtual_network.atlas-vn-group2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "example-transitive-peering3" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.atlas-group1.name
  virtual_network_name      = azurerm_virtual_network.atlas-vn-group1.name
  remote_virtual_network_id = azurerm_virtual_network.atlas-vn-group2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "example-transitive-peering4" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.atlas-group2.name
  virtual_network_name      = azurerm_virtual_network.atlas-vn-group2.name
  remote_virtual_network_id = azurerm_virtual_network.atlas-vn-group1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = false
}






# This part needs to be multi-region too

resource "azurerm_public_ip" "demo-vm-ip" {
    name                         = "myPublicIP"
    # Looks like changed in azurerm
    location                     = local.location1
    resource_group_name          = azurerm_resource_group.atlas-group1.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Atlas Demo - 1"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "demo-vm-nsg" {
    name                = "myAtlasDemo"
    # Looks like changed in azurerm

    location            = local.location1
    resource_group_name = azurerm_resource_group.atlas-group1.name

    # Allow inbound SSH traffic
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = var.source_ip
        destination_address_prefix = "*"
    }

    tags = {
        environment                = "Atlas Demo - 1"
    }
}

# Create network interface
resource "azurerm_network_interface" "demo-vm-nic" {
    name                      = "myNIC"
    location                  = azurerm_network_security_group.demo-vm-nsg.location
    resource_group_name       = azurerm_resource_group.atlas-group1.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.atlas-subnet-group1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.demo-vm-ip.id
    }

    tags = {
        environment = "Atlas Demo - 1"
    }

    # depends_on = [ azurerm_network_interface.demo-vm-nic ]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "demo-vm" {
    network_interface_id      = azurerm_network_interface.demo-vm-nic.id
    network_security_group_id = azurerm_network_security_group.demo-vm-nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "demo-vm" {
   name                  = local.azure_vm_name
   location              = local.location1
   resource_group_name   = azurerm_resource_group.atlas-group1.name
   size                  = local.azure_vm_size
   admin_username        = local.admin_username
   admin_password        = var.admin_password
   network_interface_ids = [
	azurerm_network_interface.demo-vm-nic.id,
   ]

   admin_ssh_key {
       username   = local.admin_username
       public_key = file("~/.ssh/id_rsa.pub")
   }

   os_disk {
       caching              = "ReadWrite"
       storage_account_type = "Standard_LRS"
   }

   source_image_reference {
       publisher         = "Canonical"
       offer             = "UbuntuServer"
       sku               = "18.04-LTS"
       version           = "latest"
   }

   tags = {
       environment       = "Demo"
   }

   connection {
       disable_password_authentication = true
       type 				= "ssh"
       host 				= self.public_ip_address
       user 				= self.admin_username
       password 			= self.admin_password
       agent 				= true
       private_key 			= file("~/.ssh/id_rsa")
   }

   provisioner "remote-exec" {

       connection {
           host = self.public_ip_address
           user = self.admin_username
           password = self.admin_password
       }

       # Below, we unstall some common tools, including mongo client shell
       inline = [
       "sleep 10",
       "sudo apt-get -y update",
       "sudo apt-get -y install python3-pip",
       "sudo apt-get -y update",
       "sudo pip3 install pymongo==4.0.1",
       "sudo pip3 install faker",
       "sudo pip3 install dnspython",

       "wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -",
       "echo 'deb [ arch=amd64 ] http://repo.mongodb.com/apt/ubuntu bionic/mongodb-enterprise/6.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-enterprise.list",
       "sudo apt-get update",
	     "sudo apt-get install -y mongodb-enterprise-shell mongodb-mongosh",
       "sudo rm -f /etc/resolv.conf ; sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf"
       ]
   }
}

output "public_ip_address" {
  description = "Public IP of azure VM - 1"
  value       = azurerm_linux_virtual_machine.demo-vm.*.public_ip_address
}
