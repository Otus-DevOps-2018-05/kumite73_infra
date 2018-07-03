provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source                     = "../modules/app"
  public_key_path            = "${var.public_key_path}"
  zone                       = "${var.zone}"
  app_disk_image             = "${var.app_disk_image}"
  app_name                   = "reddit-app-prod"
  tags                       = ["reddit-app-prod"]
  reddit_app_ip_name         = "reddit-app-prod-ip"
  firewall_puma_name         = "firefall-puma-prod"
  firewall_puma_source_range = ["77.91.193.61/32"]
  firewall_puma_target_tags  = ["reddit-app-prod"]
}

module "db" {
  source                     = "../modules/db"
  public_key_path            = "${var.public_key_path}"
  zone                       = "${var.zone}"
  db_disk_image              = "${var.db_disk_image}"
  db_name                    = "reddit-db-prod"
  tags                       = ["reddit-db-prod"]
  firewall_mongo_name        = "firefall-mongo-prod"
  firewall_mongo_source_tags = ["reddit-app-prod"]
  firewall_mongo_target_tags = ["reddit-db-prod"]
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["77.91.193.61/32"]
  name_ssh      = "ssh-for-prod"
}
