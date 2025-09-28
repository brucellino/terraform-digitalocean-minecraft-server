terraform {
  required_version = ">= 1.10.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.67"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.10"
    }
  }
}
