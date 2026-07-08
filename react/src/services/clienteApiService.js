// src/services/clienteApiService.js

import { httpClient } from '../api/httpClient';
import { API_ROUTES } from '../api/apiConfig';

function logInicio(acao, payload = {}) {
  console.info(`[ClienteApiService] ${acao}_INICIO`, payload);
}

function logSucesso(acao, payload = {}) {
  console.info(`[ClienteApiService] ${acao}_SUCESSO`, payload);
}

function logErro(acao, error) {
  console.error(`[ClienteApiService] ${acao}_ERRO`, {
    status: error?.status,
    message: error?.message,
    data: error?.data,
  });
}

export const clienteApiService = {
  // ─────────────────────────────────────────────────────────────
  // CLIENTE — LOGIN JWT
  // POST /api/clientes/auth/login
  // ─────────────────────────────────────────────────────────────

  async loginCliente(payload) {
    logInicio('LOGIN_CLIENTE', {
      credencial: payload?.credencial,
    });

    try {
      const response = await httpClient.post(API_ROUTES.clienteLogin, payload);

      logSucesso('LOGIN_CLIENTE', {
        status: response.status,
        idCliente: response.data?.cliente?.idCliente,
        email: response.data?.cliente?.email,
        primeiraSenha: response.data?.primeiraSenha,
        tokenType: response.data?.tokenType,
        expiresInMinutes: response.data?.expiresInMinutes,
      });

      return response.data;
    } catch (error) {
      logErro('LOGIN_CLIENTE', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
  // CLIENTE — AUTO-REGISTO PÚBLICO
  // POST /api/clientes/registo
  // ─────────────────────────────────────────────────────────────

  async registarCliente(payload) {
    logInicio('REGISTAR_CLIENTE', {
      nome: payload?.nome,
      apelido: payload?.apelido,
      email: payload?.email,
      telefone: payload?.telefone,
    });

    try {
      const response = await httpClient.post(API_ROUTES.clienteRegisto, payload);

      logSucesso('REGISTAR_CLIENTE', {
        status: response.status,
        idCliente: response.data?.idCliente,
        nome: response.data?.nome,
        email: response.data?.email,
        telefone: response.data?.telefone,
        primeiraSenha: response.data?.primeiraSenha,
      });

      return response.data;
    } catch (error) {
      logErro('REGISTAR_CLIENTE', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
  // CLIENTE — TROCA OBRIGATÓRIA DA PRIMEIRA SENHA
  // PATCH /api/clientes/{idCliente}/primeira-senha
  // ─────────────────────────────────────────────────────────────

  async trocarPrimeiraSenha(idCliente, payload) {
    logInicio('TROCAR_PRIMEIRA_SENHA', {
      idCliente,
    });

    try {
      const response = await httpClient.patch(
        API_ROUTES.clientePrimeiraSenha(idCliente),
        payload
      );

      logSucesso('TROCAR_PRIMEIRA_SENHA', {
        status: response.status,
        idCliente,
      });

      return true;
    } catch (error) {
      logErro('TROCAR_PRIMEIRA_SENHA', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
  // CLIENTE — ALTERAR SENHA NORMAL
  // PATCH /api/clientes/{idCliente}/senha
  // ─────────────────────────────────────────────────────────────

  async alterarSenha(idCliente, payload) {
    logInicio('ALTERAR_SENHA', {
      idCliente,
    });

    try {
      const response = await httpClient.patch(
        API_ROUTES.clienteAlterarSenha(idCliente),
        payload
      );

      logSucesso('ALTERAR_SENHA', {
        status: response.status,
        idCliente,
      });

      return true;
    } catch (error) {
      logErro('ALTERAR_SENHA', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
// CLIENTE — ACTUALIZAR DADOS
// PUT /api/clientes/{idCliente}
// ─────────────────────────────────────────────────────────────

async actualizarDadosCliente(idCliente, payload) {
  logInicio('ACTUALIZAR_DADOS_CLIENTE', {
    idCliente,
    nome: payload?.nome,
    apelido: payload?.apelido,
    email: payload?.email,
    telefone: payload?.telefone,
  });

  try {
    const response = await httpClient.put(
      API_ROUTES.clienteActualizarDados(idCliente),
      payload
    );

    logSucesso('ACTUALIZAR_DADOS_CLIENTE', {
      status: response.status,
      idCliente: response.data?.idCliente,
      nome: response.data?.nome,
      email: response.data?.email,
      telefone: response.data?.telefone,
    });

    return response.data;
  } catch (error) {
    logErro('ACTUALIZAR_DADOS_CLIENTE', error);
    throw error;
  }
},

};