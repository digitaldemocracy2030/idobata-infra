resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.project_id}-${var.env}-db-password"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  # replication {
  #   auto {
  #     customer_managed_encryption {
  #       kms_key_name = google_kms_crypto_key.main.name
  #     }
  #   }
  # }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret = google_secret_manager_secret.db_password.name
  # FIXME: これはマズい
  secret_data_wo = var.db["db_password"]
}
