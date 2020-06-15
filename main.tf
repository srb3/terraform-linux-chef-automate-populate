locals {

  tmp_path       = "${var.tmp_path}/${var.working_directory}" 
  ds_script_path = "${local.tmp_path}/${var.ds_script_name}"
  module         = var.automate_module != "" ? jsonencode(var.automate_module) : ""
  # below is a workarround for this bug: https://github.com/hashicorp/terraform/issues/21917 
  # once it is fixed this can be fixed up
  code           = local.module != "" ? local.module : jsonencode({"url" = [var.automate_url], "token" = [var.automate_token]})

  populate_script = [
    for n in range(var.instance_count) : templatefile("${path.module}/templates/populate_file", {
      url              = length(jsondecode(local.code)["url"]) > 0 ? jsondecode(local.code)["url"][n] : ""
      token            = length(jsondecode(local.code)["token"]) > 0 ? jsondecode(local.code)["token"][n] : ""
      tmp_path         = local.tmp_path,
      jq_linux_url     = var.jq_linux_url,
      enabled_profiles = var.enabled_profiles,
      ds_script_path   = local.ds_script_path
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

  depends_on = [null_resource.module_depends_on]
}

data "external" "populate_data" {
  count      = var.instance_count
  program    = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = [null_resource.populate_automate_server]

  query = {
    ssh_user        = element(compact(concat([var.user_name], var.user_names)), count.index)
    ssh_key         = length(compact(concat([var.user_private_key], var.user_private_keys))) > 0 ? element(compact(concat([var.user_private_key], var.user_private_keys)), count.index) : null
    ssh_pass        = length(compact(concat([var.user_pass], var.user_passes))) > 0 ? element(compact(concat([var.user_pass], var.user_passes)), count.index) : null
    target_ip       = element(compact(concat([var.ip], var.ips)), count.index)
    target_script   = local.ds_script_path
  }
}

resource "null_resource" "module_depends_on" {

  triggers = {
    value = length(var.module_depends_on)
  }
}
