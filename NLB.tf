
resource "exoscale_nlb" "myNLB" {
  zone = var.zone
  name = "CLC_NLB"
  description = "The network load balancer for CLC_Instancepool"
}

data "exoscale_compute_template" "myNLB" {
  zone = var.zone
  name = var.template
}

resource "exoscale_nlb_service" "myNLB_Service" {
  zone             = exoscale_nlb.myNLB.zone
  name             = "CLC_NLBService"
  description      = "NLB-Service over Http for CLC_Instancepool"
  nlb_id           = exoscale_nlb.myNLB.id
  instance_pool_id = exoscale_instance_pool.myInstancePool.id
    protocol       = "tcp"
    port           = 80
    target_port    = 8080
    strategy       = "round-robin"

  healthcheck {
    mode     = "http"
    port     = 8080
    uri      = "/health"    
  }
}
