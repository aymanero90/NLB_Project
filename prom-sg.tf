
resource "exoscale_security_group" "Prom-SecurityGroup" {
  name = "CLC_Prom_SecurityGroup"
}

resource "exoscale_security_group_rule" "prometheus" {
  security_group_id = exoscale_security_group.Prom-SecurityGroup.id
  type = "INGRESS"
  protocol = "TCP"
  cidr = var.admin_ip
  start_port = 9090
  end_port = 9090
}