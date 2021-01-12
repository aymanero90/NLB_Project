variable "admin_ip" {
  type = string
  default = "0.0.0.0/0"
}

resource "exoscale_security_group" "SecurityGroup" {
  name = "CLC_SecurityGroup"
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.SecurityGroup.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = var.admin_ip
  start_port = 22
  end_port = 22
}

resource "exoscale_security_group_rule" "http_8080" {
  security_group_id = exoscale_security_group.SecurityGroup.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = var.admin_ip
  start_port = 8080
  end_port = 8080
}

resource "exoscale_security_group_rule" "node_exporter" {
  security_group_id = exoscale_security_group.SecurityGroup.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = var.admin_ip
  start_port = 9100
  end_port = 9100
}