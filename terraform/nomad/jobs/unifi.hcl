job "unifi" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "nomadcli03"
  }

  group "unifi" {

    network {
      port "http" { static = "8443" }
    }

    service {
      name = "unifi"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.unifi.entrypoints=websecure",
        "traefik.http.services.unifi.loadbalancer.server.scheme=https",
        "traefik.http.routers.unifi.middlewares=auth"
      ]

      check {
        type     = "tcp"
        path     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "unifi" {
      driver = "docker"

      config {
        image        = "linuxserver/unifi-network-application:9.1.120"
        network_mode = "host"
        ports        = ["http"]
        volumes = [
          "${job_volumes}/unifi:/config"
        ]
      }

      resources {
        cpu    = 1500
        memory = 1536
      }

      template {
        env         = true
        destination = "secrets/unifi.env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/unifi" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }
    }
  }
}