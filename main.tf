
# Contains terraform-specific settings, such as required providers to provision infrastructure
# Each provider takes a source, which is the hostname/provider type in the Terraform Registry
# So our docker provider is fully: registry.terraform.io/kreuzwerker/docker
# Version constraint is optional, terraform automatically downloads most recent version
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///Users/charliedobson/.docker/run/docker.sock"
  registry_auth {
    address     = "registry-1.docker.io"
    username = var.username
    password = var.password
  }
}

resource "docker_image" "container-demo" {
  name = "registry-1.docker.io/cmdobson2002/container-demo"
  build {
    context = "."
    dockerfile = "Dockerfile"
    tag = ["container-demo:latest"]
  }
}

resource "docker_registry_image" "vm-container-demo" {
  name          = docker_image.container-demo.name
  keep_remotely = true
}

resource "google_cloud_run_v2_service" "default" {
  project = "vm-container-demo"
  name     = "cloudrun-service"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"


  template {
    containers {
      image = "docker.io/cmdobson2002/container-demo:latest"
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  service     = google_cloud_run_v2_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}


