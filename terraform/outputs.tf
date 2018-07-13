output "app_external_ip" {
  value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "forwarding_rule_ip" {
  value = "${google_compute_forwarding_rule.forwarding-rule.ip_address}"
}
