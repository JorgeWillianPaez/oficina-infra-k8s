variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "oficina"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_count" {
  type = object({
    min     = number
    desired = number
    max     = number
  })
  default = {
    min     = 2
    desired = 2
    max     = 4
  }
}

variable "environments" {
  type    = set(string)
  default = ["hml", "prod"]
}

variable "microservices" {
  type    = set(string)
  default = ["oficina-os-service", "oficina-billing-service", "oficina-execution-service"]
}

variable "rabbitmq_user" {
  type    = string
  default = "oficina"
}

variable "rabbitmq_password" {
  type      = string
  sensitive = true
}

variable "new_relic_license_key" {
  type      = string
  sensitive = true
  default   = ""
}
