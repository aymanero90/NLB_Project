terraform {
  required_providers {
    exoscale = {
      source  = "terraform-providers/exoscale"
    }
  }
}

variable "exoscale_key" {
  description = "Exoscale API key" 
  type = string
  default = "..."
}

variable "exoscale_secret" {
  description = "Exoscale API secret"
  type = string
  default = "..."
}

provider "exoscale" {
  key = var.exoscale_key
  secret = var.exoscale_secret
}