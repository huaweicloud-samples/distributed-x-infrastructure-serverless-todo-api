# distributed-x-infrastructure-serverless-todo-api


> [English](README.md)
基于华为云 Serverless 架构的**待办事项管理 RESTful API**，可用于快速搭建个人任务管理系统或作为 Web/App 后端服务的参考模板。
本项目提供了一个完整的待办事项（TODO）管理 API，部署后你可以通过 HTTP 请求：

| 功能 | API 端点 | 示例 |
|------|---------|------|
| **创建任务** | `POST /todo/new` | 新建一个待办事项 |
| **查看全部任务** | `GET /todo/all` | 列出所有待办事项 |
| **查看进行中的任务** | `GET /todo/active` | 只看还没完成的任务 |
| **更新任务** | `PUT /todo/active` | 修改任务内容 |
| **查看已完成的任务** | `GET /todo/complete` | 只看已完成的任务 |
| **标记任务完成** | `PUT /todo/complete` | 把任务标记为"已完成" |
| **清理已完成任务** | `DELETE /todo/complete` | 一键删除所有已完成的任务 |

### 典型使用场景

**场景 1：个人任务管理**
```bash
# 1. 创建任务
curl -X POST -H 'Content-Type: application/json' \
  -d '{"todo_id": "1", "active": true, "description": "完成项目文档"}' \
  https://your-api-endpoint/todo/new

# 2. 查看进行中的任务
curl https://your-api-endpoint/todo/active
# 返回: [{"todo_id": "1", "active": true, "description": "完成项目文档"}]

# 3. 标记完成
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"todo_id": "1", "active": false, "description": "完成项目文档"}' \
  https://your-api-endpoint/todo/complete
```

**场景 2：集成到你的 Web/App**
- 移动端 App 调用 API 管理用户任务
- 前端 Vue/React 项目接入后端服务
- 作为微服务架构的"任务管理"模块

## 架构图

```
┌─────────────┐      ┌─────────────┐      ┌──────────────────┐
│   客户端     │─────▶│    APIG     │─────▶│  FunctionGraph  │
│  (CURL/前端) │      │  (API网关)   │      │   (无服务器函数) │
└─────────────┘      └─────────────┘      └────────┬─────────┘
                                                   │
                                                   ▼
                                          ┌──────────────────┐
                                          │  GaussDB-Mongo   │
                                          │   (文档数据库)    │
                                          └──────────────────┘
```

## 技术栈

| 组件 | 技术 |
|------|------|
| 运行时 | Node.js 14.x |
| 计算服务 | 华为云 FunctionGraph（无服务器函数） |
| API 网关 | 华为云 APIG |
| 数据库 | 华为云 GaussDB(for Mongo) |
| 部署工具 | Terraform |

## 快速部署

### 1. 克隆代码

```bash
git clone https://github.com/huaweicloud-samples/distributed-x-infrastructure-serverless-todo-api.git
cd distributed-x-infrastructure-serverless-todo-api
```

### 2. 配置华为云凭据

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION_NAME="cn-north-4"
```

### 3. 部署

```bash
cd infra
terraform init
terraform apply
```

### 4. 获取 API 地址

部署成功后，Terraform 会输出类似：
```
apig_endpoint = "https://a1b2c3d4.cn-north-4.huaweiapis.com"
```

## 完整 API 测试

```bash
BASE_URL="https://your-endpoint"

# 创建任务
curl -X POST -H 'Content-Type: application/json' \
  -d '{"todo_id": "task1", "active": true, "description": "写周报"}' \
  $BASE_URL/todo/new

# 查看所有任务
curl $BASE_URL/todo/all

# 查看进行中的任务
curl $BASE_URL/todo/active

# 更新任务
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"todo_id": "task1", "active": true, "description": "写周报（已更新）"}' \
  $BASE_URL/todo/active

# 标记完成
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"todo_id": "task1", "active": false, "description": "写周报"}' \
  $BASE_URL/todo/complete

# 查看已完成的任务
curl $BASE_URL/todo/complete

# 删除已完成的任务
curl -X DELETE $BASE_URL/todo/complete
```

## 项目结构

```
distributed-x-infrastructure-serverless-todo-api/
├── docs/
│   ├── architecture.md          # 架构设计文档
│   └── deployment-guide.md      # 部署指南
├── infra/
│   ├── main.tf                  # Terraform 配置
│   └── variables.tf             # 变量定义
├── src/
│   └── index.js                 # 函数代码
├── LICENSE
└── README.md
```

## 清理资源

```bash
terraform destroy
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
