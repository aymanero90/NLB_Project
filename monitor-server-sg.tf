
resource "exoscale_security_group" "Monitor-SecurityGroup" {
  name = "CLC_Monitor_SecurityGroup"
}

resource "exoscale_security_group_rule" "prometheus" {
  security_group_id = exoscale_security_group.Monitor-SecurityGroup.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = var.admin_ip
  start_port = 9090
  end_port = 9090
}

resource "exoscale_security_group_rule" "grafana" {
  security_group_id = exoscale_security_group.Monitor-SecurityGroup.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = var.admin_ip
  start_port = 3000
  end_port = 3000
}

resource "exoscale_security_group_rule" "autoscaler" {
  security_group_id = exoscale_security_group.Monitor-SecurityGroup.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = var.admin_ip
  start_port = 8090
  end_port = 8090
}