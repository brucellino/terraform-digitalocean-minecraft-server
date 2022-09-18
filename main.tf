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

data "digitalocean_regions" "available" {
  filter {
    key    = "available"
    values = ["true"]
  }
  filter {
    key    = "features"
    values = ["private_networking"]
  }

  filter {
    key    = "sizes"
    values = tolist(data.digitalocean_sizes.available.sizes[*].slug)
  }
  sort {
    key       = "name"
    direction = "desc"
  }
}

data "digitalocean_vpc" "selected" {
  name = var.vpc_name
}
# Create the Security Groups
