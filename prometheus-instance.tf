data "exoscale_compute_template" "prometheus" {
  zone = var.zone
  name = var.template
}

resource "exoscale_compute" "promserver" {
  zone         = var.zone
  display_name = "clc-prometheus-server"
  template_id  = data.exoscale_compute_template.prometheus.id
  size         = "Micro"
  disk_size    = 10
  key_pair     = ""
  

  affinity_groups = []
  security_group_ids = [exoscale_security_group.SecurityGroup.id , exoscale_security_group.Prom-SecurityGroup.id]

  user_data = templatefile("userdata-prometheus.sh" , {
                exoscale_key             = var.exoscale_key
                exoscale_secret          = var.exoscale_secret
				exoscale_instancepool_id = exoscale_instance_pool.myInstancePool.id
				prometheus_config        = file("prom_config.conf")
  })
  
 }