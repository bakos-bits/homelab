job "traefik" {
  datacenters = ["dc1"]
  type        = "system"

  group "traefik" {

    network {
      port "http" { static = "80" }
      port "https" { static = "443" }
      port "postgres" { static = "5432" }
    }

    service {
      name = "$${NOMAD_JOB_NAME}"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.entrypoints=websecure",
        "traefik.http.routers.api.service=api@internal",
        "traefik.http.services.dummy.loadbalancer.server.port=9000",
        "traefik.http.routers.api.middlewares=auth",
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:3.2.3"
        ports        = ["http", "https", "postgres"]
        network_mode = "host"
        volumes      = [
          "${job_volumes}/certs:/etc/traefik/certs",
          "local/traefik.yaml:/etc/traefik/traefik.yaml",
          "local/dynamic.yaml:/etc/traefik/dynamic/dynamic.yaml"
        ]
      }

      resources {
        cpu    = 250
        memory = 256
      }

      template {
        destination = "local/traefik.yaml"
        data        = <<-EOF
        {{- key "homelab/traefik/traefik.yaml" }}
        EOF
      }

      template {
        destination = "local/dynamic.yaml"
        data        = <<-EOF
        {{- key "homelab/traefik/dynamic.yaml" }}
        EOF
      }
    }
  }
}