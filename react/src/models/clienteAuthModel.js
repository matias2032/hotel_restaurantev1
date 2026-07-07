// src/models/clienteAuthModel.js

import { mapClienteFromApi } from './clienteModel';

// ─────────────────────────────────────────────────────────────
// PAYLOAD — LOGIN CLIENTE
// POST /api/clientes/auth/login
// ─────────────────────────────────────────────────────────────

export function buildClienteLoginPayload({ credencial, senha }) {
  return {
    credencial: credencial?.trim() || '',
    senha: senha || '',
  };
}

// ─────────────────────────────────────────────────────────────
// RESPONSE — LOGIN CLIENTE
// ─────────────────────────────────────────────────────────────

export function mapClienteLoginResponseFromApi(json) {
  if (!json) {
    return null;
  }

  const tokenType = json.tokenType || 'Bearer';
  const accessToken = json.accessToken || '';

  return {
    mensagem: json.mensagem ?? '',

    primeiraSenha: json.primeiraSenha === true,

    accessToken,
    tokenType,

    authorization:
      accessToken ? `${tokenType} ${accessToken}` : null,

    expiresInMinutes: json.expiresInMinutes ?? null,

    cliente: mapClienteFromApi(json.cliente),
  };
}

// ─────────────────────────────────────────────────────────────
// HELPERS AUTH
// ─────────────────────────────────────────────────────────────

export function loginExigeTrocaPrimeiraSenha(loginResponse) {
  return loginResponse?.primeiraSenha === true;
}

export function loginTemTokenValido(loginResponse) {
  return Boolean(loginResponse?.accessToken);
}

export function getIdClienteFromLogin(loginResponse) {
  return loginResponse?.cliente?.idCliente ?? null;
}