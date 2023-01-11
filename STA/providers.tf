terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"
    }
    coralogix = {
      source  = "coralogix/coralogix"
      version = "1.3.15"
    }
  }
}
provider "coralogix" {
  api_key = var.AlertsPrivateKey
  env     = lookup(var.env_map, var.CoralogixEndpoint)
}