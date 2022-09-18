output "sizes" {
  value = data.digitalocean_sizes.available.sizes[*].slug
}
