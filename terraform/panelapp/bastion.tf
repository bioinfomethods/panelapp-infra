# Purpose: Create a bastion host into the VPC
resource "aws_instance" "bastion" {
  count                       = var.create_bastion_host ? 1 : 0
  ami                         = "ami-030a5acd7c996ef60"
  instance_type               = "t3.micro"
  subnet_id                   = data.terraform_remote_state.infra.outputs.public_subnets[0]
  security_groups = [aws_security_group.bastion_sg[0].id]
  associate_public_ip_address = true
  key_name                    = var.bastion_host_key_name
  tags = merge(
    var.default_tags,
    tomap({ "Name" : "bastion-${var.env_name}" })
  )
}

resource "aws_security_group" "bastion_sg" {
  count  = var.create_bastion_host ? 1 : 0
  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

resource "aws_security_group_rule" "allow_bastion_to_rds" {
  count                    = var.create_bastion_host ? 1 : 0
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.aurora.aurora_security_group
  source_security_group_id = aws_security_group.bastion_sg[0].id
  depends_on = [aws_instance.bastion[0]]
}
