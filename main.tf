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
# Create the Security Groups
