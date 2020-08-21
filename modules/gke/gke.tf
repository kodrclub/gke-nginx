#
data "google_container_engine_versions" "primary" {
  version_prefix = var.k8s_version_prefix
}

# --no-enable-autoupgrade \
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.cluster_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count  = 1

  min_master_version  = data.google_container_engine_versions.primary.latest_node_version
}

resource "google_container_node_pool" "primary_nodes" {
  name_prefix = var.cluster_name
  location    = var.cluster_location
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




