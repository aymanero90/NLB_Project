data "exoscale_compute_template" "monitor" {
  zone = var.zone
  name = var.template
}

resource "exoscale_compute" "monitor-server" {
  zone         = var.zone
  display_name = "clc-monitor-server"
  template_id  = data.exoscale_compute_template.monitor.id
  size         = "Tiny"
  disk_size    = 20
  key_pair     = ""
  

  affinity_groups = []
  security_group_ids = [exoscale_security_group.SecurityGroup.id , exoscale_security_group.Monitor-SecurityGroup.id]

  user_data = templatefile("userdata-monitor-server.sh" , {
                exoscale_key             = var.exoscale_key
                exoscale_secret          = var.exoscale_secret
				exoscale_instancepool_id = exoscale_instance_pool.myInstancePool.id
				prometheus_config        = file("util_files/prom_config.conf")
				grafana_dashboard_config = file("util_files/grafana/dashboard_config.yml")
				grafana_dashboard        = file("util_files/grafana/dashboard.json")				
  })
  
 }