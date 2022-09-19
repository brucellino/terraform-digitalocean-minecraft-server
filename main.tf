# Main definition

data "digitalocean_sizes" "available" {
  sort {
    key       = "vcpus"
    direction = "desc"
  }

  sort {
    key       = "memory"
    direction = "desc"
  }
  filter {
    key    = "vcpus"
    values = [for cpu in range(1, var.cpus) : cpu]
  }

  filter {
    key    = "memory"
    values = [for gb in range(1, var.mem) : tonumber(1024 * gb)]
  }
}

# data "digitalocean_regions" "available" {
#   filter {
#     key    = "available"
#     values = ["true"]
#   }
#   filter {
#     key    = "features"
#     values = ["private_networking"]
#   }

#   filter {
#     key    = "sizes"
#     values = tolist(data.digitalocean_sizes.available.sizes[*].slug)
#   }
#   sort {
#     key       = "name"
#     direction = "desc"
#   }
# }

data "digitalocean_images" "selected" {
  filter {
    key    = "distribution"
    values = ["Ubuntu"]
  }
  filter {
    key    = "regions"
    values = ["ams3"]
  }

  # filter {
  #   key    = "sizes"
  #   values = [data.digitalocean_sizes.available[*].slug]
  # }
}

data "digitalocean_vpc" "selected" {
  name = var.vpc_name
}


data "http" "github_ssh_key" {
  url = "https://github.com/brucellino.keys"
}
resource "digitalocean_ssh_key" "brucellino" {
  lifecycle {
    precondition {
      condition     = contains([200, 201, 204], data.http.github_ssh_key.status_code)
      error_message = "Key not present"
    }
  }
  name       = "minecraft"
  public_key = data.http.github_ssh_key.response_body
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "minecraft" {
  image = data.digitalocean_images.selected.images[0].slug
  name  = "minecraft-server"
  # region        = data.digitalocean_regions.available.regions[0].slug
  region        = "ams3"
  size          = element(data.digitalocean_sizes.available.sizes, 0).slug
  monitoring    = true
  vpc_uuid      = data.digitalocean_vpc.selected.id
  ssh_keys      = [digitalocean_ssh_key.brucellino.id]
  droplet_agent = true

  lifecycle {
    create_before_destroy = true

  }
  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
  }
  provisioner "remote-exec" {
    inline = [
      "echo hi"
    ]
  }

}

# Create the Security Groups
resource "digitalocean_firewall" "minecraft" {
  name = "minecraft"

  droplet_ids = [digitalocean_droplet.minecraft.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["93.148.181.198"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = []
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = []
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = []
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["93.148.181.198"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["93.148.181.198"]
  }
}
