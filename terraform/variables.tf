variable "image" {
    default = "us-central1-docker.pkg.dev/sohansm-project/kfk/app@sha256:287e0eabea58dfadd5929d599382819e33abfe29942991df05365ec0785262c1"
}
variable "consumer_image" {
    default = "us-central1-docker.pkg.dev/sohansm-project/kfk/consumer@sha256:3c0045ea761e0e3d1193c714eec779b96935097ea168a5bd51c9c8e00f754d29"
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

