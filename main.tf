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

data "digitalocean_regions" "available" {
  filter {
    key    = "available"
    values = ["true"]
  }

  filter {
    key    = "sizes"
    values = tolist(data.digitalocean_sizes.available.sizes[*].slug)
  }

  filter {
    key    = "slug"
    values = [data.digitalocean_vpc.selected.region]
  }
  sort {
    key       = "name"
    direction = "desc"
  }
}

data "digitalocean_images" "selected" {
  filter {
    key    = "distribution"
    values = ["Ubuntu"]
  }
  filter {
    key    = "regions"
    values = [data.digitalocean_vpc.selected.region]
  }
  # filter {
  #   key    = "type"
  #   values = ["distribution"]
  # }
  filter {
    key    = "slug"
    values = ["ubuntu-24-10-x64"]
  }
}

data "digitalocean_vpc" "selected" {
  name = var.vpc_name
}


data "http" "github_ssh_key" {
  url = "https://github.com/${var.instance_admin_user}.keys"
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

resource "digitalocean_volume" "minecraft_data" {
  region                  = data.digitalocean_regions.available.regions[0].slug
  name                    = "minecraftdata"
  size                    = 10
  initial_filesystem_type = "ext4"
  description             = "Minecraft Data"
  lifecycle {
    ignore_changes = [initial_filesystem_type]
  }
}

data "http" "paper_downloads" {
  url = "https://api.papermc.io/v2/projects/paper/versions/${var.paper_version}/builds"
  lifecycle {
    postcondition {
      condition     = contains([200, 201, 204], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

locals {
  build = element(jsondecode(data.http.paper_downloads.response_body).builds, length(jsondecode(data.http.paper_downloads.response_body).builds) - 1)
}



# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "minecraft" {
  count  = var.create_droplet ? 1 : 0
  image  = data.digitalocean_images.selected.images[0].slug
  name   = "minecraft-server"
  region = data.digitalocean_regions.available.regions[0].slug
  # region        = "ams3"
  size          = element(data.digitalocean_sizes.available.sizes, 0).slug
  monitoring    = true
  vpc_uuid      = data.digitalocean_vpc.selected.id
  ssh_keys      = [digitalocean_ssh_key.brucellino.id]
  droplet_agent = true
  user_data = templatefile("${path.module}/templates/cloud-config.yml.tmpl", {
    paper_version = var.paper_version
    paper_build   = local.build.build
    # Set mx based on the size of the instance memory -- should be computed
    # mx            = element(data.digitalocean_sizes.available.sizes, 0).memory
  })

  lifecycle {
    create_before_destroy = true
  }
  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
  }

}

resource "digitalocean_volume_attachment" "minecraft" {
  count      = var.create_droplet ? 1 : 0
  droplet_id = digitalocean_droplet.minecraft[0].id
  volume_id  = digitalocean_volume.minecraft_data.id
}


data "cloudflare_ip_ranges" "cloudflare" {}

# Create the Security Groups
resource "digitalocean_firewall" "minecraft" {
  count = var.create_droplet ? 1 : 0
  name  = "minecraft"

  droplet_ids = [digitalocean_droplet.minecraft[0].id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "25565"
    # source_addresses = tolist(data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks)
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "25565"
    source_addresses = tolist(data.cloudflare_ip_ranges.cloudflare.ipv4_cidrs)
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = []
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
}

resource "digitalocean_reserved_ip" "public" {
  region = "ams3"
}

resource "digitalocean_reserved_ip_assignment" "minecraft" {
  count      = var.create_droplet ? 1 : 0
  ip_address = digitalocean_reserved_ip.public.ip_address
  droplet_id = digitalocean_droplet.minecraft[0].id
}

resource "digitalocean_project_resources" "droplet" {
  project   = data.digitalocean_project.selected.id
  resources = (var.create_droplet ? [digitalocean_droplet.minecraft[0].urn] : [])
}

data "cloudflare_zone" "dev" {
  filter = {
    match = "any"
    name  = "brucellino.dev"
  }
}

# Add a record to the domain
resource "cloudflare_dns_record" "minecraft" {
  zone_id = data.cloudflare_zone.dev.id
  name    = "minecraft"
  content = digitalocean_reserved_ip.public.ip_address
  type    = "A"
  ttl     = 60
  proxied = false
}


resource "cloudflare_dns_record" "minecraft_srv" {
  zone_id = data.cloudflare_zone.dev.id
  name    = "mc_service"
  type    = "SRV"
  ttl     = 60
  data = {
    service  = "_minecraft"
    proto    = "tcp"
    name     = "mc_service"
    priority = 0
    weight   = 0
    port     = 25565
    target   = cloudflare_dns_record.minecraft.name
  }
}
