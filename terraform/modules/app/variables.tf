variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

# Tags for app
variable tags {
  type        = "list"
  description = "Tags for app"
}

# Название приложения
variable app_name {
  description = "App name"
}

# IP адрес для app_ip
variable reddit_app_ip_name {
  description = "App IP name"
}

# переменные для puma_firewall
variable firewall_puma_name {
  description = "Name for puma (firefall-puma-stage)"
}

variable firewall_puma_source_range {
  type        = "list"
  description = "Firewall puma IP ranges (0.0.0.0/0)"
}

variable firewall_puma_target_tags {
  type        = "list"
  description = "Firewall puma target tags (reddit-app-stage)"
}
