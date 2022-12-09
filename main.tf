data external port_forward {
  program = [
    var.shell_cmd,
    "${path.module}/tunnel.sh"
  ]
  query = {
    timeout = var.timeout
    kubectl_cmd = var.kubectl_cmd
    resource = var.resource
    local_port = var.local_port
    target_port = var.target_port
    shell_cmd = var.shell_cmd
    tunnel_check_sleep = var.tunnel_check_sleep
    external = (var.external ? "y" : "")
  }
}
