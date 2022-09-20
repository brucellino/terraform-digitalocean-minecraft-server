# Main definition
data "digitalocean_project" "selected" {
  name = var.vpc_name
}
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
    create_before_destroy = false

  }
  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
  }
  provisioner "remote-exec" {
    script = "${path.module}/provision/install.sh"
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
}

resource "digitalocean_reserved_ip" "public" {
  region = "ams3"
}

resource "digitalocean_reserved_ip_assignment" "minecraft" {
  ip_address = digitalocean_reserved_ip.public.ip_address
  droplet_id = digitalocean_droplet.minecraft.id
}

resource "digitalocean_project_resources" "droplet" {
  project = data.digitalocean_project.selected.id
  resources = [
    digitalocean_droplet.minecraft.urn
    # digitalocean_reserved_ip.public.urn
  ]
}

data "cloudflare_zone" "dev" {
  name = "brucellino.dev"
}

# Add a record to the domain
resource "cloudflare_record" "minecraft" {
  zone_id = data.cloudflare_zone.dev.id
  name    = "minecraft"
  value   = digitalocean_reserved_ip.public.ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}
