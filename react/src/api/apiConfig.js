// src/api/apiConfig.js


function getRequiredEnv(name) {
  const value = import.meta.env[name];

  if (!value || value.trim() === '') {
    throw new Error(`Variável de ambiente obrigatória não definida: ${name}`);
  }

  return value.trim();
}

function normalizeBaseUrl(url) {
  return url.endsWith('/') ? url.slice(0, -1) : url;
}

export const API_BASE_URL = normalizeBaseUrl(
  getRequiredEnv('VITE_API_BASE_URL')
);

export const API_TIMEOUT_MS = Number(
  import.meta.env.VITE_API_TIMEOUT_MS || 30000
);

// ─────────────────────────────────────────────────────────────
// ROTAS DO BACKEND — CLIENTE WEB PÚBLICO
// ─────────────────────────────────────────────────────────────


const CLIENTES_BASE = '/api/clientes';

export const API_ROUTES = {

  clienteRegisto: `${CLIENTES_BASE}/registo`,

  clienteLogin: `${CLIENTES_BASE}/auth/login`,

  clientePrimeiraSenha(idCliente) {
    return `${CLIENTES_BASE}/${idCliente}/primeira-senha`;
  },
  clienteAlterarSenha(idCliente) {
    return `${CLIENTES_BASE}/${idCliente}/senha`;
  },
};

export function buildUrl(path, queryParams = {}) {
  const query = new URLSearchParams();

  Object.entries(queryParams).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      query.append(key, value);
    }
  });

  const queryString = query.toString();

  return queryString ? `${path}?${queryString}` : path;
}

export function printApiConfig() {
  console.log('🚀 React API CONFIG — Cliente Web');
  console.log('🔗 API_BASE_URL:', API_BASE_URL);
  console.log('⏱️ API_TIMEOUT_MS:', API_TIMEOUT_MS);
}