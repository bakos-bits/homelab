job "cannery" {
  datacenters = ["dc1"]
  type        = "service"

  group "cannery" {

    network {
      port "http" { static = "4000" }
    }

    service {
      name = "cannery"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.cannery.entrypoints=websecure",
        "traefik.http.routers.cannery.middlewares=auth"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "cannery" {
      driver = "docker"

      config {
        image        = "shibaobun/cannery:latest"
        network_mode = "host"
        ports        = ["http"]
      }

      resources {
        cpu    = 200
        memory = 256
      }

      template {
        env         = true
        destination = "secrets/env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/cannery" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF        
      }
    }
  }
}
