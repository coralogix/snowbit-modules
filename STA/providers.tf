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
  api_key = length(var.AlertsPrivateKey) > 0 ? var.AlertsPrivateKey : "11111111-1111-1111-1111-111111111111"
  env     = lookup(var.env_map, var.CoralogixEndpoint)
}