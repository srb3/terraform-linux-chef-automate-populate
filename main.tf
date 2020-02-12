locals {

  tmp_path     = "${var.tmp_path}/${var.working_directory}" 
  # below is a workarround for this bug: https://github.com/hashicorp/terraform/issues/21917 
  # once it is fixed this can be fixed up
  code         = var.automate_module != "" ? var.automate_module : jsonencode({"url" = [var.automate_url], "token" = [var.automate_token]})
  module_input = var.module_input != "" ? var.module_input : "no_dependancy"

  populate_script = [
    for n in range(var.instance_count) : templatefile("${path.module}/templates/populate_file", {
      url              = jsondecode(local.code)["url"][n]
      token            = jsondecode(local.code)["token"][n]
      module_input     = local.module_input,
      tmp_path         = local.tmp_path,
      jq_linux_url     = var.jq_linux_url,
      enabled_profiles = var.enabled_profiles
    })
  ]
}

resource "null_resource" "populate_automate_server" {
  count = var.instance_count

  triggers = {
    profiles = md5(jsonencode(var.enabled_profiles))
  }

  connection {
    host        = element(compact(concat([var.ip], var.ips)), count.index)
    user        = element(compact(concat([var.user_name], var.user_names)), count.index)
    password    = length(compact(concat([var.user_pass], var.user_passes))) > 0 ? element(compact(concat([var.user_pass], var.user_passes)), count.index) : null
    private_key = length(compact(concat([var.user_private_key], var.user_private_keys))) > 0 ? file(element(compact(concat([var.user_private_key], var.user_private_keys)), count.index)) : null
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.tmp_path}"
    ]
  }

  provisioner "file" {
    content     = local.populate_script[count.index]
    destination = "${local.tmp_path}/${var.populate_script_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash ${local.tmp_path}/${var.populate_script_name}"
    ]
  }
}

resource "random_string" "module_hook" {
  depends_on       = [null_resource.populate_automate_server]
  count            = var.instance_count
  length           = 16
  special          = true
  override_special = "/@\" "
}

data "null_data_source" "module_hook" {
  inputs = {
    data = jsonencode(random_string.module_hook[*].result)
  }
}
