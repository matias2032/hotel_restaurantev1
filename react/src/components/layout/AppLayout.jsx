// src/components/layout/AppLayout.jsx

import { useState } from 'react';
import {
  Link,
  NavLink,
  Outlet,
} from 'react-router-dom';

import {
  ChevronDown,
  Home,
  KeyRound,
  LayoutDashboard,
  LogIn,
  LogOut,
  Menu,
  Menu as MenuIcon,
  Pencil,
  ReceiptText,
   ShoppingCart,
  UserPlus,
  X,
} from 'lucide-react';

import { useCliente } from '../../hooks/useCliente';

import './layout.css';

// ─────────────────────────────────────────────────────────────
// LINKS
// ─────────────────────────────────────────────────────────────

const linksPublicos = [
  {
    label: 'Menu',
    to: '/menu',
    icon: Home,
  },
];

const linksAutenticados = [
  {
    label: 'Dashboard',
    to: '/cliente/dashboard',
    icon: LayoutDashboard,
  },
  {
    label: 'Meus pedidos',
    to: '/cliente/pedidos',
    icon: ReceiptText,
    disabled: true,
  },
  {
    label: 'Carrinho',
    to: '/cliente/carrinho',
    icon: ShoppingCart,
    disabled: true,
  },

];

// ─────────────────────────────────────────────────────────────
// APP LAYOUT
// ─────────────────────────────────────────────────────────────

export function AppLayout() {
  const [sidebarAberta, setSidebarAberta] = useState(false);

  function abrirSidebar() {
    console.info('[AppLayout] ABRIR_SIDEBAR');
    setSidebarAberta(true);
  }

  function fecharSidebar() {
    console.info('[AppLayout] FECHAR_SIDEBAR');
    setSidebarAberta(false);
  }

  return (
    <div className="cliente-shell">
      <AppSidebar
        aberta={sidebarAberta}
        onFechar={fecharSidebar}
      />

      {sidebarAberta && (
        <button
          className="cliente-shell__overlay"
          type="button"
          aria-label="Fechar menu"
          onClick={fecharSidebar}
        />
      )}

      <main className="cliente-shell__main">
        <AppTopbar onAbrirSidebar={abrirSidebar} />

        <div className="cliente-shell__content">
          <Outlet />
        </div>
      </main>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────────────────────

function AppSidebar({ aberta, onFechar }) {
  const {
    autenticado,
    primeiraSenha,
  } = useCliente();

  console.info('[AppSidebar] RENDERIZAR', {
    aberta,
    autenticado,
    primeiraSenha,
  });

  const podeMostrarLinksProtegidos = autenticado && !primeiraSenha;

  return (
    <aside
      className={[
        'cliente-sidebar',
        aberta ? 'cliente-sidebar--aberta' : '',
      ]
        .filter(Boolean)
        .join(' ')}
    >
      <div className="cliente-sidebar__header">
        <div className="cliente-sidebar__brand">
          <div className="cliente-sidebar__brand-icon">
            <MenuIcon size={22} />
          </div>

          <div>
            <strong>Hotel Restaurante</strong>
            <span>Cliente Web</span>
          </div>
        </div>

        <button
          className="cliente-sidebar__close"
          type="button"
          onClick={onFechar}
          aria-label="Fechar menu"
        >
          <X size={20} />
        </button>
      </div>

      <nav className="cliente-sidebar__nav">
        {linksPublicos.map((item) => (
          <SidebarLink
            key={item.to}
            item={item}
            onFechar={onFechar}
          />
        ))}

        {podeMostrarLinksProtegidos && (
          <>
            <div className="cliente-sidebar__section-label">
              Área do cliente
            </div>

            {linksAutenticados.map((item) => (
              <SidebarLink
                key={item.to}
                item={item}
                onFechar={onFechar}
              />
            ))}
          </>
        )}
      </nav>

      <div className="cliente-sidebar__footer">
        <AppUserMenu />
      </div>
    </aside>
  );
}

function SidebarLink({ item, onFechar }) {
  const Icon = item.icon;

  if (item.disabled) {
    return (
      <div className="cliente-sidebar__link cliente-sidebar__link--disabled">
        <Icon size={19} />
        <span>{item.label}</span>
        <small>breve</small>
      </div>
    );
  }

  return (
    <NavLink
      to={item.to}
      onClick={onFechar}
      className={({ isActive }) =>
        [
          'cliente-sidebar__link',
          isActive ? 'cliente-sidebar__link--active' : '',
        ]
          .filter(Boolean)
          .join(' ')
      }
    >
      <Icon size={19} />
      <span>{item.label}</span>
    </NavLink>
  );
}

// ─────────────────────────────────────────────────────────────
// TOPBAR
// ─────────────────────────────────────────────────────────────

function AppTopbar({ onAbrirSidebar }) {
  const {
    autenticado,
    nomeCompletoCliente,
    iniciaisCliente,
  } = useCliente();

  console.info('[AppTopbar] RENDERIZAR', {
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

// ─────────────────────────────────────────────────────────────
// USER MENU
// ─────────────────────────────────────────────────────────────

function AppUserMenu() {
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
    console.info('[AppUserMenu] TOGGLE_MENU', {
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