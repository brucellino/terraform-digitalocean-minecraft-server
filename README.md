[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit) [![pre-commit.ci status](https://results.pre-commit.ci/badge/github/brucellino/terraform-digitalocean-minecraft-server/main.svg)](https://results.pre-commit.ci/latest/github/brucellino/terraform-digitalocean-minecraft-server/main) [![semantic-release: conventional](https://img.shields.io/badge/semantic--release-conventional-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

# Minecraft server on Digital Ocean

This creates a minecraft server on Digtial Ocean

## Pre-commit hooks

<!-- Edit this section or delete if you make no change  -->

The [pre-commit](https://pre-commit.com) framework is used to manage pre-commit hooks for this repository.
A few well-known hooks are provided to cover correctness, security and safety in terraform.

## Examples

The `examples/` directory contains the example usage of this module.
These examples show how to use the module in your project, and are also use for testing in CI/CD.

<!--

Modify this section according to the kinds of examples you want
You may want to change the names of the examples or the kinds of
examples themselves

-->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.2.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 3.23 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | >= 2.22.3 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >=3.1.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.8.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.27.0 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.36.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_record.minecraft](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.minecraft_srv](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [digitalocean_droplet.minecraft](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_firewall.minecraft](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_project_resources.droplet](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_reserved_ip.public](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/reserved_ip) | resource |
| [digitalocean_reserved_ip_assignment.minecraft](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/reserved_ip_assignment) | resource |
| [digitalocean_ssh_key.brucellino](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key) | resource |
| [digitalocean_volume.minecraft_data](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume) | resource |
| [digitalocean_volume_attachment.minecraft](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume_attachment) | resource |
| [cloudflare_ip_ranges.cloudflare](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/ip_ranges) | data source |
| [cloudflare_zone.dev](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |
| [digitalocean_images.selected](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/images) | data source |
| [digitalocean_project.selected](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/project) | data source |
| [digitalocean_regions.available](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/regions) | data source |
| [digitalocean_sizes.available](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/sizes) | data source |
| [digitalocean_vpc.selected](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/vpc) | data source |
| [http_http.github_ssh_key](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.paper_downloads](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpus"></a> [cpus](#input\_cpus) | Number of CPUs we want with the instance | `number` | `4` | no |
| <a name="input_create_droplet"></a> [create\_droplet](#input\_create\_droplet) | n/a | `bool` | `false` | no |
| <a name="input_instance_admin_user"></a> [instance\_admin\_user](#input\_instance\_admin\_user) | Github user which will be made admin of the instance. Takes their ssh key from Github and adds it to the instance. | `string` | `"brucellino"` | no |
| <a name="input_mem"></a> [mem](#input\_mem) | Max memory of droplet in GB | `number` | `8` | no |
| <a name="input_paper_version"></a> [paper\_version](#input\_paper\_version) | Version of PaperMC to use | `string` | `"1.19.4"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC to use. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sizes"></a> [sizes](#output\_sizes) | n/a |
<!-- END_TF_DOCS -->
