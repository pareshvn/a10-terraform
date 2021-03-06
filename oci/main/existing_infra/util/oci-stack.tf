variable "tenancy_ocid" {
  description = "Tenancy OCID"
}

variable "count_vm" {
  description = "count of vm"
}

variable "vThunder__image_ocid" {
  description = "vThunder image OCID"
}

variable "user_ocid" {
  description = "User OCID"
}

variable "compartment_id" {
  description = "Compartment OCID"
}

variable "dynamic_group_name" {
  description = "Dynamic group name on OCI cloud"
}

variable "policy_name" {
  description = "Policy name on OCI cloud"
}

variable "app_display_name" {
  description = "app display name"
}

variable "region" {
  description = "Region"
}
variable "private_key_path" {
  description = "Private key file path"
}
variable "private_key_password" {
  description = "Private Key Password"
}

variable "fingerprint" {
  description = "fingerprint"
}

variable "vm_availability_domain" {
  description = "VM availability domain"
}

variable "vm_display_name" {
  description = "VM display name"
}

variable "vm_shape" {
  description = "VM shape"
}

variable "vm_primary_vnic_display_name" {
  description = "VM primary VNIC display name"
}

variable "vm_ssh_public_key_path" {
  description = "VM ssh public key file path"
}

variable "vm_creation_timeout" {
  description = "VM creation timeout"
}

variable "server_vnic_private_ip" {
  description = "server VNIC private ip"
}

variable "server_vnic_display_name" {
  description = "server VNIC display name"
}

variable "server_vnic_index" {
  description = "server VNIC index"
}

variable "client_vnic_display_name" {
  description = "client VNIC display name"
}

variable "client_vnic_index" {
  description = "client VNIC index"
}

variable "oci_subnet_id1" {
  description = "oci_subnet_id1"
}

variable "oci_subnet_id2" {
  description = "oci_subnet_id2"
}

variable "oci_subnet_id3" {
  description = "oci_subnet_id3"
}

provider "oci" {
  version              = ">= 3.24.0"
  region               = "${var.region}"
  tenancy_ocid         = "${var.tenancy_ocid}"
  user_ocid            = "${var.user_ocid}"
  fingerprint          = "${var.fingerprint}"
  private_key_path     = "${var.private_key_path}"
  private_key_password = "${var.private_key_password}"
}


module "oci_compute" {
  tenancy_ocid                 = "${var.tenancy_ocid}"
  compartment_id               = "${var.compartment_id}"
  vThunder__image_ocid         = "${var.vThunder__image_ocid}"
  count_vm                     = "${var.count_vm}"
  source                       = "../../../modules/infra/compute"
  oci_subnet_id1               = "${var.oci_subnet_id1}"
  oci_subnet_id3               = "${var.oci_subnet_id3}"
  vm_availability_domain       = "${var.vm_availability_domain}"
  vm_shape                     = "${var.vm_shape}"
  vm_creation_timeout          = "${var.vm_creation_timeout}"
  vm_primary_vnic_display_name = "${var.vm_primary_vnic_display_name}"
  vm_ssh_public_key_path       = "${var.vm_ssh_public_key_path}"
  app_display_name             = "${var.app_display_name}"
}


module "dynamic_group" {
  source             = "../../../modules/infra/dynamic_group"
  instance_list      = "${concat([module.oci_compute.instance_id_active], module.oci_compute.instance_list)}"
  tenancy_ocid       = "${var.tenancy_ocid}"
  compartment_id     = "${var.compartment_id}"
  dynamic_group_name = "${var.dynamic_group_name}"
  policy_name        = "${var.policy_name}"
}

module "nic" {
  source                   = "../../../modules/infra/NIC"
  oci_subnet_id2           = "${var.oci_subnet_id2}"
  compartment_id           = "${var.compartment_id}"
  server_vnic_display_name = "${var.server_vnic_display_name}"
  instance_list            = "${module.oci_compute.instance_list}"
  instance_id_active       = "${module.oci_compute.instance_id_active}"
  oci_subnet_id3           = "${var.oci_subnet_id3}"
  client_vnic_display_name = "${var.client_vnic_display_name}"
}

output "vnic_ID" { value = "${module.nic.vnic_id}" }
