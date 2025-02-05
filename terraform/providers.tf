provider "aws" {
  alias = "france"
  region = var.aws_regions["france"]
}

provider "aws" {
  alias = "germany"
  region = var.aws_regions["germany"]
}

provider "aws" {
  alias = "us"
  region = var.aws_regions["us"]
}