data "aws_region" "current" {}
data "aws_caller_identity" "account" {}
data "http" "external-ip-address" {
  url = "http://ifconfig.me"
}
data "aws_subnet" "sta-subnet" {
  id = var.SubnetId
}
data "aws_vpc" "sta-vpc" {
  id = data.aws_subnet.sta-subnet.vpc_id
}
data "aws_security_group" "user-provided-sg" {
  count = length(var.MgmtNicSecurityGroupID) > 0 ? 1 : 0
  id = var.MgmtNicSecurityGroupID
}