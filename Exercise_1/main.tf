# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region                  = "us-east-1"
  profile                 = "default"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity_T2" {
  ami           = "ami-022e1a32d3f742bd8"
  count         = "4"
  instance_type = "t2.micro"
  tags = {
    Name = "Udacity T2"
  }
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
# resource "aws_instance" "Udacity_M4" {
#   ami           = "ami-022e1a32d3f742bd8"
#   count         = "2"
#   instance_type = "m4.large"
#   tags = {
#     Name = "Udacity M4"
#   }
# }