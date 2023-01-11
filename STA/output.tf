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
  value = var.STALifecycle == "ondemand" ? aws_instance.STAEC2Instance-ondemand[0].instance_type : "Probably ${aws_launch_template.STASpotFleetTemplate[0].instance_type}"
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
  value = length(var.ConfigS3BucketName) > 0 ? "Used the user provided bucket - ${var.ConfigS3BucketName}" : "Created new bucket called ${aws_s3_bucket.STAConfigBucket[0].id}"
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
  value = length(var.MgmtNicSecurityGroupID) > 0 ? "Used the user provided security group - ${var.MgmtNicSecurityGroupID}" : "Created a new secuirty group called ${var.WazuhRequired == true ? aws_security_group.management-sg-Wazuh[0].name : aws_security_group.management-sg-NoWazuh[0].name} and allowing SSH access from ${data.http.external-ip-address.response_body}/32"
}
output "STA-Instance-Packets-S3-Bucket" {
  value = var.PacketsS3Bucket
}
output "Coralogix-Endpoint" {
  value = "${var.CoralogixEndpoint} with the address of ${lookup(var.CoralogixEndpointMap, var.CoralogixEndpoint)}"
}
output "Spot-Price" {
  value = aws_spot_fleet_request.STASpotRequest[0].spot_price
}
