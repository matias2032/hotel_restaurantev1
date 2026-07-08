// src/repositories/clienteRepository.js

import { clienteApiService } from '../services/clienteApiService';
import { sessaoClienteStorage } from '../storage/sessaoClienteStorage';

import {
  buildClienteLoginPayload,
  mapClienteLoginResponseFromApi,
  loginExigeTrocaPrimeiraSenha,
  loginTemTokenValido,
} from '../models/clienteAuthModel';

import {
  mapClienteFromApi,
  buildClienteRegistoPayload,
  buildClientePrimeiraSenhaPayload,
  buildClienteAlterarSenhaPayload,
  buildClienteActualizarDadosPayload,
} from '../models/clienteModel';

function logInicio(acao, payload = {}) {
  console.info(`[ClienteRepository] ${acao}_INICIO`, payload);
}

function logSucesso(acao, payload = {}) {
  console.info(`[ClienteRepository] ${acao}_SUCESSO`, payload);
}

function logErro(acao, error) {
  console.error(`[ClienteRepository] ${acao}_ERRO`, {
    status: error?.status,
    message: error?.message,
    data: error?.data,
  });
}

function validarIdCliente(idCliente, acao) {
  if (!idCliente) {
    throw new Error(`ID do cliente é obrigatório para ${acao}.`);
  }
}

