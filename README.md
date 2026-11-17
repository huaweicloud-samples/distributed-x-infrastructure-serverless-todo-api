# distributed-x-infrastructure-serverless-todo-api


> [中文](README.cn.md)
A serverless TODO (Task) Management RESTful API built on Huawei Cloud. This project can be used to quickly build a personal task management system or as a reference template for web/app backend services.
After deployment, you can manage your tasks via HTTP API:

| Feature | Endpoint | Description |
|---------|----------|-------------|
| **Create Task** | `POST /todo/new` | Add a new TODO item |
| **List All Tasks** | `GET /todo/all` | Get all TODO items |
| **List Active Tasks** | `GET /todo/active` | Get incomplete tasks only |
| **Update Task** | `PUT /todo/active` | Modify a task |
| **List Completed** | `GET /todo/complete` | Get completed tasks |
| **Mark Complete** | `PUT /todo/complete` | Mark a task as done |
| **Cleanup** | `DELETE /todo/complete` | Delete all completed tasks |

### Example Usage

**Scenario 1: Personal Task Management**
```bash
# 1. Create a task
curl -X POST -H 'Content-Type: application/json' \
  -d '{"todo_id": "1", "active": true, "description": "Write project docs"}' \
  https://your-api-endpoint/todo/new

# 2. View active tasks
curl https://your-api-endpoint/todo/active
# Response: [{"todo_id": "1", "active": true, "description": "Write project docs"}]

# 3. Mark as complete
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"todo_id": "1", "active": false, "description": "Write project docs"}' \
  https://your-api-endpoint/todo/complete
```

**Scenario 2: Integrate into Your App**
- Mobile app calls API to manage user tasks
- Frontend Vue/React project connects to backend
- Use as "task management" module in microservices

## Architecture

```
┌─────────────┐      ┌─────────────┐      ┌──────────────────┐
│   Client    │─────▶│    APIG     │─────▶│  FunctionGraph   │
│  (CURL/UI)  │      │(API Gateway)│      │ (Serverless Fn)  │
└─────────────┘      └─────────────┘      └────────┬─────────┘
                                                   │
                                                   ▼
                                          ┌──────────────────┐
                                          │  GaussDB-Mongo   │
                                          │  (Document DB)   │
                                          └──────────────────┘
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Runtime | Node.js 14.x |
| Compute | Huawei Cloud FunctionGraph |
| API Gateway | Huawei Cloud APIG |
| Database | Huawei Cloud GaussDB(for Mongo) |
| IaC | Terraform |

## Quick Deploy

### 1. Clone

```bash
git clone https://github.com/huaweicloud-samples/distributed-x-infrastructure-serverless-todo-api.git
cd distributed-x-infrastructure-serverless-todo-api
```

### 2. Configure Credentials

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION_NAME="cn-north-4"
```

### 3. Deploy

```bash
cd infra
terraform init
terraform apply
```

### 4. Get API Endpoint

After deployment, Terraform outputs:
```
apig_endpoint = "https://a1b2c3d4.cn-north-4.huaweiapis.com"
```

## Full API Test

```bash
BASE_URL="https://your-endpoint"

# Create task
curl -X POST -H 'Content-Type: application/json' \
  -d '{"todo_id": "task1", "active": true, "description": "Write weekly report"}' \
  $BASE_URL/todo/new

# List all
curl $BASE_URL/todo/all

# List active
curl $BASE_URL/todo/active

# Update task
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"todo_id": "task1", "active": true, "description": "Write weekly report (updated)"}' \
  $BASE_URL/todo/active

# Mark complete
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"todo_id": "task1", "active": false, "description": "Write weekly report"}' \
  $BASE_URL/todo/complete

# List completed
curl $BASE_URL/todo/complete

# Delete completed
curl -X DELETE $BASE_URL/todo/complete
```

## Project Structure

```
distributed-x-infrastructure-serverless-todo-api/
├── docs/
│   ├── architecture.md
│   └── deployment-guide.md
├── infra/
│   ├── main.tf
│   └── variables.tf
├── src/
│   └── index.js
├── LICENSE
└── README.md
```

## Cleanup

```bash
terraform destroy
```

## License

MIT License - see [LICENSE](LICENSE) file
