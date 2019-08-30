locals {
  # below is a workarround for this bug: https://github.com/hashicorp/terraform/issues/21917 
  # once it is fixed this can be tidied up
  code = var.automate_module != "" ? var.automate_module : jsonencode({"url" = [var.automate_url], "token" = [var.automate_token]})

  populate_script = templatefile("${path.module}/templates/populate_file", {
    data             = local.code,
    tmp_path         = var.tmp_path,
    jq_linux_url     = var.jq_linux_url,
    enabled_profiles = var.enabled_profiles
  })
}

resource "null_resource" "populate_chef_server" {

  triggers = {
    profiles = md5(jsonencode(var.enabled_profiles))
  }

  connection {
    user        = var.user_name
    password    = var.user_pass
    private_key = var.user_private_key != "" ? file(var.user_private_key) : null
    host        = var.ip
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.tmp_path}"
    ]
  }

  provisioner "file" {
    content     = local.populate_script
    destination = "${var.tmp_path}/${var.populate_script_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash ${var.tmp_path}/${var.populate_script_name}"
    ]
  }
}
