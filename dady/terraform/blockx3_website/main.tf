terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host          = "tcp://10.0.0.4:2376"
  cert_material = file(pathexpand("~/docker_data/dind/client/cert.pem"))
  key_material  = file(pathexpand("~/docker_data/dind/client/key.pem"))
  registry_auth {
    address  = "registry.hub.docker.com"
    username = "blockx3"
    password = "********"
  }
}

// to use the variable from environment variable use this format, this repo uses vars.tfvars file for variables
// export RMQ_USER="RMQ_USER=admin" because the env option in docker_container resource accepts an array of 'KEY=VALUE' pair
variable "RMQ_USER" {
  type = string
}
variable "RMQ_PASS" {
  type = string
}
variable "RMQ_HOST" {
  type = string
}

resource "docker_image" "blockx3_website" {
  name = "blockx3/private:website"
}


resource "docker_container" "nginx" {
  image    = docker_image.blockx3_website.image_id
  name     = "blockx3_website"
  hostname = "blockx3website"
  env      = [var.RMQ_USER, var.RMQ_PASS, var.RMQ_HOST]
  networks_advanced = {
    name         = "deploy"
    ipv4_address = "______"
  }
}
