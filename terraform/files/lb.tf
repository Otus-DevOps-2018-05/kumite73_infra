resource "google_compute_http_health_check" "health-check" {
  name = "health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  port = "9292"
}

resource "google_compute_target_pool" "target-pool" {
  name = "target-pool"

  instances     = ["${google_compute_instance.app.*.self_link}"]
  health_checks = ["${google_compute_http_health_check.health-check.name}"]
}

resource "google_compute_forwarding_rule" "forwarding-rule" {
  name = "forwarding-rule"

  target     = "${google_compute_target_pool.target-pool.self_link}"
  port_range = "9292"
}
