###############################################################################
##     .d88b                 8            w          .d88b. 88888    db      ##
##     8P    .d8b. 8d8b .d88 8 .d8b. .d88 w Yb dP    YPwww.   8     dPYb     ##
##     8b    8' .8 8    8  8 8 8' .8 8  8 8  `8.         d8   8    dPwwYb    ##
##     `Y88P `Y8P' 8    `Y88 8 `Y8P' `Y88 8 dP Yb    `Y88P'   8   dP    Yb   ##
##                                   wwdP                                    ##
###############################################################################

# ---------------- Coralogix Account -------------------------------------------
PrivateKey                = "229254e4-d2cd-07b9-b980-14ddb3da613f"
CompanyID                 = "30188"
ApplicationName           = "sta-spot-test"   # Logical name for the Coralogix account
CoralogixEndpoint         = "Europe"           # Can be 'Europe', 'Europe2', 'India, 'Singapore' or 'US'
CreateCustomEnrichment    = false         # Automatically insert the correct JSON keys for enrichment in Coralogix (Boolean)
AlertsPrivateKey          = "15e1b457-c3ca-4e24-b986-283eed547f31"           # The 'Alerts, Rules and Tags' API Key

# ------------------ AWS Account -----------------------------------------------
SubnetId                  = "subnet-04bb5267196323c98"
SSHKey                    = "ireland"           # SSH key name to connect to the STA (without the '.pem')
ConfigS3BucketName        = ""           # S3 bucket name to store the configurations - By default if no bucket provided, the stack will create one
MgmtNicSecurityGroupID    = ""           # Optional - if not provided, a security group with the user's public IP will be used for SSH
PacketsS3BucketRequired   = false        # Optional - if true, will use the provided bucket to save the network packets. if no bucket provided in 'PacketsS3Bucket' variable, the stack will create one
PacketsS3Bucket           = ""
tags                      = {
#  example_key = "example value"
  Owner = "Nir Limor"
}

# ----------------- STA Instance -----------------------------------------------
STASize                   = "large"           # Can be 'small', 'medium' or 'large'
STALifecycle              = "spotfleet"           # Can be 'ondemand' or 'spotfleet'
ElasticIpRequired         = true         # Boolean
WazuhRequired             = true         # Boolean
AllowSTAToTagInstances    = false        # Allow the STA to automatically tag existing instances and mirror their traffic yes(Boolean)

# ------- Instance additional configurations -----------------------------------
STA-small-pool            = ""           # Optional - The default is "c5.2xlarge". Can also be "c5d.2xlarge", "c5a.2xlarge", "c5n.2xlarge", "r5.2xlarge" or "m5.2xlarge"
STA-medium-pool           = ""           # Optional - The default is "c5.4xlarge" Can also be "c5d.4xlarge", "c5a.4xlarge", "c5n.4xlarge", "r5.4xlarge" or "m5.4xlarge"
STA-large-pool            = ""           # Optional - The default is "c5.9xlarge" Can also be "m6g.8xlarge", "r5a.8xlarge", "m5n.8xlarge", "m4.10xlarge", "r5.8xlarge" or "m5.8xlarge"
SpotPrice                 = 0.5          # Number. Must be more than 0
DiskSize                  = 250          # Number. Can be 250, 334, 500, 750, 1000 or 5334
EncryptDisk               = false        # Boolean
DiskType                  = "gp3"        # Defaults to gp2



