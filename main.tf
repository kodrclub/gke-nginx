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

provider helm {}



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
data "google_container_engine_versions" "primary" {
  version_prefix = var.k8s_version_prefix
}
# --no-enable-autoupgrade \
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.main_zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count  = 1

  min_master_version  = data.google_container_engine_versions.primary.latest_node_version
}
resource "google_container_node_pool" "primary_nodes" {
  name_prefix = var.cluster_name
  location    = var.main_zone
  cluster     = google_container_cluster.primary.name
  node_count  = var.cluster_pool_node_count
  version     = data.google_container_engine_versions.primary.latest_node_version

  management {
    auto_upgrade = false
  }

  node_config {
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}




#
# Helm ingress
#
resource kubernetes_namespace ingressns{
  metadata{
    name = "ingress-nginx"
  }
}
resource helm_release ingressk {
  name = "foo"
  repository ="https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version      = ""
  force_update = true
  cleanup_on_fail = true
  namespace = "ingress-nginx"
}


#
# Obtain ingress address
#
data "kubernetes_service" "lb" {
  metadata {
    name = "foo-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.ingressk]
}




#
# DNS
#
resource "google_dns_managed_zone" "primary" {
  name        = var.dns_zone_name
  dns_name    = "${var.domain_name}."
  description = "DNS zone for K8s cluster ingress"
}

resource "google_dns_record_set" "public" {
  name = google_dns_managed_zone.primary.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.primary.name

  rrdatas = [data.kubernetes_service.lb.load_balancer_ingress[0].ip]
}








///////////////////////////////////////////
# locals {
#   subnet_ids = toset([
#     "subnet-abcdef",
#     "ingress-nginx-controller",
#     "subnet-012345",
#   ])
# }
# data "kubernetes_service" "xxx" {
#   for_each = local.subnet_ids

#   metadata {
#     name = each.key
#     namespace = "ingress-nginx"
#   }
# }
# output foo {
#   value = data.kubernetes_service.xxx
# }

# resource "google_dns_record_set" "xxx" {
#   depends_on = [data.kubernetes_service.xxx]
#   name = "xxx.${google_dns_managed_zone.primary.dns_name}"
#   type = "A"
#   ttl  = 300

#   managed_zone = google_dns_managed_zone.primary.name

#   rrdatas = [data.kubernetes_service.xxx.load_balancer_ingress[0].ip]
#   count = data.kubernetes_service.xxx.load_balancer_ingress[0] ? 1 : 0
# }

# data "kubernetes_service" "hello" {
#   metadata {
#     name = "hello-srv"
#   }
# }

# output helloIP {
#   value = data.kubernetes_service.hello.spec[0].cluster_ip
# }



