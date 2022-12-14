# This is the default example
# customise it as you see fit for your example usage of your module

# add provider configurations here, for example:


terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=3.8.2"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.22.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=3.23"
    }
  }
  backend "consul" {
    path = "terraform/modules/tfmod-digitalocean-minecraft-server"
  }
}

provider "vault" {}

data "vault_kv_secret_v2" "digitalocean" {
  mount = "kv"
  name  = "do"
}

provider "digitalocean" {
  token = data.vault_kv_secret_v2.digitalocean.data["token"]
}

data "vault_kv_secret_v2" "cloudflare" {
  mount = "kv"
  name  = "hashiathome"
}

provider "cloudflare" {
  api_token = data.vault_kv_secret_v2.cloudflare.data["cloudflare_token_brucellino_dev"]
}
variable "vpc_name" {
  type        = string
  description = "Name of the VPC we will be using"
  default     = "minecraft"
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
  create_droplet = false
}

# output "sizes" {
#   value = module.example.sizes
# }
