# High Availability + Azure PrivateLink + Multi-Region(Atlas)
![alt text](https://application-4-gql-predemo-lsfrk.mongodbstitch.com/pe-unsharded.png "Title")

## Requirements
- Terraform 0.12+

## Prerequisites
-
       private_key 			= file("~/.ssh/id_rsa")
- Existing [Atlas Organization](https://docs.atlas.mongodb.com/tutorial/create-atlas-account/#create-an-service-organization-and-project) with:
  - Existing [Atlas Project](https://docs.atlas.mongodb.com/tutorial/manage-projects/#create-a-project) with:
    - Existing [Project API Key](https://docs.atlas.mongodb.com/configure-api-access/#manage-programmatic-access-to-one-project) with Project Owner permissions
- Existing Azure subscription
```
locals {
  # Atlas cluster name
  cluster_name		      = "Sample"
  # Atlas Setup Stuff
  atlas_org_id = "YOUR_ORG_ID"
  # Atlas Public providor
  provider_name         = "AZURE"
  # Azure Subscription ID
  azure_subscription_id = "SUBSCRIPTION_ID_GOES_HERE"
  azure_client_id = "AZ_CLIENT_ID_GOES_HERE"
  azure_client_secret = "AZ_CLIENT_SECRET_GOES_HERE"
  azure_tenant_id = "AZ_TENANT_ID_GOES_HERE"
```

# What are Private Endpoints?
How exactly do Private Endpoints work for Network Access to MongoDB Atlas?
![alt text](https://application-4-gql-predemo-lsfrk.mongodbstitch.com/1.png "Title")

## Transitive Peering
Transitive peering is how we solve for high availability on a Multi-Region cluster.

## What is Peer-to-Peer Transitive Routing?
In Azure, peer-to-peer transitive routing describes network traffic between two virtual networks that is routed through an intermediate virtual network. For example, assume there are three virtual networks - A, B, and C. A is peered to B, B is peered to C, but A and C are not connected.

![alt text](https://application-4-gql-predemo-lsfrk.mongodbstitch.com/2.png "Title")

## PrivateLink + Multi-Region Replicaset Limitations (UNSHARDED)
![alt text](https://application-4-gql-predemo-lsfrk.mongodbstitch.com/3.png "Title")

```

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
```



## PrivateLink + Multiple Regionalized Endpoints (SHARDED)
This particular setup is not included in the Terraform script but provided here for educational purposes
![alt text](https://application-4-gql-predemo-lsfrk.mongodbstitch.com/4.png "Title")



# Test Resiliency
The Atlas UI let's you test a full region outage right from the UI!
# Start Full Region Outage
![alt text](https://application-4-gql-predemo-lsfrk.mongodbstitch.com/outage.png "Title")

# What happens if we don't set up transitive peering?
The application will not be able to connect to the primary! It needs to route traffic through VPC peering on the Azure side to the region with the primary node!
![alt text](https://application-4-gql-predemo-lsfrk.mongodbstitch.com/outage2.png "Title")

# Now for the good stuff. Let's see some code in action!

` export MONGODB_ATLAS_PUBLIC_KEY=yourkeyhere `
` export MONGODB_ATLAS_PRIVATE_KEY=yourkeyhere `
` update locals.tf with your values `

# Terraform
- ` terraform init `
- `terraform apply `

# Once terraform finishes doing its magic, all you gotta do is ssh into your VM and login using mongosh
- ` ssh testuser@Public IP of azure VM`
- ` mongosh <PrivateLinkConnectionString> --username testuser` (with password "helloworld")
