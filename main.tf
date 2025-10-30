provider "aws" {
  region = var.region
}


resource "aws_security_group" "ssh" {
  name        = "${var.name_prefix}-sg"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-02d26659fd82cf29"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ssh.id]
  tags = {
    Name = "${var.name_prefix}-instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # determine a default user that exists on common AMIs
    if id -u ec2-user >/dev/null 2>&1; then DEFAULT_USER=ec2-user
    elif id -u ubuntu >/dev/null 2>&1; then DEFAULT_USER=ubuntu
    elif id -u centos >/dev/null 2>&1; then DEFAULT_USER=centos
    else DEFAULT_USER=$(whoami)
    fi

    # create user1 if it doesn't exist
    if ! id -u user1 >/dev/null 2>&1; then
      useradd -m -s /bin/bash user1
    fi

    # set home directory permissions to 0775 (rwxrwxr-x)
    chmod 0775 /home/user1 || true

    # grant passwordless sudo to user1 (optional). Remove these lines if you don't want it.
    echo 'user1 ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user1
    chmod 0440 /etc/sudoers.d/user1
  EOF

  root_block_device {
    volume_size = 8
  }
}


