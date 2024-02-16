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

resource "google_service_account" "my_service_account" {
  account_id   = "${var.app_name}-service-account"
  display_name = "Service Account for ${var.app_name}"
}

resource "google_project_iam_member" "editor_for_sa" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_kms_key_ring" "terraform_state" {
  name     = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  location = "us"
}

resource "google_kms_crypto_key" "terraform_state_bucket" {
  name            = "test-terraform-state-bucket"
  key_ring        = google_kms_key_ring.terraform_state.id
  rotation_period = "86400s"

  lifecycle {
    prevent_destroy = false
  }
}
data "google_project" "project" {
}

resource "google_project_iam_member" "storage" {
  project = var.project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "tfstate" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform_state_bucket.id
  }
  uniform_bucket_level_access = true
  depends_on = [
    google_project_iam_member.storage
  ]
}

resource "null_resource" "main" {
  depends_on = [
    google_cloud_run_v2_service.cloud_run
  ]
}
