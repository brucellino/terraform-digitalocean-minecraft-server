terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
  backend "consul" {
    path = "terraform/modules/tfmod-digitalocean-minecraft-server"
  }
}

provider "vault" {}

data "vault_kv_secret_v2" "digitalocean" {
  mount = "digitalocean"
  name  = "tokens"
}

provider "digitalocean" {
  token = data.vault_kv_secret_v2.digitalocean.data["minecraft"]
}

data "vault_kv_secret_v2" "cloudflare" {
  mount = "cloudflare"
  name  = "brucellino.dev"
}

provider "cloudflare" {
  api_token = data.vault_kv_secret_v2.cloudflare.data["token"]
}
variable "vpc_name" {
  type        = string
  description = "Name of the VPC we will be using"
  default     = "minecraft"
}

variable "create_droplet" {
  type        = bool
  default     = false
  description = "Toggle for creating the server."
}
module "vpc" {
  source  = "brucellino/vpc/digitalocean"
  version = "1.0.3"
  project = {
    description = "${var.vpc_name}"
    environment = "production"
    name        = lower(var.vpc_name)
    purpose     = "Personal"
  }

  vpc_description = "Minecraft VPC"
  vpc_name        = lower(var.vpc_name)
  vpc_region      = "ams3"
}


module "example" {
  depends_on     = [module.vpc]
  source         = "../../"
  vpc_name       = var.vpc_name
  cpus           = 4
  mem            = 8
  create_droplet = var.create_droplet
}
