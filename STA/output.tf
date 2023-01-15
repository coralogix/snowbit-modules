output "Coralogix-Private-Key" {
  value = var.PrivateKey
  sensitive = true
}
output "Coralogix-Company-ID" {
  value = var.CompanyID
}
output "Coralogix-Application-Name" {
  value = var.ApplicationName
}
output "STA-Instance-Type" {
  value = var.STASize == "small" ? local.instance_type_validation_small : var.STASize == "medium" ? local.instance_type_validation_medium : local.instance_type_validation_large
}
output "STA-Instance-Lifecycle" {
  value = var.STALifecycle == "ondemand" ? "On-Demand" : "Spot Fleet"
}
output "STA-Instance-Created-Elastic-IP" {
  value = var.ElasticIpRequired == true ? "Yes" : "No"
}
output "STA-Deployed-Wazuh" {
  value = var.WazuhRequired == true ? "Yes" : "No"
}
output "AWS-Additional-Tags" {
  value = var.tags
}
output "STA-Instance-Config-S3-Bucket" {
  value = length(var.ConfigS3BucketName) > 0 ? "Used the user provided bucket '${var.ConfigS3BucketName}'" : "Created new bucket called '${aws_s3_bucket.STAConfigBucket[0].id}'"
}
output "STA-Instance-SSH-Key-name" {
  value = var.SSHKey
}
output "STA-Instance-Disk-Size" {
  value = var.DiskSize
}
output "STA-Instance-Encrypt-Disk" {
  value = var.EncryptDisk == "true" ? "Yes" : "No"
}
output "STA-Instance-Disk-Type" {
  value = var.DiskType
}
output "STA-Instance-Subnet-Id" {
  value = var.SubnetId
}
output "STA-Instance-Management-Security_Group" {
  value = length(var.MgmtNicSecurityGroupID) > 0 ? "Used the user provided security group '${data.aws_security_group.user-provided-sg[0].name}'" : "Created a new secuirty group called '${var.WazuhRequired == true ? aws_security_group.management-sg-Wazuh[0].name : aws_security_group.management-sg-NoWazuh[0].name}', and allowing SSH access from ${data.http.external-ip-address.response_body}/32"
}
output "Coralogix-Endpoint" {
  value = "${var.CoralogixEndpoint} with the address of ${lookup(var.CoralogixEndpointMap, var.CoralogixEndpoint)}"
}
output "Spot-Price" {
  value = var.STALifecycle == "spotfleet" ? aws_spot_fleet_request.STASpotRequest[0].spot_price : "Not applicable"
}
output "STA-Packet-S3-Bucket" {
  value = var.PacketsS3BucketRequired == false ? "Not Required" : length(var.PacketsS3Bucket) > 0 ? "Required, with user provided bucket - ${var.PacketsS3Bucket}" : "Required, terraform will create a bucket"
}
output "Coralogix-Enrichment" {
  value = var.CreateCustomEnrichment == false ? "Disabled by user" : length(var.AlertsPrivateKey) == 0 ? "Coralogix enrichment was requested, but the 'Alerts' API key wasn't provided"  : "Coralogix suspicious IP enrichment will be implemented"
}
output "STA-Instance-chosen-size" {
  value = var.STASize
}
