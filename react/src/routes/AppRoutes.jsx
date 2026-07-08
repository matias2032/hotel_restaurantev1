// src/routes/AppRoutes.jsx

import {
  BrowserRouter,
  Navigate,
  Route,
  Routes,
} from 'react-router-dom';

import { AppLayout } from '../components/layout/AppLayout';

import { MenuPage } from '../pages/Menu';
import { LoginPage } from '../pages/Login';
import { CadastroPage } from '../pages/Cadastro';
import { PrimeiraSenhaPage } from '../pages/PrimeiraSenha';
import { AlterarSenhaPage } from '../pages/AlterarSenha';
import { EditarDadosPage } from '../pages/EditarDados';

import { ProtectedRoute } from './ProtectedRoute';
import { PublicOnlyRoute } from './PublicOnlyRoute';
import { FirstPasswordRoute } from './FirstPasswordRoute';

function ClienteDashboardPageTemp() {
  return <h1>Dashboard do Cliente</h1>;
}

function NotFoundPageTemp() {
  return <h1>Página não encontrada</h1>;
}

export function AppRoutes() {
  console.info('[AppRoutes] RENDERIZAR_ROTAS');

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/menu" replace />} />

        {/* LOGIN / CADASTRO SEM SIDEBAR */}
        <Route element={<PublicOnlyRoute />}>
          <Route path="/cliente/login" element={<LoginPage />} />
          <Route path="/cliente/cadastro" element={<CadastroPage />} />
        </Route>

        {/* PRIMEIRA SENHA SEM SIDEBAR */}
        <Route element={<FirstPasswordRoute />}>
          <Route
            path="/cliente/primeira-senha"
            element={<PrimeiraSenhaPage />}
          />
        </Route>

        {/* ROTAS COM LAYOUT / SIDEBAR / TOPBAR */}
        <Route element={<AppLayout />}>
          <Route path="/menu" element={<MenuPage />} />

          <Route element={<ProtectedRoute exigirSenhaDefinida={true} />}>
            <Route
              path="/cliente/dashboard"
              element={<ClienteDashboardPageTemp />}
            />

            <Route
              path="/cliente/alterar-senha"
              element={<AlterarSenhaPage />}
            />

            <Route
              path="/cliente/editar-dados"
              element={<EditarDadosPage />}
            />
          </Route>
        </Route>

        <Route path="*" element={<NotFoundPageTemp />} />
      </Routes>
    </BrowserRouter>
  );
}