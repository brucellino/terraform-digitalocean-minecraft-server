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
