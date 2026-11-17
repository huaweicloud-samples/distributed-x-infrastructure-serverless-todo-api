# 部署指南

## 前置条件

### 1. 环境要求

- Node.js 14.x 或更高版本
- Terraform 1.0 或更高版本
- Git

### 2. 华为云账号准备

1. 登录 [华为云控制台](https://console.huaweicloud.com)
2. 创建 Access Key 和 Secret Key：
   - 进入「我的凭证」→「访问密钥」
   - 点击「新增访问密钥」
   - 记录生成的访问密钥

3. 开通以下服务：
   - **FunctionGraph**: 进入控制台开通
   - **APIG**: 进入控制台开通
   - **GaussDB(for Mongo)**: 进入控制台开通

### 3. 区域选择

推荐使用 `cn-north-4`（华北-北京四）或 `cn-south-1`（华南-广州）区域。

## 部署步骤

### 步骤 1: 克隆代码

```bash
git clone https://github.com/huaweicloud-samples/distributed-x-infrastructure-serverless-todo-api.git
cd distributed-x-infrastructure-serverless-todo-api
```

### 步骤 2: 配置环境变量

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION_NAME="cn-north-4"
```

或在 Windows 上：

```powershell
$env:HW_ACCESS_KEY="your-access-key"
$env:HW_SECRET_KEY="your-secret-key"
$env:HW_REGION_NAME="cn-north-4"
```

### 步骤 3: 配置 Terraform

编辑 `infra/variables.tf` 或创建 `infra/terraform.tfvars`：

```hcl
region = "cn-north-4"
project_id = "your-project-id"
```

### 步骤 4: 初始化 Terraform

```bash
cd infra
terraform init
```

### 步骤 5: 验证部署计划

```bash
terraform plan
```

### 步骤 6: 执行部署

```bash
terraform apply
```

输入 `yes` 确认部署。

### 步骤 7: 获取 API 端点

部署成功后，输出类似：

```
apig_endpoint = "https://a1b2c3d4e5.cn-north-4.huaweiapis.com/todo"
```

## 测试 API

### 创建待办事项

```bash
curl -X POST -H 'Content-Type: application/json' \
  -d '{"todo_id": "1001", "active": true, "description": "完成项目文档"}' \
  https://<endpoint>/todo/new
```

### 获取所有待办事项

```bash
curl https://<endpoint>/todo/all
```

### 获取未完成事项

```bash
curl https://<endpoint>/todo/active
```

### 标记为已完成

```bash
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"todo_id": "1001", "active": false, "description": "完成项目文档"}' \
  https://<endpoint>/todo/complete
```

### 删除已完成事项

```bash
curl -X DELETE https://<endpoint>/todo/complete
```

## 清理资源

```bash
terraform destroy
```

这将删除所有创建的 FunctionGraph 函数、API Gateway API 和 GaussDB-Mongo 实例。

## 常见问题

### Q: Terraform init 失败

确保：
1. 网络可以访问 `terraform.io`
2. 华为云凭据正确
3. 区域名称正确（如 `cn-north-4`）

### Q: 函数创建失败

检查：
1. FunctionGraph 服务已开通
2. 委托权限配置正确

### Q: API 调用返回 502

检查：
1. FunctionGraph 函数是否部署成功
2. APIG 后端配置是否正确

### Q: 数据库连接失败

检查：
1. GaussDB-Mongo 实例是否运行中
2. VPC 和安全组配置是否正确
3. FunctionGraph 所在的 VPC 是否可以访问 GaussDB
