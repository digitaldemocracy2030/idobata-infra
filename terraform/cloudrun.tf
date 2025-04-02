resource "google_artifact_registry_repository" "main" {
  repository_id = "${var.project_id}-${var.env}-main"
  description   = "idobata docker repository"
  location      = var.region
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "main" {
  name     = var.project_id
  location = var.region

  template {
    containers {
      # image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/idobata:latest"
      image = "discourse/base:2.0.20250226-0128"
      args = ["/sbin/boot"]
      resources {
        limits = {
          cpu    = "2"
          memory = "1024Mi"
        }
      }
      startup_probe {
        initial_delay_seconds = 120
        timeout_seconds = 10
        period_seconds = 10
        failure_threshold = 10
        tcp_socket {
          port = 80
        }
      }

      env {
        name = "LC_ALL"
        value = "en_US.UTF-8"
      }
      env {
        name = "LANG"
        value = "en_US.UTF-8"
      }
      env {
        name = "LANGUAGE"
        value = "en_US.UTF-8"
      }
      env {
        name  = "RAILS_ENV"
        value = "production"
      }
      env {
        name  = "DISCOURSE_RAILS_ENV"
        value = "production"
      }
      env {
        name = "DISCOURSE_DEV_LOG_LEVEL"
        value = "debug"
      }
      env {
        name = "DISCOURSE_HOSTNAME"
        value = ""
      }
      env {
        name = "DISCOURSE_DEVELOPER_EMAILS"
        value = var.app["developer_emails"]
      }
      env {
        name = "DISCOURSE_SMTP_ADDRESS"
        value = var.app["smtp_address"]
      }
      env {
        name = "DISCOURSE_SMTP_USER_NAME"
        value = var.app["smtp_user_name"]
      }
      env {
        name = "DISCOURSE_SMTP_PASSWORD"
        value = var.app["smtp_password"]
      }
      env {
        name  = "DISCOURSE_DB_HOST"
        value = google_sql_database_instance.main.private_ip_address
      }
      env {
        name  = "DISCOURSE_DB_PORT"
        value = "5432"
      }
      env {
        name  = "DISCOURSE_DB_USERNAME"
        value = google_sql_database.main.name
      }
      env {
        name  = "DISCOURSE_DB_USERNAME"
        value = var.db["db_user"]
      }
      env {
        name = "DISCOURSE_DB_PASSWORD"
        # FIXME: これはマズい
        value = var.db["db_password"]
        # value_source {
          # secret_key_ref {
            # secret = google_secret_manager_secret.db_password.secret_id
            # version = "latest"
          # }
        # }
      }
      env {
        name  = "DISCOURSE_REDIS_HOST"
        value = google_redis_instance.main.host
      }
      env {
        name = "DISCOURSE_REDIS_PORT"
        value = "6379"
      }
    }
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  # FIXME: デバッグ用
  deletion_protection = false
}

resource "google_compute_backend_service" "main" {
  name        = "${var.project_id}-${var.env}-main"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.main.id
  }
}
resource "google_compute_region_network_endpoint_group" "main" {
  name                  = "${var.project_id}-${var.env}-main"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.main.name 
  }
}
resource "google_compute_url_map" "main" {
  name = "${var.project_id}-${var.env}-main"

  default_service = google_compute_backend_service.main.id

  host_rule {
    hosts        = ["hogehoge.com"]
    path_matcher = "app"
  }
  path_matcher {
    name            = "app"
    default_service = google_compute_backend_service.main.id
  }
}
