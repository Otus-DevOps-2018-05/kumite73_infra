resource "google_compute_instance" "db" {
  name         = "${var.db_name}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = "${var.tags}"

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "${var.firewall_mongo_name}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  # правило применимо к инстансам с тегом ...
  target_tags = "${var.firewall_mongo_target_tags}"

  # порт будет доступен только для инстансов с тегом ...
  source_tags = "${var.firewall_mongo_source_tags}"
}
