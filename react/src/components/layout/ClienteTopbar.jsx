// src/components/layout/ClienteTopbar.jsx

import { LogIn, Menu, UserPlus } from 'lucide-react';
import { Link } from 'react-router-dom';

import { useCliente } from '../../hooks/useCliente';

import './layout.css';

export function ClienteTopbar({ onAbrirSidebar }) {
  const {
    autenticado,
    nomeCompletoCliente,
    iniciaisCliente,
  } = useCliente();

  console.info('[ClienteTopbar] RENDERIZAR', {
    autenticado,
    nomeCompletoCliente,
  });

  return (
    <header className="cliente-topbar">
      <button
        className="cliente-topbar__hamburger"
        type="button"
        onClick={onAbrirSidebar}
        aria-label="Abrir menu"
      >
        <Menu size={22} />
      </button>

      <div className="cliente-topbar__title">
        <strong>Bem-vindo</strong>
        <span>Escolha no menu e faça o seu pedido com facilidade.</span>
      </div>

      <div className="cliente-topbar__actions">
        {autenticado ? (
          <div className="cliente-topbar__user-chip">
            <div className="cliente-topbar__avatar">
              {iniciaisCliente}
            </div>

            <div>
              <strong>{nomeCompletoCliente || 'Cliente'}</strong>
              <span>online</span>
            </div>
          </div>
        ) : (
          <>
            <Link
              className="cliente-topbar__link cliente-topbar__link--ghost"
              to="/cliente/cadastro"
            >
              <UserPlus size={17} />
              <span>Criar conta</span>
            </Link>

            <Link
              className="cliente-topbar__link"
              to="/cliente/login"
            >
              <LogIn size={17} />
              <span>Entrar</span>
            </Link>
          </>
        )}
      </div>
    </header>
  );
}