provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_key_pair" "auth" {
  key_name   = "default"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAsblJsnvO8uSp+aBuDj4FZSrBZm/nwEWYy0OxKOpuavKItx+mmAT0+JOB2EGmI2XIacTYU2hU6Hc/KcxFJExSIcQ+bZq2dZaNuR54ShLMLUY6bWxPm94sCGJ5MKuSk+DyfDlUKhIBqYYGPhd7yRnOvxndpHrYmVsDP3IFR/wdlq0/6+0SVQXwiSMbETW78UcXWvesmzB8UjT+gw+jvBmlq/2YisGue4Rug26qAqyTB0wFqzKehig25YFvS3TqnWJjJ9XOdRqszQCxa0qniiUiIdhPKHzSzxerM427o/FU+2Mr7oJ8cbU+ijiuHAd9kT2VqHY7RepnPJ4LYWb4DRWhDw== mostlyfine"
}

data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210721.2-arm64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

}

resource "aws_security_group" "example_ec2" {
  name = "example-ec2"
  ingress {
    description = "example ingress http"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    description = "example ingress ssh"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    description = "example egress"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

}

resource "aws_instance" "example" {
  ami           = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type = "t4g.micro"
  tags = {
    "Name" = "terraform-nginx-test1"
  }
  vpc_security_group_ids = [aws_security_group.example_ec2.id]

  key_name  = aws_key_pair.auth.id
  user_data = <<EOF
  #!/bin/bash
  amazon-linux-extras install -y nginx1
  systemctl start nginx.service
EOF
}

output "example_instance_id" {
  value = aws_instance.example.public_dns
}
