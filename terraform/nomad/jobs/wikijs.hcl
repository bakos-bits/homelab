job "wikijs" {
  datacenters = ["dc1"]

  group "wikijs" {

    network {
      port "http" { to = 3000 }
    }

    volume "wikijs" {
      type            = "csi"
      source          = "wikijs"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "wikijs"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.wikijs.entrypoints=websecure",
        "traefik.http.routers.wikijs.middlewares=auth"
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "wikijs" {
      driver = "docker"

      config {
        image = "linuxserver/wikijs:2.5.303"
        ports = ["http"]

      }

      volume_mount {
        volume      = "wikijs"
        destination = "/config"
      }

      env {
        PUID = 1010
        PGID = 1010
        TZ   = "America/Denver"
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
  }
}