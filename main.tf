locals {

  tmp_path        = "${var.tmp_path}/${var.working_directory}"
  ds_script_path  = "${local.tmp_path}/${var.ds_script_name}"
  # below is a workarround for this bug: https://github.com/hashicorp/terraform/issues/21917 
  # once it is fixed this can be fixed up
  code            = var.automate_module != "" ? var.automate_module : jsonencode({"url" = var.automate_url, "token" = var.automate_token})
  populate_script = templatefile("${path.module}/templates/populate_file", {
      url              = jsondecode(local.code)["url"]
      token            = jsondecode(local.code)["token"]
      tmp_path         = local.tmp_path,
      jq_linux_url     = var.jq_linux_url,
      enabled_profiles = var.enabled_profiles,
      ds_script_path   = local.ds_script_path,
      local_automate   = var.local_automate,
      proxy_string     = var.proxy_string,
      no_proxy_string  = var.no_proxy_string
  })
}

resource "null_resource" "populate_automate_server" {

  triggers = {
    profiles = md5(jsonencode(var.enabled_profiles))
  }

  connection {
    host        = var.ip
    user        = var.user_name
    password    = var.user_pass != "" ? var.user_pass : null
    private_key = var.user_private_key != "" ? file(var.user_private_key) : null
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.tmp_path}"
    ]
  }

  provisioner "file" {
    content     = local.populate_script
    destination = "${local.tmp_path}/${var.populate_script_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash ${local.tmp_path}/${var.populate_script_name}"
    ]
  }

}

data "external" "populate_data" {
  program    = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = [null_resource.populate_automate_server]

  query = {
    ssh_user        = var.user_name != "" ? var.user_name : null
    ssh_key         = var.user_private_key != "" ? var.user_private_key : null
    ssh_pass        = var.user_pass != "" ? var.user_pass : null
    target_ip       = var.ip != "" ? var.ip : null
    target_script   = local.ds_script_path
  }
}
