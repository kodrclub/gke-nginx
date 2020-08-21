
output cluster_master_version {value = google_container_cluster.primary.master_version}
output cluster_node_version   {value = google_container_node_pool.primary_nodes.version}