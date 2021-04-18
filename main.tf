locals {
  tmp_dir         = "${path.cwd}/.tmp"
  crn_file_name   = "${local.tmp_dir}/endpoint-gateway-targets.json"
  endpoint_target = jsondecode(data.local_file.endpoint-target.content)
  prefix_name       = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name              = lower(replace("${local.prefix_name}-vpe-${var.resource_label}", "_", "-"))
}

resource null_resource setup {
  provisioner "local-exec" {
    command = "mkdir -p ${local.tmp_dir}"
  }
  provisioner "local-exec" {
    command = "echo 'Resource group name: ${var.resource_group_name}'"
  }
  provisioner "local-exec" {
    command = "echo 'Resource crn: ${var.resource_crn}'"
  }
}

resource null_resource get-endpoint-target {
  depends_on = [null_resource.setup]

  provisioner "local-exec" {
    command = "${path.module}/scripts/get-endpoint-target.sh ${var.resource_crn} ${var.resource_service} ${var.region} ${var.resource_group_name} ${local.crn_file_name}"

    environment = {
      IBMCLOUD_API_KEY = var.ibmcloud_api_key
      TMP_DIR          = local.tmp_dir
    }
  }
}

data local_file endpoint-target {
  depends_on = [null_resource.get-endpoint-target]

  filename = local.crn_file_name
}

data ibm_resource_group resource_group {
  depends_on = [null_resource.setup]

  name = var.resource_group_name
}

data ibm_is_subnet subnets {
  count = var.vpc_subnet_count

  identifier = var.vpc_subnets[count.index].id
}

resource time_sleep wait_for_resource_initialization {
  depends_on = [null_resource.setup]

  create_duration = "5m"
}

resource ibm_is_virtual_endpoint_gateway vpe-gateway {
  depends_on = [time_sleep.wait_for_resource_initialization]

  name           = local.name
  vpc            = var.vpc_id
  resource_group = data.ibm_resource_group.resource_group.id
  tags           = [var.resource_label]

  target {
    crn           = local.endpoint_target.crn
    resource_type = local.endpoint_target.resource_type
  }

  # One reserved IP per zone in the VPC in the VPE subnets
  dynamic "ips" {
    for_each = {for subnet in data.ibm_is_subnet.subnets : subnet.id => subnet}
    content {
      subnet = ips.key
      name = "${ips.value.name}-${var.resource_label}"
    }
  }
}
