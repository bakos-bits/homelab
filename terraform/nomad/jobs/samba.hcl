job "samba" {
  datacenters = ["dc1"]
  type        = "service"

  group "samba" {

    network {
      port "smb" { static = "445" }
    }

    service {
      name = "$${NOMAD_JOB_NAME}"
      port = "smb"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "samba" {
      driver = "docker"

      config {
        image        = "servercontainers/samba:smbd-only-a3.19.0-s4.18.9-r0"
        ports        = ["smb"]
        network_mode = "host"
        volumes = [
          "${job_volumes}/$${NOMAD_JOB_NAME}:/shares/homelab",
          "${job_volumes}/media:/data"
        ]
      }

      resources {
        cpu    = 200
        memory = 256
      }

      template {
        env         = true
        destination = "secrets/env"
        data        = <<-EOF
        {{- with nomadVar "nomad/jobs/samba" }}
          {{- range .Tuples }}
            {{ .K }}={{ .V }}
          {{- end }}
        {{- end }}
        EOF
      }
    }
  }
}
