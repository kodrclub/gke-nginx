
output cluster_master_version {value = google_container_cluster.kubernetes.master_version}
output cluster_node_version   {value = google_container_node_pool.kubernetes_nodes.version}

output client_certificate {
  value       = base64decode(join(",", google_container_cluster.kubernetes[*].master_auth[0].client_certificate))
  sensitive   = true
}

output client_key {
  value       = base64decode(join(",", google_container_cluster.kubernetes[*].master_auth[0].client_key))
  sensitive   = true
}

output cluster_ca_certificate {
  value       = base64decode(join(",", google_container_cluster.kubernetes[*].master_auth[0].cluster_ca_certificate))
  sensitive   = true
}