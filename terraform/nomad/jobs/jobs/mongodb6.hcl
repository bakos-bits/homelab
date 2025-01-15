job "mongodb6" {
  datacenters = ["dc1"]
  type        = "service"

    constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nomadcli01"
  }

  group "mongodb6" {

    network {
      port "mongo" { static = "27017" }
    }

    service {
      name = "mongodb6"
      port = "mongo"
    }

    task "mongodb6" {
      driver = "docker"

      config {
        image        = "mongo:6.0.18"
        network_mode = "host"
        ports        = ["mongo"]      
      }

      resources {
        cpu    = 512
        memory = 512
      }
    }
  }
}