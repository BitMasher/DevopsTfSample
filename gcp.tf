provider "google" {
  project     = "sandbox-302302"
  region      = "us-central"
  credentials = "sandbox-302302-23e759dc0d3d.json"
}

data "google_compute_image" "ubuntu2004" {
  project = "ubuntu-os-cloud"
  family  = "ubuntu-minimal-2004-lts"
}

data "google_compute_network" "default_network" {
  name = "default"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = data.default_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["24.242.23.224/32"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = data.default_network.name
  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}

resource "google_compute_instance" "appserver_gcp" {
  name    = "appserver"
  machine = "f1-micro"
  zone    = "us-central1-a"

  metadata = {
    provisioner = "terraform"
    environment = "integration"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      size  = 20
      image = data.google_compute_image.ubuntu2004.self_link
      type  = "pd-standard"
    }
  }

  network_interface {
    network = data.default_network.name
    access_config {
    }
  }

  tags = ["allow-ssh", "allow-http"]

  allow_stopping_for_update = false
}