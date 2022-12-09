variable "shell_cmd" {
  type = string
  description = "Command to run a shell"
  default = "bash"
}

variable "kubectl_cmd" {
  type = string
  description = "Kubectl command to use"
  default = "kubectl"
}

variable "resource" {
  type = string
  description = "The target resource. Can be a service, pod, deployment, etc. See kubectl port-forward for more info."
}

variable "target_port" {
  type = number
  description = "Target port number"
}

variable "local_port" {
  type = number
  description = "Local port number"
}

variable "timeout" {
  type = string
  description = "Timeout value ensures tunnel won't remain open forever"
  default = "30m"
}

variable "tunnel_check_sleep" {
  type = string
  description = "extra time to wait for kubectl tunnel to connect"
  default = "0s"
}

variable "external" {
  type = bool
  description = "A flag to quickly disable the terraform managed tunnel to run it manually."
  default = false
}