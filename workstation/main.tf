provider "digitalocean" { }

resource "digitalocean_droplet" "dev" {
  ssh_keys           = [23867142]         # doctl compute ssh-key list
  image              = "ubuntu-19-10-x64"
  region             = "fra1"
  size               = "s-1vcpu-1gb"
  # size               = "s-4vcpu-8gb"
  private_networking = true
  backups            = true
  ipv6               = true
  name               = "dev"

  # I really hate user-data, don't @ me. This is powerful and works fine for my
  # needs
  provisioner "remote-exec" {
    script = "bootstrap.sh"

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "file" {
    source      = "pull-secrets.sh"
    destination = "/mnt/secrets/pull-secrets.sh"

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /mnt/secrets/pull-secrets.sh",
    ]

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }
}

variable "cf_zone_name" {}
variable "cf_auth_email" {}
variable "cf_api_key" {}

resource "null_resource" "set_dns" {
  depends_on = ["digitalocean_droplet.dev"] #wait for the db to be ready
  provisioner "local-exec" {
    command = "${path.module}/dns_update.sh ${digitalocean_droplet.dev.ipv4_address}"
    environment {
      CF_ZONE_NAME = "${var.cf_zone_name}"
      CF_AUTH_EMAIL = "${var.cf_auth_email}"
      CF_API_KEY = "${var.cf_api_key}"
    }
  }
}

resource "digitalocean_firewall" "dev" {
  name = "dev"

  droplet_ids = ["${digitalocean_droplet.dev.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "3222"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "udp"
      port_range       = "60000-60010"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

output "public_ip" {
  value = "${digitalocean_droplet.dev.ipv4_address}"
}
