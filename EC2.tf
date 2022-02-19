#Ubuntu_jumphost

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "nginx_public" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public-subnet.id
  #user_data              = file("./scripts/nginx.sh")
  vpc_security_group_ids = [aws_security_group.public.id]
  key_name               = aws_key_pair.demo.key_name
  tags = {
    Name = "${var.prefix}-nginx_public"
    Environment = "${var.prefix}-terraform"
  }
}

#NGINX_App_Protect

resource "aws_instance" "nginx_WAF" {
  #NGINX Plus with NGINX App Protect Premium - Ubuntu 18.04
  ami                    = "ami-0e141c47b1e88c8aa"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public-subnet.id
  #user_data             = file("./scripts/nginx.sh")
  vpc_security_group_ids = [aws_security_group.public.id]
  key_name               = aws_key_pair.demo.key_name
  tags = {
    Name = "${var.prefix}-nginx_WAF"
    Environment = "${var.prefix}-terraform"
  }
}

#F5 instance


resource "random_string" "password" {
  length      = 10
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}

data "template_file" "user_data_vm0" {
  template = file("scripts/f5_onboard.tmpl")
  vars = {
    bigip_username         = var.f5_username
    ssh_keypair            = fileexists("~/.ssh/id_rsa.pub") ? file("~/.ssh/id_rsa.pub") : ""
    aws_secretmanager_auth = false
    bigip_password         = random_string.password.result
    INIT_URL               = "https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.2.1/dist/f5-bigip-runtime-init-1.2.1-1.gz.run",
    DO_URL                 = var.DO_URL
    DO_VER                 = var.DO_VER
    AS3_URL                = var.AS3_URL
    AS3_VER                = var.AS3_VER
    TS_URL                 = var.TS_URL
    TS_VER                 = var.TS_VER
    CFE_URL                = var.CFE_URL
    CFE_VER                = var.CFE_VER
    FAST_URL               = var.FAST_URL
    FAST_VER               = var.FAST_VER
  }
depends_on = [random_string.password]
}

module bigip {
  source                 = "F5Networks/bigip-module/aws"
  count                  = 1
  f5_ami_search_name     = var.f5_ami_search_name
  f5_username            = var.f5_username
  f5_password            = random_string.password.result
  prefix                 = "bigip-aws-1nic"
  ec2_instance_type	     = "m5.large"
  ec2_key_name           = aws_key_pair.demo.key_name
  mgmt_subnet_ids        = [{ "subnet_id" = aws_subnet.public-subnet.id, "public_ip" = true, "private_ip_primary" =  "10.0.2.100"}]
  mgmt_securitygroup_ids = [aws_security_group.public.id]
  custom_user_data       = data.template_file.user_data_vm0.rendered
  DO_URL                 = var.DO_URL
  AS3_URL                = var.AS3_URL
  TS_URL                 = var.TS_URL
  FAST_URL               = var.FAST_URL
  CFE_URL	               = var.CFE_URL
}




/*
resource "aws_instance" "nginx_private" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private-subnet.id
  #user_data              = file("./scripts/nginx.sh")
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = aws_key_pair.demo.key_name
  tags = {
    Name = "${var.prefix}-nginx_private"
    Environment = "${var.prefix}-terraform"
  }

}*/

