output "Coralogix" {
  value = {
    Company-ID       = var.Company_ID
    Domain           = "User chose ${var.GRPC_Endpoint} - will send to ${lookup(var.grpc-endpoints-map, var.GRPC_Endpoint)}"
    Application-Name = var.applicationName
    Subsystem-Name   = var.subsystemName
  }
}
output "AWS" {
  value = {
    Instance = {
      SSH-Key        = var.SSHKeyName
      Security-Group = length(var.security_group_id) > 0 ? "User provided - ${var.security_group_id}" : "User didn't provide, created new - ${aws_security_group.CSPMSecurityGroup[0].id}"
      EBS-Encrypted  = var.ebs_encryption == true ? "Yes" : "No"
      Public-Access  = var.public_instance == true ? "Yes" : "No"
      Instance-Type  = var.instanceType
      Disk-Type      = aws_instance.cspm-instance.root_block_device[0].volume_type
    }
    VPC-ID                                = data.aws_subnet.subnet.vpc_id
    Subnet-ID                             = var.Subnet_ID
    Additional-Tags                       = var.additional_tags
    Role-ARNs-to-scan-additional-accounts = length(var.multiAccountsARNs) > 0 ? "Provided" : "Not provided"
  }
}
output "CSPM" {
  value = {
    Tester-List = length(var.TesterList) > 0 ? var.TesterList : "No explicit tester was given, scanning all"
    Region-List = length(var.RegionList) > 0 ? var.RegionList : "No explicit region was given, scanning all"
  }
}