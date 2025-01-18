job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres" {

    network {
      port "postgres" { to = "5432" }
    }

    volume "postgres" {
      type            = "csi"
      read_only       = false
      source          = "postgres"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }   

    service {
      name = "postgres"
      port = "postgres"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.postgres.entrypoints=postgres",
        "traefik.tcp.routers.postgres.rule=HostSNI(`*`)",
        "traefik.tcp.services.postgres.loadBalancer.server.port=${NOMAD_HOST_PORT_postgres}"
      ]

      check {
        type     = "tcp"
        port     = "postgres"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "postgres" {
      driver = "docker"

      volume_mount {
        volume      = "postgres"
        destination = "/var/lib/pgsql/db"
      }

      config {
        image = "postgres:16.4"
        ports = ["postgres"]
      }

      template {
        env         = true
        destination = "secrets/postgres.env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/postgres" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }

      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }
}
