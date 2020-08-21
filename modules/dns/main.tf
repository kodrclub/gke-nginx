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

  rrdatas = [var.ip]
}