
output master_version {value = google_container_cluster.primary.master_version}
output node_version   {value = google_container_node_pool.primary_nodes.version}
output public_ip {
  value = data.kubernetes_service.lb.load_balancer_ingress[0].ip
}
output len {
  value =length(data.kubernetes_service.lb.load_balancer_ingress)
}
