                 ###############################################################################
                 ##     .d88b                 8            w          .d88b. 88888    db      ##
                 ##     8P    .d8b. 8d8b .d88 8 .d8b. .d88 w Yb dP    YPwww.   8     dPYb     ##
                 ##     8b    8' .8 8    8  8 8 8' .8 8  8 8  `8.         d8   8    dPwwYb    ##
                 ##     `Y88P `Y8P' 8    `Y88 8 `Y8P' `Y88 8 dP Yb    `Y88P'   8   dP    Yb   ##
                 ##                                   wwdP                                    ##
                 ###############################################################################

# ------------------------------------------ Coralogix Account -------------------------------------------
PrivateKey                = ""
CompanyID                 = ""
ApplicationName           = ""           # Logical name for the Coralogix account
CoralogixEndpoint         = ""           # See here: https://coralogix.com/docs/coralogix-domain/
CoralogixSyslogEndpoint   = ""           # See here: https://coralogix.com/docs/coralogix-endpoints/

# ----------------------------------------- Azure Account -------------------------------------------------
SSHKey                    = ""           # A file name of a file contains the public key from Azure
Region                    = "East US"    # The Azure region where the STA will be placed

# ------------------------------------------ STA Instance ------------------------------------------------
Prefix                    = ""           # A prefix that will be added to the resources created to prevent 
                                         # duplicate names
STA_Version               = "2.1.168"    # The STA version to install

# -------------------------- STA Instance - Instance additional configurations ----------------------------
DiskSize                  = 250          # Number. Can be 250, 334, 500, 750, 1000 or 5334
