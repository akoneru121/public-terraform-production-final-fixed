
resource "aws_lb" "this" {
  name               = "alb-${var.env}"
  load_balancer_type = "application"
  subnets            = var.subnets

  depends_on = [
    var.depends_on_igw
  ]

  tags = {
    Name = "alb-${var.env}"
  }
}
