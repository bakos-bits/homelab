job "flaresolverr" {
  datacenters = ["dc1"]
  type        = "service"

  group "flaresolverr" {

    network {
      port "http" { static = "8191" }
    }

    volume "flaresolverr" {
      type            = "csi"
      read_only       = false
      source          = "flaresolverr"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }   

    volume "media" {
      type            = "csi"
      read_only       = false
      source          = "media"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    } 

    service {
      name = "flaresolverr"
      port = "http"
      
      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "flaresolverr" {
      driver = "docker"

      config {
        image = "flaresolverr/flaresolverr:latest"
        ports = ["http"]
      }

      volume_mount {
        volume      = "flaresolverr"
        destination = "/config"
      }

      volume_mount {
        volume      = "media"
        destination = "/data"
      }

      env {
        PUID = 1010
        PGID = 1010
        TZ   = "America/Denver"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
