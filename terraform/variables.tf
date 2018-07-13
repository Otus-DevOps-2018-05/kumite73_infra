variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable "private_key_path" {
  description = "Private key path for provisiners to connect via ssh"
}

variable "count" {
  description = "number of VM instance"
  default = 1
}
