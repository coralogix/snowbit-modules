variable "PrivateKey" {
  description = "Coralogix private key"
  type        = string
  validation {
    condition     = can(regex("^\\w{8}\\-(?:(?:\\w{4})\\-){3}\\w{12}", var.PrivateKey))
    error_message = "The private key in not valid"
  }
}
variable "CompanyID" {
  type        = number
  description = "Coralogix company ID"
}
variable "ApplicationName" {
  type        = string
  description = "Coralogix application name"
  default     = "Coralogix-STA-test"
  validation {
    condition     = can(regex("^[A-Za-z0-9-_]{3,50}$", var.ApplicationName))
    error_message = "invalid Application name"
  }
}
variable "STASize" {
  description = "What size of the STA instance is required"
  type        = string
  default     = "medium"
  validation {
    condition     = can(regex("(small|medium|large)", var.STASize))
    error_message = "This size is not supported by this module. Use 'small', 'medium' or 'large'."
  }
}
variable "STA-small-pool" {
  type = string
}
variable "STA-medium-pool" {
  type = string
}
variable "STA-large-pool" {
  type = string
}
variable "STALifecycle" {
  description = "Launch the STA as a Spot or an Ondemand instance"
  type        = string
  default     = "ondemand"
  validation {
    condition     = can(regex("ondemand|spotfleet", var.STALifecycle))
    error_message = "This lifecycle type is not supported by this module. Use 'spotfleet' or 'ondemand'."
  }
}
variable "ElasticIpRequired" {
  type        = bool
  description = "Whether an Elastic IP is required"
}
variable "WazuhRequired" {
  type        = bool
  description = "Whether Wazuh support is required"
}
variable "tags" {}
variable "ConfigS3BucketName" {
  type        = string
  description = "An S3 bucket that holds/will hold the STA config files (optional)"
  default     = ""
  #  validation {
  #    condition = length(var.ConfigS3BucketName) > 3 && can(regex("^[a-z0-9-]+$", var.ConfigS3BucketName))
  #    error_message = "Invalid bucket name"
  #  }
}
variable "PacketsS3Bucket" {
  description = "An S3 bucket that will hold packets captured by this STA instance (optional)"
  type        = string
  default     = ""
}
variable "SSHKey" {
  type = string
}
variable "DiskSize" {
  description = "STA Disk Size - Determines the allowed IOPs rate. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html"
  type        = number
  default     = 250
  validation {
    condition = contains([
      250,
      334,
      500,
      750,
      1000,
      5334
    ], var.DiskSize)
    error_message = "The disk size can only be one of the following: 250, 334, 500, 750, 1000, 5334."
  }
}
variable "EncryptDisk" {
  description = "Whether to encrypt the STA disk"
  type        = bool
  default     = false
}
variable "DiskType" {
  description = "STA Disk Type - Determines the allowed IOPs rate. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html"
  type        = string
  default     = "gp2"
  validation {
    condition     = var.DiskType == "gp2" || var.DiskType == "gp3"
    error_message = "A valid AWS disk type must be specified"
  }
}
variable "SubnetId" {
  description = "The list of SubnetIds in your Virtual Private Cloud (VPC)"
  type        = string
  validation {
    condition     = can(regex("^subnet-\\w{1,20}$", var.SubnetId))
    error_message = "A valid AWS subnet ID must be specified."
  }
}
variable "MgmtNicSecurityGroupID" {
  description = "A security group for the management interface of the Security Traffic Analyzer (STA)"
  type        = string
  validation {
    condition     = var.MgmtNicSecurityGroupID == "" ? true : can(regex("^sg-\\w+", var.MgmtNicSecurityGroupID))
    error_message = "Invalid security group ID"
  }
}
variable "CoralogixEndpoint" {
  type        = string
  default     = "Europe"
  description = "The endpoint of the coralogix account"
  validation {
    condition     = var.CoralogixEndpoint == "Europe" || var.CoralogixEndpoint == "Europe2" || var.CoralogixEndpoint =="India" || var.CoralogixEndpoint =="Singapore" || var.CoralogixEndpoint == "US"
    error_message = "Invalid coralogix region, can be 'Europe', 'Europe2', 'India', 'Singapore' or 'US'"
  }
}
variable "CoralogixEndpointMap" {
  type    = map(string)
  default = {
    Europe    = "coralogix.com"
    Europe2   = "eu2.coralogix.com"
    India     = "app.coralogix.in"
    Singapore = "coralogixsg.com"
    US        = "coralogix.us"
  }
}
variable "AllowSTAToTagInstances" {
  type        = string
  description = "not yet operational"
}
variable "SpotPrice" {
  description = "Spot price for application AutoScaling Group"
  type        = number
  default     = 0.5
  validation {
    condition     = var.SpotPrice > 0
    error_message = "The spot price must be greater than zero."
  }
}
variable "AlertsPrivateKey" {
  type        = string
  description = "The 'Alerts, Rules and Tags' API Key"
  validation {
    condition     = var.AlertsPrivateKey == "" ? true : can(regex("^\\w{8}\\-(?:(?:\\w{4})\\-){3}\\w{12}", var.AlertsPrivateKey))
    error_message = "The private key in not valid"
  }
}
variable "env_map" {
  type    = map(string)
  default = {
    Europe    = "EUROPE1"
    Europe2   = "EUROPE2"
    India     = "APAC1"
    Singapore = "APAC2"
    US        = "USA1"
  }
}
variable "CreateCustomEnrichment" {
  type    = bool
  default = true
}
variable "PacketsS3BucketRequired" {
  type    = bool
  default = false
}
locals {
  # Defining accepted pools for each general size
  small_pool  = ["c5.2xlarge", "c5d.2xlarge", "c5a.2xlarge", "c5n.2xlarge", "r5.2xlarge", "m5.2xlarge"]
  medium_pool = ["c5.4xlarge", "c5d.4xlarge", "c5a.4xlarge", "c5n.4xlarge", "r5.4xlarge", "m5.4xlarge"]
  large_pool  = [
    "c5.9xlarge", "m6g.8xlarge", "r5a.8xlarge", "m5n.8xlarge", "m4.10xlarge", "r5.8xlarge", "m5.8xlarge"
  ]
  # Validating if the provided value in the pool variable is in the corespondent pool (also used for the instance type validation Output)
  small_pool_condition   = var.STASize == "small" && contains(local.small_pool, var.STA-small-pool)
  medium_pool_condition  = var.STASize == "medium" && contains(local.medium_pool, var.STA-medium-pool)
  large_pool_condition   = var.STASize == "large" && contains(local.large_pool, var.STA-large-pool)
  # Selecting the correct value according to the validation ^
  small_pool_validation  = local.small_pool_condition ? var.STA-small-pool : "c5.2xlarge"
  medium_pool_validation = local.medium_pool_condition ? var.STA-medium-pool : "c5.4xlarge"
  large_pool_validation  = local.large_pool_condition  ? var.STA-large-pool : "c5.9xlarge"
  # comparing sizes to values
  final_size             = var.STASize == "small" ? local.small_pool_validation : var.STASize == "medium" ? local.medium_pool_validation : local.large_pool_validation

  # Instance validation for Output "STA-Instance-Type"
  instance_type_validation_small  = local.small_pool_condition ? "User changed default to ${local.final_size}" : var.STASize == "small" && !contains(local.small_pool, var.STA-small-pool) && length(var.STA-small-pool) > 0 ? "::Error:: The provided instance type did not match the allowed pool, using default for ${var.STASize} - ${local.final_size}" : "User didn't provide input, using default - ${local.final_size}"
  instance_type_validation_medium = local.medium_pool_condition ? "User changed default to ${local.final_size}" : var.STASize == "medium" && !contains(local.medium_pool, var.STA-medium-pool) && length(var.STA-medium-pool) > 0 ? "::Error:: The provided instance type did not match the allowed pool, using default for ${var.STASize} - ${local.final_size}" : "User didn't provide input, using default - ${local.final_size}"
  instance_type_validation_large  = local.large_pool_condition ? "User changed default to ${local.final_size}" : var.STASize == "large" && !contains(local.large_pool, var.STA-large-pool) && length(var.STA-large-pool) > 0 ? "::Error:: The provided instance type did not match the allowed pool, using default for ${var.STASize} - ${local.final_size}" : "User didn't provide input, using default - ${local.final_size}"
}