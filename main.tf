terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"

}

 provider "scaleway" {
     zone            = "fr-par-1"
     region          = "fr-par"
     project_id="2d67d69c-7abd-4903-8d3b-11bd1f6494c6"
     access_key="SCWT24CHQB768N92D1FN"
     secret_key="8ed8aa11-02a4-40bb-89af-63e005025d24"
}

resource "scaleway_rdb_instance" "main" {
  name           = "test-rdb"
  node_type      = "db-dev-s"
  engine         = "PostgreSQL-11"
  is_ha_cluster  = false
  disable_backup = false
  user_name      = "my_initial_user"
  password       = "thiZ_is_v&ry_s3cret"
}

resource "scaleway_instance_ip" "public_ip" {
  count=2
}

resource "scaleway_instance_server" "web" {
  count=2
  type = "DEV1-S"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.public_ip[(count.index)].id

  user_data={
    DATABASE_URI="postgres://${scaleway_rdb_instance.main.user_name}:${scaleway_rdb_instance.main.password}@${scaleway_rdb_instance.main.endpoint_ip}:${scaleway_rdb_instance.main.endpoint_port}/rdb"
  }
   provisioner "remote-exec" {
     connection {
      type     = "ssh"
      user     = "root"
      host     = self.public_ip
      private_key = file("C:\\Users\\User OI\\dylane")
  }
    inline = [
      "sudo apt-get update",
      "sudo apt-get install docker.io --assume-yes",
      "docker run -d --name app -e DATABASE_URI='$(scw-userdata DATABASE_URI)' -p 80:8080 --restart=always europe-west1-docker.pkg.dev/efrei-devops/efrei-devops/app:latest"
    ]
  }
}

