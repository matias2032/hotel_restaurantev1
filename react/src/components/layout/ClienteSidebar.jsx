// src/components/layout/ClienteSidebar.jsx

import {
  Home,
  LayoutDashboard,
  LockKeyhole,
  Menu as MenuIcon,
  ReceiptText,
  Settings,
  ShoppingCart,
  X,
} from 'lucide-react';

import { NavLink } from 'react-router-dom';
import { useCliente } from '../../hooks/useCliente';
import { ClienteUserMenu } from './ClienteUserMenu';

import './layout.css';

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
  {
    label: 'Alterar senha',
    to: '/cliente/alterar-senha',
    icon: LockKeyhole,
  },
  {
    label: 'Editar dados',
    to: '/cliente/editar-dados',
    icon: Settings,
  },
];

export function ClienteSidebar({ aberta, onFechar }) {
  const {
    autenticado,
    primeiraSenha,
  } = useCliente();

  console.info('[ClienteSidebar] RENDERIZAR', {
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
        <ClienteUserMenu />
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