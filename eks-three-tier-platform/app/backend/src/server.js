const express = require('express');
const { Pool } = require('pg');
const client = require('prom-client');
const app = express();
app.use(express.json());
const port = Number(process.env.PORT || 3000);
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost', port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'platformdb', user: process.env.DB_USER || 'platform',
  password: process.env.DB_PASSWORD || 'local-dev-password', connectionTimeoutMillis: 2500,
  max: 10
});
const register = new client.Registry();
client.collectDefaultMetrics({ register });
const httpRequests = new client.Counter({ name: 'http_requests_total', help: 'Total HTTP requests', labelNames: ['method', 'route', 'status'] });
register.registerMetric(httpRequests);
app.use((req, res, next) => { res.on('finish', () => httpRequests.inc({ method: req.method, route: req.route?.path || req.path, status: String(res.statusCode) })); next(); });
app.get('/health', (_req, res) => res.json({ status: 'ok', service: 'backend' }));
app.get('/ready', async (_req, res) => { try { await pool.query('SELECT 1'); res.json({ status: 'ready' }); } catch { res.status(503).json({ status: 'not-ready' }); } });
app.get('/metrics', async (_req, res) => { res.set('Content-Type', register.contentType); res.end(await register.metrics()); });
app.get('/', async (_req, res) => {
  try {
    await pool.query('CREATE TABLE IF NOT EXISTS visits (id BIGSERIAL PRIMARY KEY, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())');
    const result = await pool.query('INSERT INTO visits DEFAULT VALUES RETURNING id, created_at');
    const count = await pool.query('SELECT COUNT(*)::int AS total FROM visits');
    res.json({ message: 'Hello from the Node.js API. PostgreSQL is connected.', visit: result.rows[0], totalVisits: count.rows[0].total });
  } catch (error) { console.error('Database operation failed:', error.message); res.status(503).json({ message: 'Database is not ready. Check backend logs and DB connectivity.' }); }
});
let server;
if (require.main === module) {
  server = app.listen(port, () => console.log(`Backend listening on ${port}`));
  async function shutdown() { server.close(); await pool.end(); process.exit(0); }
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
}
module.exports = { app, pool };
