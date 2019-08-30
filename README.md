# Overview
This module will connect to any ssh enabled server and run commands against an automate server via curl.
It expects that curl and wget are already installed. Currently the module only supports enabling profiles in chef automate. 

#### Supported platform families:
  * Debian
  * RHEL
  * SUSE

## Usage

```hcl

module "populate_chef_automate" {
  source               = "devoptimist/chef-automate-populate/linux"
  version              = "0.0.1"
  ips                  = "172.16.0.23"
  ssh_user_name        = "ec2-user"
  enabled_profiles     = var.enabled_profiles # see  Map/List Variable examples
  automate_url         = var.automate_url
  automate_token       = var.automate_token
  ssh_user_private_key = "~/.ssh/id_rsa"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|ip|The ip of an ssh enabled server|string|[]|no|
|user_name|The ssh user name used to access the ip addresses provided|string||yes|
|user_pass|The ssh user password used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)|string|""|no|
|user_private_key|The ssh user key used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)|string|""|no|
|tmp_path|The path to use as the upload destination for any executabl scripts that need to be run|string|/var/tmp|no|
|populate_script_name|The name to give the chef automate populate script|string|automate_server_populate.sh|no|
|automate_url|The url to a chef automate server|string||yes|
|automate_token|The api token for a chef automate server|string||yes|
|enabled_profiles|A list of Maps used to enable inspec profiles from the chef automate market place|list|[]|no|

## Map/List Variable examples (for tfvars file)

### berksfiles

```hcl
enabled_profiles = [
  {
    "name" = "cis-rhel7-level1-server",
    "version" = "latest",
    "owner" = "admin"
  },
  {
    "name" = "cis-sles11-level1",
    "version" = "1.1.0-7",
    "owner" = "admin"
  }
]
```
