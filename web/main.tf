data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "mytf-state"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_security_group" "sg_allow_http" {
    name        = "allow_http"
    description = "Allow http inbound traffic"
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "template_file" "userdata" {
  template = "${file("userdata.tpl")}"

  vars {
    http_proxy = "http://127.0.0.1:8888/"
  }
}


data "aws_ami" "my-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ami-web*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "iac_keypair"
  public_key = "${file("~/.ssh/id_rsa.iac.pub")}"
}

resource "aws_elb" "my_elb" {
  name            = "terraform-elb"
  subnets         = ["${data.terraform_remote_state.vpc.subnet_id}"]
  security_groups = ["${aws_security_group.sg_allow_http.id}"]
  

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

 health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/"
    interval            = 5
  }
}

resource "aws_launch_configuration" "my_launch_config" {
  name_prefix     = "web-asg"
  image_id        = "${data.aws_ami.my-ami.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.sg_allow_http.id}"]
  key_name        = "${aws_key_pair.my_keypair.id}"
  user_data       = "${data.template_file.userdata.rendered}"
  lifecycle {
       create_before_destroy = "true"
  }
}

resource "aws_autoscaling_group" "my_asg" {
  vpc_zone_identifier       = ["${data.terraform_remote_state.vpc.subnet_id}"]
  name                      = "asg-${aws_launch_configuration.my_launch_config.name}"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.my_launch_config.name}"
  load_balancers            = ["${aws_elb.my_elb.id}"]


  tags = [
    {
      key                 = "Name"
      value               = "autoscaledserver"
      propagate_at_launch = true
    }
  ]
  lifecycle {
    create_before_destroy = "true"
  }
}
