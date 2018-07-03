variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

# Tags for app
variable tags {
  type        = "list"
  description = "Tags for app"
}

# Название приложения
variable db_name {
  description = "Db name"
}

# переменные для mongo_firewall
variable firewall_mongo_name {
  description = "Name for mongo (firefall-mongo-stage)"
}

variable firewall_mongo_source_tags {
  type        = "list"
  description = "Firewall mongo source tags"
}

variable firewall_mongo_target_tags {
  type        = "list"
  description = "Firewall mongo target tags (reddit-app-stage)"
}
