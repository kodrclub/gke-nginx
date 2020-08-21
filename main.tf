#
# Providers
#
provider "google" {
  # See https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
  version     = "~> 3.34"
  project     = var.project_id
  region      = var.main_region
  zone        = var.main_zone
}

provider "kubernetes" {
  version = "~> 1.12"
}

provider helm {
  version = "~> 1.2.4"
}



#
# State
#
# terraform {
#   backend "gcs" {
#     bucket  = "my-bucket-name"      #created in bootstrap
#     prefix  = "terraform/state"
#   }
# }



#
# GKE Cluster
module gke {
  source                  = "./modules/gke"
  cluster_location        = var.main_zone
  cluster_name            = var.cluster_name
  cluster_pool_node_count = var.cluster_pool_node_count
  k8s_version_prefix      = var.k8s_version_prefix
}

