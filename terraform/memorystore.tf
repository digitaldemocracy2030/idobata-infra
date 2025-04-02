resource "google_redis_instance" "main" {
  name               = "${var.project_id}-${var.env}-main"
  tier               = var.redis["tier"]
  memory_size_gb     = var.redis["memory_size_gb"]
  region             = var.region
  redis_version      = var.redis["redis_version"]
  authorized_network = google_compute_network.main.id
}