export const clienteRepository = {
  // ─────────────────────────────────────────────────────────────
  // LOGIN CLIENTE
  // POST /api/clientes/auth/login
  // ─────────────────────────────────────────────────────────────

  async login({ credencial, senha }) {
    logInicio('LOGIN_CLIENTE', {
      credencial: credencial?.trim() || '',
    });

    try {
      const payload = buildClienteLoginPayload({
        credencial,
        senha,
      });

      const response = await clienteApiService.loginCliente(payload);

      const loginResponse = mapClienteLoginResponseFromApi(response);

      if (!loginTemTokenValido(loginResponse)) {
        throw new Error('Login inválido. O servidor não devolveu um token JWT.');
      }

      sessaoClienteStorage.salvarSessao(loginResponse);

      const resultado = {
        ...loginResponse,
        deveTrocarPrimeiraSenha: loginExigeTrocaPrimeiraSenha(loginResponse),
      };

      logSucesso('LOGIN_CLIENTE', {
        idCliente: resultado?.cliente?.idCliente,
        nome: resultado?.cliente?.nome,
        email: resultado?.cliente?.email,
        primeiraSenha: resultado?.primeiraSenha,
        deveTrocarPrimeiraSenha: resultado?.deveTrocarPrimeiraSenha,
        tokenType: resultado?.tokenType,
        expiresInMinutes: resultado?.expiresInMinutes,
      });

      return resultado;
    } catch (error) {
      logErro('LOGIN_CLIENTE', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
  // AUTO-REGISTO PÚBLICO DO CLIENTE
  // POST /api/clientes/registo
  // ─────────────────────────────────────────────────────────────

  async registarCliente({
    nome,
    apelido,
    email,
    telefone,
    senha,
    confirmarSenha,
  }) {
    logInicio('REGISTAR_CLIENTE', {
      nome: nome?.trim() || '',
      apelido: apelido?.trim() || '',
      email: email?.trim() || '',
      telefone: telefone?.trim() || '',
    });

    try {
      const payload = buildClienteRegistoPayload({
        nome,
        apelido,
        email,
        telefone,
        senha,
        confirmarSenha,
      });

      const response = await clienteApiService.registarCliente(payload);

      const cliente = mapClienteFromApi(response);

      logSucesso('REGISTAR_CLIENTE', {
        idCliente: cliente?.idCliente,
        nome: cliente?.nome,
        apelido: cliente?.apelido,
        email: cliente?.email,
        telefone: cliente?.telefone,
        primeiraSenha: cliente?.primeiraSenha,
      });

      return cliente;
    } catch (error) {
      logErro('REGISTAR_CLIENTE', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
  // TROCA OBRIGATÓRIA DA PRIMEIRA SENHA
  // PATCH /api/clientes/{idCliente}/primeira-senha
  // ─────────────────────────────────────────────────────────────

  async trocarPrimeiraSenha(idCliente, { novaSenha }) {
    logInicio('TROCAR_PRIMEIRA_SENHA', {
      idCliente,
    });

    try {
      validarIdCliente(idCliente, 'trocar a primeira senha');

      const payload = buildClientePrimeiraSenhaPayload({
        novaSenha,
      });

      await clienteApiService.trocarPrimeiraSenha(idCliente, payload);

      sessaoClienteStorage.actualizarPrimeiraSenha(false);

      logSucesso('TROCAR_PRIMEIRA_SENHA', {
        idCliente,
        primeiraSenha: false,
      });

      return true;
    } catch (error) {
      logErro('TROCAR_PRIMEIRA_SENHA', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
  // ALTERAR SENHA NORMAL
  // PATCH /api/clientes/{idCliente}/senha
  // ─────────────────────────────────────────────────────────────

  async alterarSenha(idCliente, { senhaActual, novaSenha }) {
    logInicio('ALTERAR_SENHA', {
      idCliente,
    });

    try {
      validarIdCliente(idCliente, 'alterar a senha');

      const payload = buildClienteAlterarSenhaPayload({
        senhaActual,
        novaSenha,
      });

      await clienteApiService.alterarSenha(idCliente, payload);

      logSucesso('ALTERAR_SENHA', {
        idCliente,
      });

      return true;
    } catch (error) {
      logErro('ALTERAR_SENHA', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
  // SESSÃO LOCAL DO CLIENTE
  // ─────────────────────────────────────────────────────────────

  obterClienteLogado() {
    logInicio('OBTER_CLIENTE_LOGADO');

    try {
      const cliente = sessaoClienteStorage.obterCliente();

      logSucesso('OBTER_CLIENTE_LOGADO', {
        existeCliente: Boolean(cliente),
        idCliente: cliente?.idCliente,
        email: cliente?.email,
      });

      return cliente;
    } catch (error) {
      logErro('OBTER_CLIENTE_LOGADO', error);
      return null;
    }
  },

  estaAutenticado() {
    logInicio('VERIFICAR_AUTENTICACAO');

    try {
      const autenticado = sessaoClienteStorage.estaAutenticado();

      logSucesso('VERIFICAR_AUTENTICACAO', {
        autenticado,
      });

      return autenticado;
    } catch (error) {
      logErro('VERIFICAR_AUTENTICACAO', error);
      return false;
    }
  },

  clienteTemPrimeiraSenha() {
    logInicio('VERIFICAR_PRIMEIRA_SENHA');

    try {
      const primeiraSenha = sessaoClienteStorage.clienteTemPrimeiraSenha();

      logSucesso('VERIFICAR_PRIMEIRA_SENHA', {
        primeiraSenha,
      });

      return primeiraSenha;
    } catch (error) {
      logErro('VERIFICAR_PRIMEIRA_SENHA', error);
      return false;
    }
  },

  obterAuthorizationHeader() {
    logInicio('OBTER_AUTHORIZATION_HEADER');

    try {
      const authorization = sessaoClienteStorage.obterAuthorizationHeader();

      logSucesso('OBTER_AUTHORIZATION_HEADER', {
        existeAuthorization: Boolean(authorization),
      });

      return authorization;
    } catch (error) {
      logErro('OBTER_AUTHORIZATION_HEADER', error);
      return null;
    }
  },

  logout() {
    logInicio('LOGOUT_CLIENTE');

    try {
      sessaoClienteStorage.limparSessao();

      logSucesso('LOGOUT_CLIENTE');

      return true;
    } catch (error) {
      logErro('LOGOUT_CLIENTE', error);
      throw error;
    }
  },

  // ─────────────────────────────────────────────────────────────
// ACTUALIZAR DADOS DO CLIENTE
// PUT /api/clientes/{idCliente}
// ─────────────────────────────────────────────────────────────

async actualizarDadosCliente(idCliente, {
  nome,
  apelido,
  email,
  telefone,
  idPerfilCliente,
}) {
logInicio('ACTUALIZAR_DADOS_CLIENTE', {
  idCliente,
  nome: nome?.trim() || '',
  apelido: apelido?.trim() || '',
  email: email?.trim() || '',
  telefone: telefone?.trim() || '',
  idPerfilCliente,
});

  try {
    validarIdCliente(idCliente, 'actualizar os dados');

  const payload = buildClienteActualizarDadosPayload({
  nome,
  apelido,
  email,
  telefone,
  idPerfilCliente,
});

    const response = await clienteApiService.actualizarDadosCliente(
      idCliente,
      payload
    );

    const clienteActualizado = mapClienteFromApi(response);

    logSucesso('ACTUALIZAR_DADOS_CLIENTE', {
      idCliente: clienteActualizado?.idCliente,
      nome: clienteActualizado?.nome,
      apelido: clienteActualizado?.apelido,
      email: clienteActualizado?.email,
      telefone: clienteActualizado?.telefone,
    });

    return clienteActualizado;
  } catch (error) {
    logErro('ACTUALIZAR_DADOS_CLIENTE', error);
    throw error;
  }
},
};