# variables.tf
variable "cpus" {
  type        = number
  description = "Number of CPUs we want with the instance"
  default     = 4

  validation {
    condition     = var.cpus <= 8
    error_message = "Can't select an instance with more than 8 CPUs, it will cost a lot."
  }
}

variable "mem" {
  type        = number
  description = "Max memory of droplet in GB"
  default     = 8
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to use."
}

variable "create_droplet" {
  default = false
  type    = bool
}

variable "paper_version" {
  default     = "1.19.4"
  type        = string
  description = "Version of PaperMC to use"
}

variable "instance_admin_user" {
  default     = "brucellino"
  type        = string
  description = "Github user which will be made admin of the instance. Takes their ssh key from Github and adds it to the instance."
}
