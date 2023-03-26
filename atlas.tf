#################################################################
#          Terraform file depends on variables.tf               #
#################################################################

#################################################################
#          Terraform file depends on locals.tf                  #
#################################################################

# Some remaining variables are still hardcoded, such Atlas shape
# details. There are only used once, and most likely they are
# not required to change

#################################################################
##################### MONGODB ATLAS SECTION #####################
#################################################################

provider "mongodbatlas" {
  # variable are provided via ENV
  # public_key = ""
  # private_key  = ""
}

resource "mongodbatlas_privatelink_endpoint" "test1" {
  project_id    = local.atlas_org_id
  provider_name = local.provider_name
  region        = "eastus"
}

resource "mongodbatlas_privatelink_endpoint" "test2" {
  project_id    = local.atlas_org_id
  provider_name = local.provider_name
  region        = "eastus2"
}

resource "mongodbatlas_privatelink_endpoint" "test3" {
  project_id    = local.atlas_org_id
  provider_name = local.provider_name
  region        = "westus"
}

resource "mongodbatlas_privatelink_endpoint_service" "test1" {
  project_id            = mongodbatlas_privatelink_endpoint.test1.project_id
  private_link_id       = mongodbatlas_privatelink_endpoint.test1.private_link_id
  endpoint_service_id   = azurerm_private_endpoint.atlas-pe-group1.id
  private_endpoint_ip_address = azurerm_private_endpoint.atlas-pe-group1.private_service_connection.0.private_ip_address
  provider_name = local.provider_name
}
resource "mongodbatlas_privatelink_endpoint_service" "test2" {
  project_id            = mongodbatlas_privatelink_endpoint.test2.project_id
  private_link_id       = mongodbatlas_privatelink_endpoint.test2.private_link_id
  endpoint_service_id   = azurerm_private_endpoint.atlas-pe-group2.id
  private_endpoint_ip_address = azurerm_private_endpoint.atlas-pe-group2.private_service_connection.0.private_ip_address
  provider_name = local.provider_name
}
resource "mongodbatlas_privatelink_endpoint_service" "test3" {
  project_id            = mongodbatlas_privatelink_endpoint.test3.project_id
  private_link_id       = mongodbatlas_privatelink_endpoint.test3.private_link_id
  endpoint_service_id   = azurerm_private_endpoint.atlas-pe-group3.id
  private_endpoint_ip_address = azurerm_private_endpoint.atlas-pe-group3.private_service_connection.0.private_ip_address
  provider_name = local.provider_name
}


resource "mongodbatlas_advanced_cluster" "this" {
  name                  = local.cluster_name
  project_id            = local.atlas_org_id
  cluster_type          = "REPLICASET"
  backup_enabled        = false
  version_release_system = "CONTINUOUS"

  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 2
      }
      provider_name = "AZURE"
      priority      = 7
      region_name   = "US_EAST"
    }
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 2
      }
      provider_name = "AZURE"
      priority      = 6
      region_name   = "US_EAST_2"
    }
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 1
      }
      provider_name = "AZURE"
      priority      = 5
      region_name   = "US_WEST"
    }
  }

  labels {
        key   = "Owner"
        value = local.atlas_org_id
  }
  labels {
        key   = "date"
        value = "${timestamp()}"
  }

  # Label "date" has always a different value, one can prevent updates with lifecycle
  lifecycle { ignore_changes = [labels] }

}


output "atlasclusterstring" {
   value = mongodbatlas_advanced_cluster.this.connection_strings[0].private_endpoint[0].srv_connection_string
}

# DATABASE USER
resource "mongodbatlas_database_user" "user1" {
  username           = local.admin_username
  password           = var.admin_password
  project_id         = local.atlas_org_id
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
  labels {
    key   = "Name"
    value = local.admin_username
  }

  labels {
        key   = "date"
        value = "${timestamp()}"
  }

  # Label "date" has always a different value, one can prevent updates with lifecycle
  lifecycle { ignore_changes = [labels] }

  scopes {
    name = mongodbatlas_advanced_cluster.this.name
    type = "CLUSTER"
  }
}

output "user1" {
  value = mongodbatlas_database_user.user1.username
}
