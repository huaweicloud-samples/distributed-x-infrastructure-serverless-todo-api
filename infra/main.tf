terraform {
  required_version = ">= 1.0"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "1.98.2"
    }
  }
}

provider "huaweicloud" {
  region = var.region
}

# 1. VPC
resource "huaweicloud_vpc" "this" {
  name = "startup-kit-vpc"
  cidr = var.vpc_cidr
}

# 2. 子网
resource "huaweicloud_vpc_subnet" "this" {
  name       = "startup-kit-subnet"
  vpc_id     = huaweicloud_vpc.this.id
  cidr       = var.subnet_cidr
  gateway_ip = cidrhost(var.subnet_cidr, 1)
}

# 3. 安全组
resource "huaweicloud_networking_secgroup" "this" {
  name = "startup-kit-sg"
}

resource "huaweicloud_networking_secgroup_rule" "allow_http" {
  count = var.enable_apig ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.this.id
}

resource "huaweicloud_networking_secgroup_rule" "allow_https" {
  count = var.enable_apig ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.this.id
}

resource "huaweicloud_networking_secgroup_rule" "allow_mongo" {
  count = var.enable_managed_database ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8635
  port_range_max    = 8635
  remote_ip_prefix  = var.vpc_cidr
  security_group_id = huaweicloud_networking_secgroup.this.id
}

# 4. IAM 委托（用于 FunctionGraph 访问其他服务）
resource "huaweicloud_identity_agency" "this" {
  count = var.enable_managed_database ? 1 : 0

  name                   = "startup-kit-agency"
  description            = "FunctionGraph 访问 GaussDB-Mongo 的委托"
  delegated_service_name = "op_svc_functiongraph"

  all_resources_roles = [
    "FunctionGraph FullAccess"
  ]
}

# 5. GaussDB-Mongo 实例（可选，默认关闭）
resource "huaweicloud_gaussdb_mongo_instance" "this" {
  count = var.enable_managed_database ? 1 : 0

  name              = var.gaussdb_instance_name
  flavor            = "gemserv.uf2.4xlarge.uch2.mongo"
  volume_size       = 100
  vpc_id            = huaweicloud_vpc.this.id
  subnet_id         = huaweicloud_vpc_subnet.this.id
  security_group_id = huaweicloud_networking_secgroup.this.id
  password          = var.gaussdb_password
  node_num          = 3
  availability_zone = "cn-north-4a"

  datastore {
    engine         = "MongoDB"
    storage_engine = "WiredTiger"
    version        = "4.0"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# 6. APIG 专享实例（可选，默认关闭）
resource "huaweicloud_apig_instance" "this" {
  count = var.enable_apig ? 1 : 0

  name              = var.apig_name
  edition           = "BASIC"
  vpc_id            = huaweicloud_vpc.this.id
  subnet_id         = huaweicloud_vpc_subnet.this.id
  security_group_id = huaweicloud_networking_secgroup.this.id
  region            = var.region
  available_zones   = ["cn-north-4a"]
}

# 7. FunctionGraph 函数
locals {
  function_code = <<EOF
'use strict';

exports.handler = async (event, context) => {
    console.log('Event:', JSON.stringify(event));
    
    // 返回一个简单的响应用于验证
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello from Startup Kit FunctionGraph!',
            input: event
        }),
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    };
};
EOF
}

resource "huaweicloud_fgs_function" "this" {
  name        = "startup_todo_handler"
  package     = "startup_kit"
  runtime     = "Node.js18.15"
  handler     = "index.handler"
  memory_size = 128
  timeout     = 30
  code_type   = "inline"
  func_code   = base64encode(local.function_code)

  # 暂时不使用 vpc_config（启用 GaussDB 时需要配置 app_agency）
  # vpc_id     = huaweicloud_vpc.this.id
  # network_id = huaweicloud_vpc_subnet.this.id
}

# 输出
output "vpc_id" {
  description = "VPC ID"
  value       = huaweicloud_vpc.this.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = huaweicloud_vpc_subnet.this.id
}

output "function_urn" {
  description = "FunctionGraph 函数 URN"
  value       = huaweicloud_fgs_function.this.urn
}

output "function_name" {
  description = "FunctionGraph 函数名称"
  value       = huaweicloud_fgs_function.this.name
}
