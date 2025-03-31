resource "google_compute_network" "main" {
  name                    = "${var.project_id}-${var.env}-main"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "access_connector" {
  name          = "${var.project_id}-${var.env}-access-connector"
  region        = var.region
  network       = google_compute_network.main.name
  ip_cidr_range = var.network["connector_cidr"]
}

resource "google_vpc_access_connector" "main" {
  name = "${var.project_id}-${var.env}-main"
  subnet {
    name = google_compute_subnetwork.access_connector.name
  }
  machine_type  = var.network["connector_machine_type"]
  min_instances = var.network["connector_min_instances"]
  max_instances = var.network["connector_max_instances"]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = google_compute_network.main.name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.network["private_ip_address"]
  prefix_length = var.network["private_ip_prefix_length"]
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "main" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}