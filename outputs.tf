output "id" {
  description = "The id of the created VPE gateway"
  value       = ibm_is_virtual_endpoint_gateway.vpe-gateway.id
}

output "sync" {
  description = "Value used to synchronize downstream modules"
  value       = var.resource_service
  depends_on = [ibm_is_virtual_endpoint_gateway.vpe-gateway]
}
