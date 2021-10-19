packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:xenial"
  commit = "true"
}

build {
  name = "learn-packer"
  sources = [
    "source.docker.ubuntu"
  ]
}