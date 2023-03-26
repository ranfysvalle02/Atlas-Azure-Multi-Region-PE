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
  # A Azure resource group
  resource_group_name1   = "atlas-demo-link1"
  resource_group_name2   = "atlas-demo-link2"
  resource_group_name3   = "atlas-demo-link3"
  # Associated Azure vnet
  vnet_name1             = "atlas-link-vnet1"
  vnet_name2             = "atlas-link-vnet2"
  vnet_name3             = "atlas-link-vnet3"
  # Azure location
  location1              = "East US"
  # Azure location
  location2              = "East US 2"
  # Azure location
  location3              = "West US"
  # Azure cidr block for vnet
  address_space1         = ["10.12.4.0/23"]
  address_space2         = ["10.1.0.0/23"]
  address_space3         = ["10.2.0.0/23"]
  # Azure subnet in vnet
  subnet1                = "sn1"
  subnet2                = "sn2"
  subnet3                = "sn3"
  # Azure subnet cidr
  subnet_address_space1  = "10.12.4.192/26"
  subnet_address_space2  = "10.1.0.192/26"
  subnet_address_space3  = "10.2.0.192/26"
  # Azure vm admin_user
  admin_username        = "testuser"
  # Azure vm size
  azure_vm_size		      = "Standard_F2"
  # Azure vm_name
  azure_vm_name		      = "demo-link"
}
