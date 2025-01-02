resource "aws_security_group" "sg" {
  vpc_id = var.vpc_id

  # SSH ingress
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
    description = "SSH access"
  }

  # Salt ports from specific SGs
  ingress {
    from_port        = 4505
    to_port          = 4506
    protocol         = "tcp"
    security_groups  = var.allowed_sg_ids
    description      = "Allow Salt ports from known Minion SGs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}
