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
  app_name                   = "reddit-app-stage"
  tags                       = ["reddit-app-stage"]
  reddit_app_ip_name         = "reddit-app-stage-ip"
  firewall_puma_name         = "firefall-puma-stage"
  firewall_puma_source_range = ["0.0.0.0/0"]
  firewall_puma_target_tags  = ["reddit-app-stage"]
}

module "db" {
  source                     = "../modules/db"
  public_key_path            = "${var.public_key_path}"
  zone                       = "${var.zone}"
  db_disk_image              = "${var.db_disk_image}"
  db_name                    = "reddit-db-stage"
  tags                       = ["reddit-db-stage"]
  firewall_mongo_name        = "firefall-mongo-stage"
  firewall_mongo_source_tags = ["reddit-app-stage"]
  firewall_mongo_target_tags = ["reddit-db-stage"]
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
  name_ssh      = "ssh-for-stage"
}
