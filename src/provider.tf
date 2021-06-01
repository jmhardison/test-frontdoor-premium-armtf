provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}
/*
provider "azurerm" {
  alias   = "shared_sub"
  subscription_id      = var.Shrd_SubID
  features {}
}
*/

data "azurerm_client_config" "current" {
}

//backend configuration///////////
terraform {
  #lock tf version to 0.14.10 or newer
  required_version = ">=0.14.10"
  #   backend "azurerm" {
  #     storage_account_name = "cldsharedstate"
  #     container_name       = "tf-prod-profitstars-jhlm-azr"
  #     key                  = "prod.new.terraform.tfstate"
  #   }
}