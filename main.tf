provider "aws" {
     //your region
  
}
//CREATE VPC
resource "aws_vpc" "halfway_app" { // halfway_app-->vpc name
  cidr_block = var.vpc_cidr_block //Give CIDR 
}

// Create SUBNET
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.halfway_app
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}"
}
// Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.halfway_app.id
}

// Create Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.halfway_app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

// Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "web_server_sg_tf" {
 name        = "web-server-sg-tf"
 description = "Allow HTTPS to web server"
 vpc_id      = data.aws_vpc.halfway_app.id

ingress {
   description = "HTTPS ingress"
   from_port   = 443
   to_port     = 443
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

# Create a new load balancer
resource "aws_elb" "halfway-elb" {
  name               = "halfway-elb"
  availability_zones = var.region.id

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.halfaway-server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}
resource "aws_instance" "halfaway-server" {
  count         = 2  // Change to the desired number of EC2 instances
  instance_type = "t2.micro"  // Change to your desired instance type
  subnet_id     = var.subnet_id[0]
  security_groups = var.aws_security_group.id
  ami = var.AMI_ID.id
  key_name = "deployer-key"
  // Define other EC2 instance settings like key_name, user_data, etc.
}
resource "aws_route53_record" "halfway_app.external.com" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "halfwayapp.coms"
  type    = "CNAME"
  ttl     = 300
  records = halfaway-elb.id
}