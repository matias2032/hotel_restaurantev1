// src/routes/ProtectedRoute.jsx

import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useCliente } from '../hooks/useCliente';

export function ProtectedRoute({ exigirSenhaDefinida = true }) {
  const location = useLocation();

  const {
    autenticado,
    primeiraSenha,
    carregando,
  } = useCliente();

  console.info('[ProtectedRoute] VERIFICAR_ACESSO', {
    pathname: location.pathname,
    autenticado,
    primeiraSenha,
    exigirSenhaDefinida,
    carregando,
  });

  if (carregando) {
    return <p>Carregando sessão...</p>;
  }

  if (!autenticado) {
    console.warn('[ProtectedRoute] ACESSO_NEGADO_SEM_LOGIN', {
      pathname: location.pathname,
    });

    return (
      <Navigate
        to="/cliente/login"
        replace
        state={{ from: location.pathname }}
      />
    );
  }

  if (exigirSenhaDefinida && primeiraSenha) {
    console.warn('[ProtectedRoute] REDIRECT_PRIMEIRA_SENHA_OBRIGATORIA', {
      pathname: location.pathname,
    });

    return <Navigate to="/cliente/primeira-senha" replace />;
  }

  console.info('[ProtectedRoute] ACESSO_PERMITIDO', {
    pathname: location.pathname,
  });

  return <Outlet />;
}