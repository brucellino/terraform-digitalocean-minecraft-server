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
  }
  backend "consul" {
    path = "terraform/tfmod-digitalocean-minecraft-server"
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


module "example" {
  source = "../../"
}

output "sizes" {
  value = module.example.sizes
}
