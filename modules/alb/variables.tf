
variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "env" {
  type = string
}

variable "depends_on_igw" {
  type = any
}
