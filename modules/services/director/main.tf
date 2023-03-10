resource aws_instance director {
  ami = var.image_id
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }

  subnet_id = var.specific_subnet_id
  vpc_security_group_ids = [aws_security_group.director.id]

  key_name = var.director_key_pair_name

  root_block_device {
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
    iops        = var.ebs_volume_type == "gp3" ? var.ebs_iops : null
    tags = {
      Name = var.custom_instance_name == "" ? "edx-${var.environment}-director" : var.custom_instance_name
    }
  }

  tags = {
    Name = var.custom_instance_name == "" ? "edx-${var.environment}-director" : var.custom_instance_name
  }
}

resource aws_security_group director {
  vpc_id = var.specific_vpc_id
  name = var.custom_security_group_name == "" ? "edx-${var.environment}-director" : var.custom_security_group_name

  lifecycle {
    ignore_changes = [description]
  }
}

resource aws_security_group_rule director-outbound {
  type = "egress"
  security_group_id = aws_security_group.director.id

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource aws_security_group_rule director-ssh-rule {
  type = "ingress"
  security_group_id = aws_security_group.director.id
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
