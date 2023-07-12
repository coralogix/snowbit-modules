variable "PrivateKey" {}
variable "CompanyID" {}
variable "ApplicationName" {}
variable "Endpoint" {}
variable "Azure-KeyManager" {}
variable "SSHKeyResourceGroup" {}
variable "Azure-SSHKeyResourceGroup" {}
variable "SSHKey" {}
variable "Prefix" {}
variable "DiskSize" {}
variable "Azure-Region" {}
variable "STA-Version" {}
variable "storageAccountResourceGroup" {}
variable "storageAccount" {}
variable "storageContainer" {}


module "STA" {
  source = "https://coralogix-integrations.s3-eu-west-1.amazonaws.com/cloud-security/terraform-azure/snowbit-sta.template.tgz"

  Azure-Region                      = var.Azure-Region
  Coralogix-PrivateKey              = var.PrivateKey
  Coralogix-CompanyID               = var.CompanyID
  Coralogix-ApplicationName         = var.ApplicationName
  Coralogix-Endpoint                = var.Endpoint
  Azure-SSHKeyName                  = file(var.SSHKey)
  Azure-KeyManager                  = var.Azure-KeyManager
  Azure-SSHKeyResourceGroup         = var.Azure-SSHKeyResourceGroup
  Azure-DiskSize                          = var.DiskSize
  Azure-Prefix                            = var.Prefix
  STA-Version                       = var.STA-Version
  Azure-StorageAccountResourceGroup = var.storageAccountResourceGroup
  Azure-StorageAccount              = var.storageAccount
  Azure-StorageContainer            = var.storageContainer
}
output "General" {
  value = module.STA.General
}
output "Azure" {
  value = module.STA.Instance_and_Permissions
}