data "http" "workstation_ip_addr" {
      url = "http://ipv4.icanhazip.com"
}

locals {
    workstation-external-cidr = "${chomp(data.http.workstation_ip_addr.body)}/32"
}