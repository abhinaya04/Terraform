data "template_file" "npci_squid1" {
  count    = 1
  template = "${file("${path.module}/userdata_squid.tpl")}"
  vars {
    host_eni = "${element(var.npci_middleware_squid_network_interface_id,0)}"
    failover_eni = "${element(var.npci_middleware_squid_network_interface_id,1)}"
    failover_ip = "${element(var.npci_middleware_squid_instance_cidr,1)}"
    change_rt = "${element(var.npci_db_private_rt_id,1)} ${element(var.npci_middleware_private_rt_id,1)} ${element(var.npci_ui_private_rt_id,1)} ${element(var.npci_piwik_public_rt_id,1)}" 
    #change_rt = "${element(var.npci_db_private_rt_id,0)},${element(var.npci_db_opshash_rt_id,0)},${element(var.npci_middleware_private_rt_id,0)},${element(var.npci_opsapp_server_private_rt_id,0)},${element(var.npci_ui_private_rt_id,0)},${element(var.npci_piwik_public_rt_id,0)}"
  }
}


resource "aws_launch_configuration" "npci_squid1_config" {
  count = "1"
  name          = "${var.env}_squid1"
  image_id      = "${data.aws_ami.npci_squid_ami.id}"
  instance_type = "${var.instance_type == "prod_setup" ? var.prod_setup["npci_middleware_squid"] : var.staging_setup["npci_middleware_squid"]}"
  key_name      = "${var.key_name}"
  iam_instance_profile = "${var.role_values["squid"]}"
  associate_public_ip_address = true
  security_groups = ["${var.npci_util_squid_sg_id}","${var.npci_all_sg_id}"]
  user_data     = "${base64encode("${data.template_file.npci_squid1.*.rendered[count.index]}")}"
}

