variable "vpc_id" {}

variable "private_subnet_cidrs" {}

resource "aws_security_group" "management_ui_elb" {
  name        = "management_ui_elb_sg"
  description = "Allow ports rancher "
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
}

resource "aws_security_group" "management_allow_ui_elb" {
  name        = "rancher_ha_allow_ui_elb"
  description = "Allow Connection from elb"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.management_ui_elb.id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.management_ui_elb.id}"]
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.management_ui_elb.id}"]
  }

  ingress {
    from_port       = 8001
    to_port         = 8001
    protocol        = "tcp"
    security_groups = ["${aws_security_group.management_ui_elb.id}"]
  }

}

resource "aws_security_group" "management_allow_ui_internal" {
  name        = "rancher_ha_ui_allow_internal"
  description = "Allow Connection from internal"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.private_subnet_cidrs)}"]
  }
}

output "elb_sg_id" {
  value = "${aws_security_group.management_ui_elb.id}"
}

output "management_node_sgs" {
  value = "${join(",", list(aws_security_group.management_allow_ui_elb.id,
            aws_security_group.management_allow_ui_internal.id))}"
}
