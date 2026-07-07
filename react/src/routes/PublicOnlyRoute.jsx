// src/routes/PublicOnlyRoute.jsx

import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useCliente } from '../hooks/useCliente';

export function PublicOnlyRoute() {
  const location = useLocation();

  const {
    autenticado,
    primeiraSenha,
    carregando,
  } = useCliente();

  console.info('[PublicOnlyRoute] VERIFICAR_ACESSO_PUBLICO', {
    pathname: location.pathname,
    autenticado,
    primeiraSenha,
    carregando,
  });

  if (carregando) {
    return <p>Carregando sessão...</p>;
  }

  if (autenticado && primeiraSenha) {
    console.warn('[PublicOnlyRoute] CLIENTE_LOGADO_COM_PRIMEIRA_SENHA', {
      pathname: location.pathname,
    });

    return <Navigate to="/cliente/primeira-senha" replace />;
  }

  if (autenticado && !primeiraSenha) {
    console.warn('[PublicOnlyRoute] CLIENTE_JA_LOGADO', {
      pathname: location.pathname,
    });

    return <Navigate to="/menu" replace />;
  }

  console.info('[PublicOnlyRoute] ACESSO_PUBLICO_PERMITIDO', {
    pathname: location.pathname,
  });

  return <Outlet />;
}