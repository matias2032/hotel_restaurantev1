// src/routes/FirstPasswordRoute.jsx

import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useCliente } from '../hooks/useCliente';

export function FirstPasswordRoute() {
  const location = useLocation();

  const {
    autenticado,
    primeiraSenha,
    carregando,
  } = useCliente();

  console.info('[FirstPasswordRoute] VERIFICAR_ACESSO_PRIMEIRA_SENHA', {
    pathname: location.pathname,
    autenticado,
    primeiraSenha,
    carregando,
  });

  if (carregando) {
    return <p>Carregando sessão...</p>;
  }

  if (!autenticado) {
    console.warn('[FirstPasswordRoute] ACESSO_NEGADO_SEM_LOGIN', {
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

  if (!primeiraSenha) {
    console.warn('[FirstPasswordRoute] CLIENTE_NAO_PRECISA_TROCAR_SENHA', {
      pathname: location.pathname,
    });

    return <Navigate to="/menu" replace />;
  }

  console.info('[FirstPasswordRoute] ACESSO_PERMITIDO', {
    pathname: location.pathname,
  });

  return <Outlet />;
}