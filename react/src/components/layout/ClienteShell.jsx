// src/components/layout/ClienteShell.jsx

import { useState } from 'react';
import { Outlet } from 'react-router-dom';

import { ClienteSidebar } from './ClienteSidebar';
import { ClienteTopbar } from './ClienteTopbar';

import './layout.css';

export function ClienteShell() {
  const [sidebarAberta, setSidebarAberta] = useState(false);

  function abrirSidebar() {
    console.info('[ClienteShell] ABRIR_SIDEBAR');
    setSidebarAberta(true);
  }

  function fecharSidebar() {
    console.info('[ClienteShell] FECHAR_SIDEBAR');
    setSidebarAberta(false);
  }

  return (
    <div className="cliente-shell">
      <ClienteSidebar
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
        <ClienteTopbar onAbrirSidebar={abrirSidebar} />

        <div className="cliente-shell__content">
          <Outlet />
        </div>
      </main>
    </div>
  );
}