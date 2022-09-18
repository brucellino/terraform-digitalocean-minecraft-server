terraform {
  required_version = ">1.2.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=3.8.2"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.22.3"
    }

    http = {
      source  = "hashicorp/http"
      version = ">=3.1.0"
    }
  }
}
