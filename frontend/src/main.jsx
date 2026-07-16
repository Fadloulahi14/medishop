import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';

const API_URL = '/api';

function App() {
  const [todos, setTodos] = useState([]);
  const [title, setTitle] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadTodos = async () => {
    try {
      setError('');
      const response = await fetch(`${API_URL}/todos`);
      if (!response.ok) throw new Error('Impossible de charger les tâches');
      setTodos(await response.json());
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadTodos(); }, []);

  const addTodo = async (event) => {
    event.preventDefault();
    if (!title.trim()) return;
    const response = await fetch(`${API_URL}/todos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: title.trim() })
    });
    if (!response.ok) return setError('Création impossible');
    setTitle('');
    await loadTodos();
  };

  const toggleTodo = async (todo) => {
    await fetch(`${API_URL}/todos/${todo.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ completed: !todo.completed })
    });
    await loadTodos();
  };

  const removeTodo = async (id) => {
    await fetch(`${API_URL}/todos/${id}`, { method: 'DELETE' });
    await loadTodos();
  };

  return (
    <main className="page">
      <section className="card">
        <div className="brand">MediShop</div>
        <h1>Todo interne</h1>
        <p className="subtitle">Organisez les tâches de l'équipe simplement.</p>
        <form onSubmit={addTodo} className="todo-form">
          <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Nouvelle tâche…" maxLength={200} />
          <button type="submit">Ajouter</button>
        </form>
        {error && <p className="error">{error}</p>}
        {loading ? <p>Chargement…</p> : (
          <ul className="todo-list">
            {todos.length === 0 && <li className="empty">Aucune tâche pour le moment.</li>}
            {todos.map((todo) => (
              <li key={todo.id} className={todo.completed ? 'done' : ''}>
                <button className="check" onClick={() => toggleTodo(todo)} aria-label="Basculer la tâche">{todo.completed ? '✓' : ''}</button>
                <span>{todo.title}</span>
                <button className="delete" onClick={() => removeTodo(todo.id)} aria-label="Supprimer">×</button>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);
