# 架构设计文档

## 架构概述

本项目使用华为云 Serverless 架构，包含以下核心组件：

| 华为云服务 | 用途 |
|-----------|------|
| FunctionGraph | 业务逻辑处理（7个函数） |
| APIG | RESTful API 暴露 |
| GaussDB(for Mongo) | 文档数据存储 |

### FunctionGraph 函数列表

1. `create_todo` - 创建待办事项
2. `get_all_todos` - 获取所有待办事项
3. `get_active_todos` - 获取未完成事项
4. `update_todo` - 更新事项
5. `get_complete_todos` - 获取已完成事项
6. `mark_complete` - 标记完成
7. `delete_complete` - 删除已完成事项

### API 端点设计

```
POST   /todo/new      - 创建
GET    /todo/all      - 获取全部
GET    /todo/active  - 获取未完成
PUT    /todo/active  - 更新
GET    /todo/complete - 获取已完成
PUT    /todo/complete - 标记完成
DELETE /todo/complete - 删除已完成
```

## 华为云架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         华为云 account                           │
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐ │
│  │     APIG     │───▶│ FunctionGraph│───▶│  GaussDB-Mongo   │ │
│  │  (API网关)   │    │   (7个函数)   │    │   (文档数据库)    │ │
│  └──────────────┘    └──────────────┘    └──────────────────┘ │
│         │                   │                    │              │
│         └───────────────────┴────────────────────┘              │
│                            │                                    │
│                     VPC (10.0.0.0/16)                          │
└─────────────────────────────────────────────────────────────────┘
```

## 服务详情

### FunctionGraph 函数设计

每个 API 端点对应一个 FunctionGraph 函数：

| 函数名 | 触发方式 | 说明 |
|--------|---------|------|
| create_todo | APIG API | 创建待办事项 |
| get_all_todos | APIG API | 获取所有待办事项 |
| get_active_todos | APIG API | 获取未完成事项 |
| update_todo | APIG API | 更新待办事项 |
| get_complete_todos | APIG API | 获取已完成事项 |
| mark_complete | APIG API | 标记完成 |
| delete_complete | APIG API | 删除已完成事项 |

### APIG API 设计

- **API 分组**: startup-kit-todo-api
- **API 名称**: startup-kit-todo
- **运行环境**: RELEASE
- **认证方式**: None (可改为 App)

### GaussDB-Mongo 数据库设计

- **实例规格**: 副本集实例（单节点可选）
- **存储引擎**: MongoDB
- **数据库版本**: 4.0
- **Collection**: todos

### 数据模型

```json
{
  "todo_id": "string (primary key)",
  "active": "boolean",
  "description": "string"
}
```

## 安全配置

- APIG 与 FunctionGraph 之间使用 VPC 内网通信
- FunctionGraph 与 GaussDB-Mongo 之间使用 VPC 内网连接
- CORS 已启用，生产环境建议限制允许的域名

## 部署架构

使用 Terraform 进行基础设施即代码（IaC）管理：

- `main.tf`: 包含所有资源定义
- `variables.tf`: 可配置变量（区域、实例规格等）
