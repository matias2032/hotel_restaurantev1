// src/App.jsx

import { ClienteAuthProvider } from './contexts/ClienteAuthProvider';
import { AppRoutes } from './routes/AppRoutes';

export default function App() {
  return (
    <ClienteAuthProvider>
      <AppRoutes />
    </ClienteAuthProvider>
  );
}