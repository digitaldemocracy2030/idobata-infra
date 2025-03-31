resource "google_sql_database_instance" "main" {
  name             = "${var.project_id}-${var.env}-main"
  database_version = var.db["database_version"]
  region           = var.region

  settings {
    tier = var.db["tier"]
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      enable_private_path_for_google_cloud_services = false
    }
  }
  # 面倒なので後回し
  # ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#encryption_key_name-1
  # encryption_key_name = google_kms_crypto_key.main.name
  # FIXME: デバッグ用
  deletion_protection = false
}

resource "google_sql_user" "main" {
  project = var.project_id

  name        = var.db["db_user"]
  instance    = google_sql_database_instance.main.name
  # FIXME: これはマズい
  password_wo = var.db["db_password"]
  # password_wo = google_secret_manager_secret_version.db_password.secret_data
}

resource "google_sql_database" "main" {
  project = var.project_id

  name     = var.db["db_name"]
  instance = google_sql_database_instance.main.name
}
