###############################################################################
# terraform-docker-sandbox
# Provisions real Docker containers + a network on the LOCAL machine.
# Same init/plan/apply/destroy workflow as cloud — but $0 and no API token.
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Talks to the local Docker daemon over its unix socket.
# (On Docker Desktop for macOS this socket path is the default.)
provider "docker" {
  host = var.docker_host
}

# A user-defined bridge network so the containers can talk by name.
resource "docker_network" "sandbox" {
  name = "${var.project}-net"
}

# Pull the nginx image (declaratively — Terraform manages the image too).
resource "docker_image" "nginx" {
  name         = var.nginx_image
  keep_locally = true
}

# A web container, port-mapped to the host so you can curl it.
resource "docker_container" "web" {
  name  = "${var.project}-web"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.sandbox.name
  }

  ports {
    internal = 80
    external = var.web_port
  }

  restart = "unless-stopped"
}

# A second, plain container to practice multi-resource graphs.
resource "docker_image" "alpine" {
  name         = var.alpine_image
  keep_locally = true
}

resource "docker_container" "worker" {
  name    = "${var.project}-worker"
  image   = docker_image.alpine.image_id
  command = ["sleep", "infinity"]

  networks_advanced {
    name = docker_network.sandbox.name
  }
}

output "web_url" {
  value       = "http://localhost:${var.web_port}"
  description = "Open this in a browser — the nginx welcome page."
}

output "containers" {
  value       = [docker_container.web.name, docker_container.worker.name]
  description = "Names of the running containers (verify with: docker ps)."
}

output "network" {
  value       = docker_network.sandbox.name
  description = "The bridge network the containers share."
}
