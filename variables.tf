################## connection #####################

variable "ip" {
  description = "An ip address where we will stage api calls to the automate server"
  type        = string
  default     = ""
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
  type        = string
  default     = ""
}

############ misc ###############################

variable "working_directory" {
  description = "The path to use for the working directory"
  type        = string
  default     = "chef_automate_populate"
}

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

variable "ds_script_name" {
  description = "The name to give to the populate data source script"
  type        = string
  default     = "populate_data_source.sh"
}

variable "populate_script_name" {
  description = "The name to give the chef automate populate script"
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
  description = "The jsonencoded output of the https://registry.terraform.io/modules/srb3/chef-automate/linux module. If you are not using this module then you need to specify automate_token and automate_url"
  type       = string
  default    = ""
}

variable "local_automate" {
  description = "Set to false if this module will be connecting to a host that is not running chef automate"
  type        = bool
  default     = true
}

variable "proxy_string" {
  description = "If needed set a proxy server details in this variable"
  type        = string
  default     = ""
}

variable "no_proxy_string" {
  description = "If needed set the no_proxy details in this variable"
  type        = string
  default     = ""
}
