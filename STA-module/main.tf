variable "PrivateKey" {}
variable "CompanyID" {}
variable "ApplicationName" {}
variable "CoralogixEndpoint" {}
variable "AlertsPrivateKey" {}
variable "SubnetId" {}
variable "SSHKey" {}
variable "ConfigS3BucketName" {}
variable "MgmtNicSecurityGroupID" {}
variable "PacketsS3BucketRequired" {}
variable "PacketsS3Bucket" {}
variable "tags" {}
variable "STASize" {}
variable "STALifecycle" {}
variable "ElasticIpRequired" {}
variable "WazuhRequired" {}
variable "STA-size-pool" {}
variable "SpotPrice" {}
variable "DiskSize" {}
variable "EncryptDisk" {}
variable "DiskType" {}
variable "CreateCustomEnrichment" {}

module "STA" {
  source = "../STA"

  PrivateKey              = var.PrivateKey
  CompanyID               = var.CompanyID
  ApplicationName         = var.ApplicationName
  CoralogixEndpoint       = var.CoralogixEndpoint
  AlertsPrivateKey        = var.AlertsPrivateKey
  SubnetId                = var.SubnetId
  SSHKey                  = var.SSHKey
  ConfigS3BucketName      = var.ConfigS3BucketName
  MgmtNicSecurityGroupID  = var.MgmtNicSecurityGroupID
  PacketsS3BucketRequired = var.PacketsS3BucketRequired
  PacketsS3Bucket         = var.PacketsS3Bucket
  tags                    = var.tags
  STASize                 = var.STASize
  STALifecycle            = var.STALifecycle
  ElasticIpRequired       = var.ElasticIpRequired
  WazuhRequired           = var.WazuhRequired
  STA-size-pool           = var.STA-size-pool
  SpotPrice               = var.SpotPrice
  DiskSize                = var.DiskSize
  EncryptDisk             = var.EncryptDisk
  DiskType                = var.DiskType
}

output "Coralogix-Private-Key" {
  value     = module.STA.Coralogix-Private-Key
  sensitive = true
}
output "Coralogix-Company-ID" {
  value = module.STA.Coralogix-Company-ID
}
output "Coralogix-Application-Name" {
  value = module.STA.Coralogix-Application-Name
}
output "STA-Instance-Type" {
  value = module.STA.STA-Instance-Type
}
output "STA-Instance-Lifecycle" {
  value = module.STA.STA-Instance-Lifecycle
}
output "STA-Instance-Created-Elastic-IP" {
  value = module.STA.STA-Instance-Created-Elastic-IP
}
output "STA-Deployed-Wazuh" {
  value = module.STA.STA-Deployed-Wazuh
}
output "AWS-Additional-Tags" {
  value = module.STA.AWS-Additional-Tags
}
output "STA-Instance-Config-S3-Bucket" {
  value = module.STA.STA-Instance-Config-S3-Bucket
}
output "STA-Instance-SSH-Key-name" {
  value = module.STA.STA-Instance-SSH-Key-name
}
output "STA-Instance-Disk-Size" {
  value = module.STA.STA-Instance-Disk-Size
}
output "STA-Instance-Encrypt-Disk" {
  value = module.STA.STA-Instance-Encrypt-Disk
}
output "STA-Instance-Disk-Type" {
  value = module.STA.STA-Instance-Disk-Type
}
output "STA-Instance-Subnet-Id" {
  value = module.STA.STA-Instance-Subnet-Id
}
output "STA-Instance-Management-Security_Group" {
  value = module.STA.STA-Instance-Management-Security_Group
}
output "Coralogix-Endpoint" {
  value = module.STA.Coralogix-Endpoint
}
output "Spot-Price" {
  value = module.STA.Spot-Price
}
output "STA-Packet-S3-Bucket" {
  value = module.STA.STA-Packet-S3-Bucket
}
output "Coralogix-Enrichment" {
  value = module.STA.Coralogix-Enrichment
}
output "STA-Instance-chosen-size" {
  value = module.STA.STA-Instance-chosen-size
}
