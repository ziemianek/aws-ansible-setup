provider "aws" {
  region = "eu-west-2"
}

variable "ingress_rules" {
  type    = list(number)
  default = [22, 80, 443, 8080]
}

variable "egress_rules" {
  type    = list(number)
  default = [22, 80, 443, 8080]
}

# Create security group for ansible
resource "aws_security_group" "ansible_sg" {
  name = var.ansible_security_group_name
  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_rules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.egress_rules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# Creating key-pair on AWS using SSH-public key
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${path.module}/my_key.pub")
}

# Create Elastic IP for Control node
resource "aws_eip" "control_node_eip" {
  instance = aws_instance.control_node.id
}

# Provision Control node
resource "aws_instance" "control_node" {
  ami             = var.amazon_linux_ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ansible_sg.name]
  key_name        = aws_key_pair.deployer.key_name

  tags = {
    Name = "Control_Node"
  }
}

# Provision Managed nodes
resource "aws_instance" "managed_nodes" {
  count           = var.num_hosts
  ami             = element([var.redhat_linux_ami, var.amazon_linux_ami, var.ubuntu_linux_ami], count.index)
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ansible_sg.name]
  key_name        = aws_key_pair.deployer.key_name

  tags = {
    Name = "Managed_Node_${count.index + 1}"
  }
}

# Output Control Node Public IP
output "control_node_public_ip" {
  value = aws_eip.control_node_eip.public_ip
}

# Output Managed Nodes Public IPs
output "rhel_node_public_ip" {
  value = aws_instance.managed_nodes[0].public_ip
}

output "amazl_node_public_ip" {
  value = aws_instance.managed_nodes[1].public_ip
}

output "ubuntu_node_public_ip" {
  value = aws_instance.managed_nodes[2].public_ip
}