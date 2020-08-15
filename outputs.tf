
output master_version {value = google_container_cluster.primary.master_version}
output node_version   {value = google_container_node_pool.primary_nodes.version}
