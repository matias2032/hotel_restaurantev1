// src/components/layout/ClienteUserMenu.jsx

import { ChevronDown, LogIn, LogOut, Pencil, UserPlus, KeyRound } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useState } from 'react';

import { useCliente } from '../../hooks/useCliente';

import './layout.css';

export function ClienteUserMenu() {
  const [aberto, setAberto] = useState(false);

  const {
    cliente,
    autenticado,
    primeiraSenha,
    nomeCompletoCliente,
    iniciaisCliente,
    executarLogout,
  } = useCliente();

  function toggleMenu() {
    console.info('[ClienteUserMenu] TOGGLE_MENU', {
      aberto: !aberto,
      autenticado,
      idCliente: cliente?.idCliente,
    });

    setAberto((value) => !value);
  }

  if (!autenticado) {
    return (
      <div className="cliente-user-menu cliente-user-menu--publico">
        <Link className="cliente-user-menu__public-link" to="/cliente/login">
          <LogIn size={18} />
          <span>Entrar na conta</span>
        </Link>

        <Link className="cliente-user-menu__public-link" to="/cliente/cadastro">
          <UserPlus size={18} />
          <span>Criar conta</span>
        </Link>
      </div>
    );
  }

  return (
    <div className="cliente-user-menu">
      <button
        className="cliente-user-menu__trigger"
        type="button"
        onClick={toggleMenu}
      >
        <div className="cliente-user-menu__avatar">
          {iniciaisCliente}
        </div>

        <div className="cliente-user-menu__identity">
          <strong>{nomeCompletoCliente || 'Cliente'}</strong>
          <span>{cliente?.email || cliente?.telefone || 'Sessão activa'}</span>
        </div>

        <ChevronDown
          size={18}
          className={[
            'cliente-user-menu__chevron',
            aberto ? 'cliente-user-menu__chevron--open' : '',
          ]
            .filter(Boolean)
            .join(' ')}
        />
      </button>

      {aberto && (
        <div className="cliente-user-menu__dropdown">
          {primeiraSenha ? (
            <Link
              className="cliente-user-menu__option"
              to="/cliente/primeira-senha"
              onClick={() => setAberto(false)}
            >
              <KeyRound size={17} />
              <span>Definir primeira senha</span>
            </Link>
          ) : (
            <>
              <Link
                className="cliente-user-menu__option"
                to="/cliente/editar-dados"
                onClick={() => setAberto(false)}
              >
                <Pencil size={17} />
                <span>Editar dados</span>
              </Link>

              <Link
                className="cliente-user-menu__option"
                to="/cliente/alterar-senha"
                onClick={() => setAberto(false)}
              >
                <KeyRound size={17} />
                <span>Alterar senha</span>
              </Link>
            </>
          )}

          <button
            className="cliente-user-menu__option cliente-user-menu__option--danger"
            type="button"
            onClick={executarLogout}
          >
            <LogOut size={17} />
            <span>Sair</span>
          </button>
        </div>
      )}
    </div>
  );
}