#TODO - maybe not have 22 be open for all
variable "ingress_ports" {
  description = "Ingress ports to be used in security group."
  type        = list(string)
  default     = [22, 80, 443]
}

variable "egress_ports" {
  description = "Egress ports to be used in security group."
  type        = list(string)
  default     = [80, 443]
}

variable "public_key" {
  description = "Path to your public SSH key"
  type        = string
  default     = "~/.ssh/aws.pub"
}
