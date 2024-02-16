resource "google_cloud_run_v2_service" "cloud_run" {
  name = var.app_name
  location = var.region
  provider = google-beta
  launch_stage = "BETA"
  project = var.project

  template {
    service_account = google_service_account.my_service_account.email
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    containers {
      name = var.app_name
      image = var.image
      resources {
        limits = {
          cpu = "1000m"
          memory = "512Mi"
        }
        cpu_idle = false
      }

      env {
        name = "APP_ENV"
        value = "production"
      }

      env {
        name = "KAFKA_BOOTSTRAP_SERVERS"
        value = "${google_compute_instance.vm.network_interface.0.network_ip}:9094"
      }

      env {
        name = "KAFKA_TOPIC"
        value = "test-topic"
      }

    }

    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }

    vpc_access{
      network_interfaces {
        network = google_compute_network.vpc.name
        subnetwork = google_compute_subnetwork.subnet.name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

  }

  traffic {
    percent         = 100
     type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

}