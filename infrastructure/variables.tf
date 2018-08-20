variable "product" {
  type    = "string"
}

variable "component" {
  type = "string"
}

variable "location_app" {
  type    = "string"
  default = "UK South"
}

variable "env" {
  type = "string"
}

variable "ilbIp" {}

variable "subscription" {}

variable "capacity" {
  default = "1"
}

variable "common_tags" {
  type = "map"
}




variable "location" {
  type    = "string"
  default = "UK South"
}

variable "source_range" {
  type = "string"
}

variable "source_range_index" {}

variable "vnet_rg_name" {
  type = "string"
}

variable "vnet_name" {
  type = "string"
}

variable "publisher_email" {
  type    = "string"
  default = "papi-mangement@hmcts.net"
}

variable "publisher_name" {
  type    = "string"
  default = "HMCTS Reform Platform Professional API"
}

variable "notification_sender_email" {
  type    = "string"
  default = "professional-api-noreply@mail.windowsazure.com"
}





variable api_gateway_test_certificate_thumbprint {
  type = "string"
  default = ""
}


