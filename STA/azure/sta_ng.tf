variable "PrivateKey" {}
variable "CompanyID" {}
variable "ApplicationName" {}
variable "CoralogixEndpoint" {}
variable "CoralogixSyslogEndpoint" {}
variable "SSHKey" {}
variable "Prefix" {}
variable "DiskSize" {}
variable "Region" {}
variable "STA_Version" {}


module "STA" {
  source = "https://coralogix-integrations.s3-eu-west-1.amazonaws.com/cloud-security/terraform-azure/snowbit-sta.template.tgz"

  Region                  = var.Region
  PrivateKey              = var.PrivateKey
  CompanyID               = var.CompanyID
  ApplicationName         = var.ApplicationName
  CoralogixEndpoint       = var.CoralogixEndpoint
  CoralogixSyslogEndpoint = var.CoralogixSyslogEndpoint
  SSH_PublicKey           = file(var.SSHKey)
  DiskSize                = var.DiskSize
  Prefix                  = var.Prefix
  STA_Version              = var.STA_Version
}
