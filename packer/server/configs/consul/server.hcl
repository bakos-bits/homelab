server           = true
client_addr      = "0.0.0.0"
advertise_addr   = "{{GetInterfaceIP \"eth0\"}}"
bind_addr        = "{{GetInterfaceIP \"eth0\"}}"
bootstrap_expect = 3
data_dir         = "/opt/consul"
datacenter       = "dc1"
enable_syslog    = true
log_level        = "warn"
retry_join  = ["nomadsrv01.bakos.lan","nomadsrv02.bakos.lan", "nomadsrv03.bakos.lan"]
acl {
  enabled = true
}
ui_config {
  enabled = true
}
