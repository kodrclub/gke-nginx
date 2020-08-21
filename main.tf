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
  client_certificate     = module.gke.client_certificate
  client_key             = module.gke.client_key
  cluster_ca_certificate = module.gke.cluster_ca_certificate
}

provider helm {
  version = "~> 1.2.4"
  kubernetes {
    client_certificate     = module.gke.client_certificate
    client_key             = module.gke.client_key
    cluster_ca_certificate = module.gke.cluster_ca_certificate
  }
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
#
module gke {
  source                  = "./modules/gke"
  cluster_location        = var.main_zone
  cluster_name            = var.cluster_name
  cluster_pool_node_count = var.cluster_pool_node_count
  k8s_version_prefix      = var.k8s_version_prefix
}



#
# Ingress-nginx
#
module ingress {
  source          = "./modules/k8s-ingress"
  ingress_name    = var.cluster_name
  ingress_version = var.ingress_version
}



#
# cert-manager
#
module cert_manager {
  source               = "./modules/k8s-cert-manager"
  cert_manager_version = var.cert_manager_version
}



