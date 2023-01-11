###############################################################################
##     .d88b                 8            w          .d88b. 88888    db      ##
##     8P    .d8b. 8d8b .d88 8 .d8b. .d88 w Yb dP    YPwww.   8     dPYb     ##
##     8b    8' .8 8    8  8 8 8' .8 8  8 8  `8.         d8   8    dPwwYb    ##
##     `Y88P `Y8P' 8    `Y88 8 `Y8P' `Y88 8 dP Yb    `Y88P'   8   dP    Yb   ##
##                                   wwdP                                    ##
###############################################################################

# ---------------- Coralogix Account -------------------------------------------
PrivateKey                = ""
CompanyID                 = ""
ApplicationName           = ""
CoralogixEndpoint         = ""           # Can be 'Europe', 'Europe2', 'India, 'Singapore' or 'US'
AlertsPrivateKey          = ""           # The 'Alerts, Rules and Tags' API Key

# ------------------ AWS Account -----------------------------------------------
SubnetId                  = ""
SSHKey                    = ""           # SSH key name to connect to the STA (without the '.pem')
ConfigS3BucketName        = ""           # S3 bucket name to store the configurations
MgmtNicSecurityGroupID    = ""
tags                      = {
#  example_key = "example value"
}

# ----------------- STA Instance -----------------------------------------------
STASize                   = ""           # Can be 'small', 'medium' or 'large'
STALifecycle              = ""           # Can be 'ondemand' or 'spotfleet'
ElasticIpRequired         = false        # Boolean
WazuhRequired             = false        # Boolean
AllowSTAToTagInstances    = false        # Allow the STA to automatically tag existing instances and mirror their traffic (Boolean)

# ------- Instance additional configurations -----------------------------------
STA-small-pool            = ""           # Can be "c5.2xlarge", "c5d.2xlarge", "c5a.2xlarge", "c5n.2xlarge", "r5.2xlarge" or "m5.2xlarge"
STA-medium-pool           = ""           # Can be "c5.4xlarge", "c5d.4xlarge", "c5a.4xlarge", "c5n.4xlarge", "r5.4xlarge" or "m5.4xlarge"
STA-large-pool            = ""           # Can be "c5.9xlarge", "m6g.8xlarge", "r5a.8xlarge", "m5n.8xlarge", "m4.10xlarge", "r5.8xlarge" or "m5.8xlarge"
SpotPrice                 = ""           # Defaults to 0.5
DiskSize                  = ""           # Defaults to 250
EncryptDisk               = ""           # Defaults to false (Boolean)
DiskType                  = ""           # Defaults to gp2



