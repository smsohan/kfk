variable "image" {
    default = "us-central1-docker.pkg.dev/sohansm-project/kfk/app@sha256:55ef029f3e10a7451d68eba325596bfa80fdb90ddd382246662fa96a9d2b2331"
}
variable "consumer_image" {
    default = "us-central1-docker.pkg.dev/sohansm-project/kfk/consumer@sha256:8e0afbf925f0b793bd38cd73a38136ed7b97604bd3e63611d83569db8f78998f"
}

variable "project" {
  default = "sohansm-project"
}
variable "zone" {
    default = "us-central1-a"
}
variable "region" {
    default = "us-central1"
}

variable "app_name" {
    default = "kfk"
}

