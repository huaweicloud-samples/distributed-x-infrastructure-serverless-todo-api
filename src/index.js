'use strict';

const { MongoClient } = require('mongodb');

// 从环境变量获取 MongoDB 连接信息
const mongoUrl = process.env.MONGO_URL || 'mongodb://username:password@host:8635';
const dbName = 'startupkit';
const collectionName = 'todos';

let cachedClient = null;

async function getClient() {
    if (cachedClient) return cachedClient;
    const client = new MongoClient(mongoUrl);
    await client.connect();
    cachedClient = client;
    return client;
}

// 构建 API 响应
const createResponse = (statusCode, body) => {
    return {
        statusCode: statusCode,
        body: body,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }
};

/**
 * 华为云 FunctionGraph 入口函数
 * @param {Object} event - 事件对象，包含 path, httpMethod, body 等
 * @param {Object} context - 上下文对象
 */
exports.handler = async (event, context) => {
    const client = await getClient();
    const db = client.db(dbName);
    const col = db.collection(collectionName);

    const path = event.path || '/';
    const method = event.httpMethod || 'GET';

    console.log('Path:', path, 'Method:', method);

    try {
        // POST /todo/new - 创建待办事项
        if (path === '/todo/new' && method === 'POST') {
            const item = JSON.parse(event.body);
            await col.insertOne(item);
            return createResponse(200, JSON.stringify({
                message: 'TODO created',
                todo_id: item.todo_id
            }));
        }

        // GET /todo/all - 获取所有待办事项
        if (path === '/todo/all' && method === 'GET') {
            const items = await col.find({}).toArray();
            return createResponse(200, JSON.stringify(items));
        }

        // GET /todo/active - 获取未完成的待办事项
        if (path === '/todo/active' && method === 'GET') {
            const items = await col.find({ active: true }).toArray();
            return createResponse(200, JSON.stringify(items));
        }

        // PUT /todo/active - 更新待办事项
        if (path === '/todo/active' && method === 'PUT') {
            const item = JSON.parse(event.body);
            await col.replaceOne({ todo_id: item.todo_id }, item);
            return createResponse(200, JSON.stringify({
                message: 'TODO updated',
                todo_id: item.todo_id
            }));
        }

        // GET /todo/complete - 获取已完成的待办事项
        if (path === '/todo/complete' && method === 'GET') {
            const items = await col.find({ active: false }).toArray();
            return createResponse(200, JSON.stringify(items));
        }

        // PUT /todo/complete - 标记待办事项为已完成
        if (path === '/todo/complete' && method === 'PUT') {
            const item = JSON.parse(event.body);
            item.active = false;
            await col.replaceOne({ todo_id: item.todo_id }, item);
            return createResponse(200, JSON.stringify({
                message: 'TODO marked complete',
                todo_id: item.todo_id
            }));
        }

        // DELETE /todo/complete - 删除所有已完成的待办事项
        if (path === '/todo/complete' && method === 'DELETE') {
            const result = await col.deleteMany({ active: false });
            return createResponse(200, JSON.stringify({
                message: 'Deleted completed',
                count: result.deletedCount
            }));
        }

        return createResponse(404, JSON.stringify({ error: 'Not found' }));
    } catch (err) {
        console.error('Error:', err);
        return createResponse(500, JSON.stringify({ error: err.message }));
    }
};
