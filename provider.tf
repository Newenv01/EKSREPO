provider "aws" {
   region     =  "${var.AMIS}"
   access_key =  "${var.ACC}"
   secret_key =  "${var.SEC}"
}

data "aws_regions" "current" {}

provider "http" {}