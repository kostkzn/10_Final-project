provider "aws" {
  region        = "eu-north-1"
  profile       = "kooky"
}

provider "cloudinit" {
}

locals {
  common_tags = {
    Owner       = "DevOps Student Kostiantyn Kuzin"
    Project     = "swapp"
    Task        = "Hosts deploy"
  }

  ami           = "ami-0d32f1e246a0306ec"   # Ubuntu 20 
  shared_sg     = "sg-022a47e6a93c81b20" 
  shared_subnet = "subnet-0912e3e84584dba3e"
  shared_key    = "ci-swapp"
  
  # Check correct IP in init-ansible_playbook.sh
  node_1        = "control"
  node_1_type   = "t3.micro"
  node_1_key    = "${local.shared_key}"
  node_1_sg     = "sg-0b427bf05457cba01"
  node_1_ip     = "172.31.10.10"

  node_2        = "tomcat"
  node_2_type   = "t3.micro"
  node_2_key    = "${local.shared_key}"
  node_2_sg     = "sg-0fc6dde3618d73afb"
  node_2_ip     = "172.31.10.11"

  node_3        = "agent"
  node_3_type   = "t3.small"
  node_3_key    = "${local.shared_key}"
  node_3_sg     = "sg-06fee69cc7e0d7d21"
  node_3_ip     = "172.31.10.12"

  node_4        = "nexus"
  node_4_type   = "t3.medium"
  node_4_key    = "${local.shared_key}"
  node_4_sg     = "sg-038f08cad7d914658"
  node_4_ip     = "172.31.10.13"
  # Check aws_instance.nexus for volume size

  node_5        = "jenkins"
  node_5_type   = "t3.medium"
  node_5_key    = "${local.shared_key}"
  node_5_sg     = "sg-08b43188576777032"
  node_5_ip     = "172.31.10.20"
  # Check aws_instance.nexus for volume size
}

resource "aws_instance" "control" {
  ami                    = "${local.ami}"
  subnet_id              = "${local.shared_subnet}"
  instance_type          = "${local.node_1_type}"  
  key_name               = "${local.node_1_key}"
  private_ip             = "${local.node_1_ip}"  
  vpc_security_group_ids = [
    "${local.node_1_sg}",
    "${local.shared_sg}"
  ]
  iam_instance_profile   = "s3-artifacti-storage-role"   
  user_data = data.cloudinit_config.scripts.rendered 
  tags      = merge ({Name = "${local.common_tags.Project}-${local.node_1}"}, local.common_tags)
}

resource "aws_instance" "tomcat" {
  ami                    = "${local.ami}"
  subnet_id              = "${local.shared_subnet}"
  instance_type          = "${local.node_2_type}" 
  key_name               = "${local.node_2_key}"
  private_ip             = "${local.node_2_ip}"
  vpc_security_group_ids = [
                           "${local.node_2_sg}",
                           "${local.shared_sg}"
  ]  
  tags = merge ({Name = "${local.common_tags.Project}-${local.node_2}"}, local.common_tags)
}

resource "aws_instance" "agent" {
  ami                    = "${local.ami}"
  subnet_id              = "${local.shared_subnet}"
  instance_type          = "${local.node_3_type}" 
  key_name               = "${local.node_3_key}"
  private_ip             = "${local.node_3_ip}"
  vpc_security_group_ids = [
                           "${local.node_3_sg}",
                           "${local.shared_sg}"
  ]  
  tags = merge ({Name = "${local.common_tags.Project}-${local.node_3}"}, local.common_tags)
}

resource "aws_instance" "nexus" {
  ami                    = "${local.ami}"
  subnet_id              = "${local.shared_subnet}"
  instance_type          = "${local.node_4_type}" 
  key_name               = "${local.node_4_key}"
  private_ip             = "${local.node_4_ip}"
  vpc_security_group_ids = [
                           "${local.node_4_sg}",
                           "${local.shared_sg}"
  ]
  ebs_block_device {
    device_name = "/dev/sda1" # default name
    volume_size = 20
  }
  iam_instance_profile   = "s3-artifacti-storage-role"  
  tags = merge ({Name = "${local.common_tags.Project}-${local.node_4}"}, local.common_tags)
}

resource "aws_instance" "jenkins" {
  ami                    = "${local.ami}"
  subnet_id              = "${local.shared_subnet}"
  instance_type          = "${local.node_5_type}" 
  key_name               = "${local.node_5_key}"
  private_ip             = "${local.node_5_ip}"
  vpc_security_group_ids = [
                           "${local.node_5_sg}",
                           "${local.shared_sg}"
  ]
  ebs_block_device {
    device_name = "/dev/sda1" # default name
    volume_size = 20
  }
  iam_instance_profile   = "s3-artifacti-storage-role"  
  tags = merge ({Name = "${local.common_tags.Project}-${local.node_5}"}, local.common_tags)
}

output "public_ip" {
  description = "Hosts public IP:"
  value       = tomap({
    "control" = aws_instance.control.public_ip,
    "tomcat"  = aws_instance.tomcat.public_ip,
    "agent"   = aws_instance.agent.public_ip,
    "nexus"   = aws_instance.nexus.public_ip,
    "jenkins" = aws_instance.jenkins.public_ip
  })  
}

# output "private_ip" {
#   description = "Hosts public IP:"
#   value       = tomap({
#     "control" = aws_instance.control.private_ip,
#     "tomcat"  = aws_instance.tomcat.private_ip,
#     "agent"   = aws_instance.agent.private_ip,
#     "nexus"   = aws_instance.nexus.private_ip,
#     "jenkins" = aws_instance.jenkins.private_ip
#   })  
# }

data "cloudinit_config" "scripts" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "01_hosts.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("01_hosts.sh", {
      node_1_ip  = local.node_1_ip,
      node_2_ip  = local.node_2_ip,
      node_3_ip  = local.node_3_ip,
      node_4_ip  = local.node_4_ip,
      node_5_ip  = local.node_5_ip
    })
  }

  part {
    filename     = "02_playbook.sh"
    content_type = "text/x-shellscript"
    content      = file("02_playbook.sh")
  }

  part {
    filename     = "03_init-control.sh"
    content_type = "text/x-shellscript"
    content      = file("03_init-control.sh")
  }

  part {
    filename     = "04_init-docker.sh"
    content_type = "text/x-shellscript"
    content      = file("04_init-docker.sh")
  }

  part {
    filename     = "05_init-agent.sh"
    content_type = "text/x-shellscript"
    content      = file("05_init-agent.sh")
  }

  part {
    filename     = "06_init-tools.sh"
    content_type = "text/x-shellscript"
    content      = file("06_init-tools.sh")
  }

  part {
    filename     = "07_init-tomcat9.sh"
    content_type = "text/x-shellscript"
    content      = file("07_init-tomcat9.sh")
  }

  part {
   filename     = "08_ansible-install.sh"
   content_type = "text/x-shellscript"
   content      = file("08_ansible-install.sh")
  }

  part {
    filename     = "09_ssh-keys.sh"
    content_type = "text/x-shellscript"
    content      = file("09_ssh-keys.sh")
  }

  part {
    filename     = "10_start.sh"
    content_type = "text/x-shellscript"
    content      = file("10_start.sh")
  }
}