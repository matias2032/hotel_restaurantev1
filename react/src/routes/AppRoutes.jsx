// src/routes/AppRoutes.jsx

import {
  BrowserRouter,
  Navigate,
  Route,
  Routes,
} from 'react-router-dom';

import { ClienteShell } from '../components/layout/ClienteShell';
import { ProtectedRoute } from './ProtectedRoute';
import { PublicOnlyRoute } from './PublicOnlyRoute';
import { FirstPasswordRoute } from './FirstPasswordRoute';

function MenuPageTemp() {
  return <h1>Menu público do restaurante</h1>;
}

function ClienteLoginPageTemp() {
  return <h1>Login do Cliente</h1>;
}

function ClienteCadastroPageTemp() {
  return <h1>Cadastro Público de Cliente</h1>;
}

function ClientePrimeiraSenhaPageTemp() {
  return <h1>Troca Obrigatória da Primeira Senha</h1>;
}

function ClienteDashboardPageTemp() {
  return <h1>Dashboard do Cliente</h1>;
}

function ClienteAlterarSenhaPageTemp() {
  return <h1>Alterar Senha</h1>;
}

function ClienteEditarDadosPageTemp() {
  return <h1>Editar Dados</h1>;
}

function NotFoundPageTemp() {
  return <h1>Página não encontrada</h1>;
}

export function AppRoutes() {
  console.info('[AppRoutes] RENDERIZAR_ROTAS');

  return (
    <BrowserRouter>
      <Routes>
        <Route element={<ClienteShell />}>
          <Route path="/" element={<Navigate to="/menu" replace />} />

          {/* PÁGINA PÚBLICA */}
          <Route path="/menu" element={<MenuPageTemp />} />

          {/* PÁGINAS PÚBLICAS SOMENTE PARA NÃO AUTENTICADOS */}
          <Route element={<PublicOnlyRoute />}>
            <Route path="/cliente/login" element={<ClienteLoginPageTemp />} />
            <Route
              path="/cliente/cadastro"
              element={<ClienteCadastroPageTemp />}
            />
          </Route>

          {/* PRIMEIRA SENHA — SOMENTE AUTENTICADO COM primeiraSenha=true */}
          <Route element={<FirstPasswordRoute />}>
            <Route
              path="/cliente/primeira-senha"
              element={<ClientePrimeiraSenhaPageTemp />}
            />
          </Route>

          {/* ÁREA PROTEGIDA — EXIGE LOGIN E SENHA JÁ DEFINIDA */}
          <Route element={<ProtectedRoute exigirSenhaDefinida={true} />}>
            <Route
              path="/cliente/dashboard"
              element={<ClienteDashboardPageTemp />}
            />

            <Route
              path="/cliente/alterar-senha"
              element={<ClienteAlterarSenhaPageTemp />}
            />

            <Route
              path="/cliente/editar-dados"
              element={<ClienteEditarDadosPageTemp />}
            />
          </Route>

          <Route path="*" element={<NotFoundPageTemp />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}