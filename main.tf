provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ami-02d26659fd82cf299"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
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
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
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

    # copy SSH keys from default user (if present) so you can SSH as user1
    if [ -f /home/${DEFAULT_USER}/.ssh/authorized_keys ]; then
      mkdir -p /home/user1/.ssh
      cp /home/${DEFAULT_USER}/.ssh/authorized_keys /home/user1/.ssh/authorized_keys
      chown -R user1:user1 /home/user1/.ssh
      chmod 700 /home/user1/.ssh
      chmod 600 /home/user1/.ssh/authorized_keys
    fi

    # grant passwordless sudo to user1 (optional). Remove these lines if you don't want it.
    echo 'user1 ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user1
    chmod 0440 /etc/sudoers.d/user1

    EOF

  root_block_device {
    volume_size = 8
  }
}
