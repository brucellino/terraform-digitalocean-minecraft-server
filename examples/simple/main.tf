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
      version = ">=2.22.3"
    }
  }
  backend "consul" {
    path = "terraform/tfmod-digitalocean-minecraft-server"
  }
}

provider "vault" {

}


module "example" {
  source = "../../"
  dummy  = "test"
}
