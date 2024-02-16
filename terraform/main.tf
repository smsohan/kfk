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

# Provider setup
provider "google" {
  project = var.project
  region  = var.region
}


resource "google_compute_network" "vpc" {
  name = "${var.app_name}-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.app_name}-vpc-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_firewall" "http-allow" {
  name        = "allow-http-9093"
  network     = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["9092", "9093"]
  }
  source_ranges = ["0.0.0.0/0"] # open to the world
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "ssh-allow" {
  name        = "allow-ssh"
  network     = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]  # Open to the world
  target_tags   = ["container-vm-example"]
}

resource "google_service_account" "my_service_account" {
  account_id   = "${var.app_name}-service-account"
  display_name = "Service Account for ${var.app_name}"
}

resource "google_project_iam_member" "editor_for_sa" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 3.0"

  cos_image_name = "cos-stable-77-12371-89-0"

  container = {
    image = "bitnami/kafka:latest"

    env = [
        {name = "KAFKA_CFG_NODE_ID", value = "0"},
        {name = "KAFKA_CFG_PROCESS_ROLES", value = "controller,broker"},
        {name = "KAFKA_CFG_LISTENERS", value = "PLAINTEXT://:9092,CONTROLLER://:9093"},
        {name = "KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP", value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"},
        {name = "KAFKA_CFG_CONTROLLER_QUORUM_VOTERS", value = "0@kafka:9093"},
        {name = "KAFKA_CFG_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER"},
        {name = "KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE", value = "true"}
    ]

    volumeMounts = [
      {
        mountPath = "/cache"
        name      = "tempfs-0"
        readOnly  = false
      },
    ]
  }

  volumes = [
    {
      name = "tempfs-0"

      emptyDir = {
        medium = "Memory"
      }
    },
  ]

  restart_policy = "Always"
}

resource "google_compute_instance" "vm" {
  project      = var.project
  name         = "${var.app_name}-vm"
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  network_interface {
    subnetwork_project = var.project
    subnetwork         = google_compute_subnetwork.subnet.name
    access_config {}
  }

  tags = ["container-vm-example"]

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  service_account {
    email = google_service_account.my_service_account.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}