terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
  backend "s3" {
    bucket         = "aaraz"
    key            = "terraform/state_files/server_docker/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform_state"
  }
}

variable "docker_registry" {
  type = object({
    url      = string
    username = string
    password = string
  })
}

provider "docker" {
  ## i have a ssh config named dady in .ssh/config
  host = "ssh://dady"
  registry_auth {
    address  = var.docker_registry.url
    username = var.docker_registry.username
    password = var.docker_registry.password
  }
}

## Docker container Not managed by this terraform

## grafana
## postgres
## nextcloud & nextcloud-db
## portainer
## ciscolive
## clown
## telegram bot
## sockerio-server


# static server
resource "docker_image" "nginx-alpine" {
  name         = "nginx:alpine3.20"
  keep_locally = true
}
resource "docker_container" "static-server" {
  name  = "static-server"
  image = docker_image.nginx-alpine.image_id
  volumes {
    host_path      = "/home/ubuntu/static_serve"
    container_path = "/usr/share/nginx/html/"
  }
  networks_advanced {
    name         = "deploy"
    ipv4_address = "11.0.0.4"
  }
}


# NTFY 
resource "docker_image" "ntfy" {
  name         = "binwiederhier/ntfy:v2.11.0"
  keep_locally = true
}
resource "docker_container" "ntfy" {
  name       = "ntfy"
  image      = docker_image.ntfy.image_id
  tty        = true
  stdin_open = true
  command    = ["serve"]
  networks_advanced {
    name         = "deploy"
    ipv4_address = "11.0.0.5"
  }
}
