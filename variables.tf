################## connection #####################

variable "ip" {
  description = "An ip addresses where we will stage pushes to the chef server (pushes include roles, environments, policyfiles, policygroups, cookbooks"
  type        = string
}

variable "user_name" {
  description = "The ssh user name used to access the ip addresses provided" 
  type        = string
}

variable "user_pass" {
  description = "The ssh user password used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = string
  default     = ""
}

variable "user_private_key" {
  description = "The ssh user key used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = "string"
  default     = ""
}

############ misc ###############################

variable "jq_linux_url" {
  description = "A url to a jq binary to download, used in the install process"
  type        = string
  default     = "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
}

variable "tmp_path" {
  description = "The path to use as the upload destination for any executabl scripts that need to be run"
  type        = string
  default     = "/var/tmp"
}

variable "populate_script_name" {
  description = "The name to give the chef server populate script"
  type        = string
  default     = "automate_server_populate.sh"
}

############ populate automate options ############

variable "automate_url" {
  description = "The url to a chef automate server"
  type        = string
  default     = ""
}

variable "automate_token" {
  description = "The api token for a chef automate server"
  type        = string
  default     = ""
}

variable "enabled_profiles" {
  description = "A list of Maps used to enable profiles from the chef automate market place"
  type        = list
  default     = []
}

variable "automate_module" {
  description = "The jsonencoded output of the https://registry.terraform.io/modules/devoptimist/chef-automate/linux module. If you are not using this module then you need to specify automate_token and automate_url"
  type       = string
  default    = ""
}
