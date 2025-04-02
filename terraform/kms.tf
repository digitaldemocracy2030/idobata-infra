resource "google_kms_key_ring" "main" {
  name     = "${var.project_id}-${var.env}-main"
  location = var.region
}

resource "google_kms_crypto_key" "main" {
  name     = "${var.project_id}-${var.env}-main"
  key_ring = google_kms_key_ring.main.id
}
