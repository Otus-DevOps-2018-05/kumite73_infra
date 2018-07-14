output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

#output "forwarding_rule_ip" {
#  value = "${google_compute_forwarding_rule.forwarding-rule.ip_address}"
#}

