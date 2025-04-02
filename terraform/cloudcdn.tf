resource "google_storage_bucket" "cdn" {
  name                        = "${var.project_id}-${var.env}-cdn"
  location                    = var.region
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  # FIXME: デバッグ用
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "cdn" {
  bucket = google_storage_bucket.cdn.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
