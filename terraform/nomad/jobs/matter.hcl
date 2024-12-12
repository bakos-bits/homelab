job "matter" {
  datacenters = ["dc1"]
  type        = "service"

  group "matter" {

    network {
      port "websocket" { static = 5580 }

    }  

    service {
      name = "matter"
      port = "websocket"

      check {
        type     = "tcp"
        port     = "websocket" 
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "matter" {
      driver = "docker"

      config {
        image   = "ghcr.io/home-assistant-libs/python-matter-server:stable"
        ports   = ["websocket"]
        volumes = [
          "/mnt/matter:/data"
        ]     
      }

      resources {
        cpu    = 300
        memory = 256
      }    
    }
  }
}