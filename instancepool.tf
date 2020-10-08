variable "zone" {
  type = string
}

variable "template"{
  type = string
}

data "exoscale_compute_template" "InstancePool" {
  zone = var.zone
  name = var.template
}

resource "exoscale_instance_pool" "myInstancePool" {
  name = "CLC_Instancepool"
  description = "Instancepool of the first project sprint"
  template_id = data.exoscale_compute_template.InstancePool.id
  service_offering = "micro"
  size = 2
  disk_size = 10
  key_pair = ""
  zone = var.zone
  user_data = file("UserData.sh")

security_group_ids = [exoscale_security_group.SecurityGroup.id]
}