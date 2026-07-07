// src/models/clienteModel.js

// ─────────────────────────────────────────────────────────────
// PERFIL CLIENTE
// ─────────────────────────────────────────────────────────────

export function mapPerfilClienteFromApi(json) {
  if (!json) {
    return null;
  }

  return {
    idPerfilCliente: json.idPerfilCliente ?? null,
    nomePerfilCliente: json.nomePerfilCliente ?? '',
  };
}

// ─────────────────────────────────────────────────────────────
// CLIENTE
// ─────────────────────────────────────────────────────────────

export function mapClienteFromApi(json) {
  if (!json) {
    return null;
  }

  return {
    idCliente: json.idCliente ?? null,

    nome: json.nome ?? '',
    apelido: json.apelido ?? '',
    email: json.email ?? '',
    telefone: json.telefone ?? '',
    nuit: json.nuit ?? '',

    ativo: json.ativo === true,
    primeiraSenha: json.primeiraSenha === true,

    perfilCliente: mapPerfilClienteFromApi(json.perfilCliente),

    createdAt: json.createdAt ?? null,
    updatedAt: json.updatedAt ?? null,
  };
}

// ─────────────────────────────────────────────────────────────
// PAYLOAD — AUTO-REGISTO WEB
// POST /api/clientes/registo
// ─────────────────────────────────────────────────────────────

export function buildClienteRegistoPayload({
  nome,
  apelido,
  email,
  telefone,
  senha,
  confirmarSenha,
}) {
  return {
    nome: nome?.trim() || '',
    apelido: apelido?.trim() || null,
    email: email?.trim() || null,
    telefone: telefone?.trim() || null,
    senha: senha || '',
    confirmarSenha: confirmarSenha || '',
  };
}

// ─────────────────────────────────────────────────────────────
// PAYLOAD — PRIMEIRA SENHA
// PATCH /api/clientes/{idCliente}/primeira-senha
// ─────────────────────────────────────────────────────────────

export function buildClientePrimeiraSenhaPayload({ novaSenha }) {
  return {
    novaSenha: novaSenha || '',
  };
}

// ─────────────────────────────────────────────────────────────
// PAYLOAD — ALTERAR SENHA NORMAL
// PATCH /api/clientes/{idCliente}/senha
// ─────────────────────────────────────────────────────────────

export function buildClienteAlterarSenhaPayload({
  senhaActual,
  novaSenha,
}) {
  return {
    senhaActual: senhaActual || '',
    novaSenha: novaSenha || '',
  };
}

// ─────────────────────────────────────────────────────────────
// HELPERS DO PERFIL
// ─────────────────────────────────────────────────────────────

export function getNomePerfilCliente(cliente) {
  return cliente?.perfilCliente?.nomePerfilCliente || '';
}

export function clienteEhEmpresarial(cliente) {
  const perfil = getNomePerfilCliente(cliente).toLowerCase();

  return perfil.includes('empresarial') || perfil.includes('empresa');
}

export function clienteEhSingular(cliente) {
  const perfil = getNomePerfilCliente(cliente).toLowerCase();

  return (
    perfil.includes('singular') ||
    perfil.includes('regular') ||
    perfil.includes('comum')
  );
}