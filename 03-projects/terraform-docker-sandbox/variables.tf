variable "project" {
  description = "Short slug used to name/label all resources."
  type        = string
  default     = "tf-docker"
}

variable "docker_host" {
  description = "Docker daemon socket. Default works for Docker Desktop / standard Linux installs."
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "nginx_image" {
  description = "Web server image to pull."
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "alpine_image" {
  description = "Lightweight image for the worker container."
  type        = string
  default     = "alpine:3.20"
}

variable "web_port" {
  description = "Host port mapped to the web container's port 80."
  type        = number
  default     = 8080
}
