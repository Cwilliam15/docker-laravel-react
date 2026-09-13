import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import '../css/app.css';

function App() {
    const [count, setCount] = useState(0);
    return <main className="min-h-screen bg-slate-950 text-slate-100 flex items-center justify-center p-6">
        <section className="max-w-3xl w-full rounded-3xl border border-slate-700 p-8 md:p-12">
            <p className="text-emerald-400 font-semibold">TU ENTORNO DE DESARROLLO</p>
            <h1 className="text-4xl md:text-6xl font-bold mt-5">Construye tu próximo proyecto.</h1>
            <p className="text-slate-300 mt-6">Laravel · React · Tailwind CSS · PostgreSQL</p>
            <p className="text-slate-400 mt-4">Edita resources/js/app.jsx para comenzar.</p>
            <button className="mt-8 rounded-xl bg-emerald-400 px-5 py-3 font-semibold text-slate-950 hover:bg-emerald-300"
                onClick={() => setCount(count + 1)}>Probar React: {count}</button>
        </section>
    </main>;
}
createRoot(document.getElementById('app')).render(<React.StrictMode><App /></React.StrictMode>);
