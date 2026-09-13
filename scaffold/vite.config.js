import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    plugins: [laravel({ input: ['resources/js/app.jsx'], refresh: true }), react(), tailwindcss()],
    server: {
        host: '0.0.0.0', port: 5173, strictPort: true,
        origin: `http://localhost:${process.env.VITE_PORT || 5173}`,
        cors: { origin: process.env.APP_URL || 'http://localhost:8080' },
        hmr: { host: 'localhost', clientPort: Number(process.env.VITE_PORT || 5173) },
        watch: { usePolling: process.env.VITE_USE_POLLING === 'true', interval: 500 },
    },
});
