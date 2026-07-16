import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import pg from 'pg';

const { Pool } = pg;
const app = express();
const port = Number(process.env.PORT || 3000);

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'medishop',
  user: process.env.DB_USER || 'medishop',
  password: process.env.DB_PASSWORD,
  max: 10
});

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '100kb' }));

async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS todos (
      id SERIAL PRIMARY KEY,
      title VARCHAR(200) NOT NULL,
      completed BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
}

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch {
    res.status(503).json({ status: 'error', database: 'unavailable' });
  }
});

app.get('/todos', async (_req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT * FROM todos ORDER BY created_at DESC');
    res.json(rows);
  } catch (error) { next(error); }
});

app.post('/todos', async (req, res, next) => {
  try {
    const title = String(req.body.title || '').trim();
    if (!title) return res.status(400).json({ error: 'Le titre est obligatoire' });
    const { rows } = await pool.query('INSERT INTO todos(title) VALUES($1) RETURNING *', [title]);
    res.status(201).json(rows[0]);
  } catch (error) { next(error); }
});

app.patch('/todos/:id', async (req, res, next) => {
  try {
    const { rows } = await pool.query('UPDATE todos SET completed=$1 WHERE id=$2 RETURNING *', [Boolean(req.body.completed), req.params.id]);
    if (!rows[0]) return res.status(404).json({ error: 'Tâche introuvable' });
    res.json(rows[0]);
  } catch (error) { next(error); }
});

app.delete('/todos/:id', async (req, res, next) => {
  try {
    await pool.query('DELETE FROM todos WHERE id=$1', [req.params.id]);
    res.status(204).end();
  } catch (error) { next(error); }
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({ error: 'Erreur interne' });
});

initDb()
  .then(() => app.listen(port, '0.0.0.0', () => console.log(`API listening on ${port}`)))
  .catch((error) => { console.error('Database initialization failed', error); process.exit(1); });
