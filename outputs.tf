
output cluster_master_version {value = module.gke.cluster_master_version}
output cluster_node_version   {value = module.gke.cluster_node_version}

# output client_certificate {value = module.gke.client_certificate}
# output client_key {value = module.gke.client_key}
# output cluster_ca_certificate {value = module.gke.cluster_ca_certificate}
        output endpoint {value  = module.gke.endpoint }
        output token {value = module.gke.token }
        output cluster_ca_certificate {value = module.gke.cluster_ca_certificate }

# output public_ips {value = module.ingress.public_ips}
# output ingress_version {value = module.ingress.version}

# output cert_manager_version {value = module.cert_manager.version}

# output name_servers {value = module.dns.name_servers}

