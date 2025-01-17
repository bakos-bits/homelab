job "transmission" {
  datacenters = ["dc1"]
  type        = "service"

  group "transmission" {

    network {
      port "http" { static = 9091 }
    }

    service {
      name = "transmission"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.transmission.entrypoints=websecure",
        "traefik.http.routers.transmission.middlewares=auth"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "transmission" {
      driver = "docker"

      config {
        image   = "lscr.io/linuxserver/transmission:latest"
        ports   = ["http"]
        volumes = [
          "/mnt/volumes/transmission:/config",
          "/mnt/volumes/media:/data",
          "/mnt/volumes/media:/watch"
        ]
      }

      env {
        PUID = 1010
        PGID = 1010
        TZ   = "America/Denver"
      }

      resources {
        cpu    = 500
        memory = 768
      }
    }
  }
}