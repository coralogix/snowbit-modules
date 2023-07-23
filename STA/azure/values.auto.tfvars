                 ###############################################################################
                 ##     .d88b                 8            w          .d88b. 88888    db      ##
                 ##     8P    .d8b. 8d8b .d88 8 .d8b. .d88 w Yb dP    YPwww.   8     dPYb     ##
                 ##     8b    8' .8 8    8  8 8 8' .8 8  8 8  `8.         d8   8    dPwwYb    ##
                 ##     `Y88P `Y8P' 8    `Y88 8 `Y8P' `Y88 8 dP Yb    `Y88P'   8   dP    Yb   ##
                 ##                                   wwdP                                    ##
                 ###############################################################################

# ------------------------------------------ Coralogix Account -------------------------------------------
PrivateKey                  = ""
CompanyID                   = ""
ApplicationName             = ""           # Logical name for the Coralogix account
Endpoint                    = ""           # Can be 'Europe', 'Europe2', 'India, 'Singapore' or 'US'

# ----------------------------------------- Azure Account -------------------------------------------------
Azure-Region                = "Central US" # The Azure region where the STA will be placed
storageAccountResourceGroup = ""           # Azure's Resource Group for Storage Account which holds the STA's configuration
storageAccount              = ""           # Azure's Storage Account which holds the STA's configuration
storageContainer            = ""           # Azure's Storage Container which holds the STA's configuration

## SSH Key
SSHKey                      = ""
Azure-KeyManager            = ""           # can only be 'azure' or 'user'. When using 'user', paste the public key content in the 'Azure-SSHKeyName' variable - should start with 'ssh-rsa '
Azure-SSHKeyResourceGroup   = ""           # Only required when using Azure managed SSH key

# ------------------------------------------ STA Instance ------------------------------------------------
Prefix                      = ""           # A prefix that will be added to the resources created to prevent duplicate names
STA-Version                 = "2.1.233"    # The STA version to install

# -------------------------- STA Instance - Instance additional configurations ----------------------------
DiskSize                    = 250          # Number. Can be 250, 334, 500, 750, 1000 or 5334
