job "mosquitto" {
  datacenters = ["dc1"]
  type        = "service"

  group "moquitto" {

    network {
      port "mqtt" { static = 1883 }
      port "websocket" { static = 9001 }

    }

    volume "mosquitto-config" {
      type            = "csi"
      source          = "mosquitto-config"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "mosquitto-data" {
      type            = "csi"
      source          = "mosquitto-data"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "mosquitto-log" {
      type            = "csi"
      source          = "mosquitto-log"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "mosquitto"
      port = "mqtt"

      check {
        type     = "tcp"
        port     = "mqtt"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "mosquitto" {
      driver = "docker"

      config {
        image        = "eclipse-mosquitto"
        ports        = ["mqtt", "websocket"]
        network_mode = "host"
        volumes = [
          "local/mosquitto.conf:/mosquitto/config/mosquitto.conf",
          "secrets/password.txt:/mosquitto/config/password.txt",
        ]
      }

      volume_mount {
        volume      = "mosquitto-config"
        destination = "/mosquitto/config"
      }

      volume_mount {
        volume      = "mosquitto-data"
        destination = "/mosquitto/data"
      }

      volume_mount {
        volume      = "mosquitto-log"
        destination = "/mosquitto/log"
      }

      env {
        PUID = "1010"
        PGID = "1010"
        TZ   = "America/Denver"
      }

      resources {
        cpu    = 300
        memory = 256
      }


      template {
        destination = "local/mosquitto.conf"
        data        = <<-EOF
        {{- key "homelab/mqtt/mosquitto.conf" }}
        EOF
      }


      template {
        destination = "secrets/password.txt"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/mqtt" }}
          {{ .USER }}:{{ .PASSWORD }}
        {{- end }}        
        EOF
      }

    }
  }
}