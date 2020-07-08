variable "cluster_name" {
  default = "eks_cluster"
}

variable "node_group_name" {
  default = "worker_node"
}

variable "vpc_cidr_block" {
  default = "10.25.0.0/16"
}

variable "eks_version" {
  default = 1.16
}

variable "public_access" {
  default = "true"
}
