// src/contexts/ClienteAuthProvider.jsx

import { useEffect, useMemo, useState } from 'react';

import { ClienteAuthContext } from './clienteAuthContext';
import { clienteRepository } from '../repositories/clienteRepository';

export function ClienteAuthProvider({ children }) {
  const [cliente, setCliente] = useState(null);
  const [autenticado, setAutenticado] = useState(false);
  const [primeiraSenha, setPrimeiraSenha] = useState(false);

  const [carregando, setCarregando] = useState(true);
  const [erro, setErro] = useState(null);

  // ─────────────────────────────────────────────────────────────
  // LOGS
  // ─────────────────────────────────────────────────────────────

  function logInicio(acao, payload = {}) {
    console.info(`[ClienteAuthProvider] ${acao}_INICIO`, payload);
  }

  function logSucesso(acao, payload = {}) {
    console.info(`[ClienteAuthProvider] ${acao}_SUCESSO`, payload);
  }

  function logErro(acao, error) {
    console.error(`[ClienteAuthProvider] ${acao}_ERRO`, {
      status: error?.status,
      message: error?.message,
      data: error?.data,
    });
  }

  // ─────────────────────────────────────────────────────────────
  // RESTAURAR SESSÃO AO ABRIR A APLICAÇÃO
  // ─────────────────────────────────────────────────────────────

  useEffect(() => {
    restaurarSessao();
  }, []);

  function restaurarSessao() {
    logInicio('RESTAURAR_SESSAO');

    try {
      setCarregando(true);
      setErro(null);

      const tokenExiste = clienteRepository.estaAutenticado();
      const clienteGuardado = clienteRepository.obterClienteLogado();
      const clienteTemPrimeiraSenha =
        clienteRepository.clienteTemPrimeiraSenha();

      if (tokenExiste && clienteGuardado) {
        setCliente(clienteGuardado);
        setAutenticado(true);
        setPrimeiraSenha(clienteTemPrimeiraSenha);

        logSucesso('RESTAURAR_SESSAO', {
          idCliente: clienteGuardado?.idCliente,
          nome: clienteGuardado?.nome,
          email: clienteGuardado?.email,
          primeiraSenha: clienteTemPrimeiraSenha,
        });

        return;
      }

      setCliente(null);
      setAutenticado(false);
      setPrimeiraSenha(false);

      logSucesso('RESTAURAR_SESSAO_VAZIA', {
        tokenExiste,
        existeCliente: Boolean(clienteGuardado),
      });
    } catch (error) {
      logErro('RESTAURAR_SESSAO', error);

      setErro(error.message || 'Erro ao restaurar sessão do cliente.');

      setCliente(null);
      setAutenticado(false);
      setPrimeiraSenha(false);

      try {
        clienteRepository.logout();
      } catch (logoutError) {
        logErro('LIMPAR_SESSAO_APOS_ERRO', logoutError);
      }
    } finally {
      setCarregando(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN DO CLIENTE
  // POST /api/clientes/auth/login
  // ─────────────────────────────────────────────────────────────

  async function login({ credencial, senha }) {
    logInicio('LOGIN_CLIENTE', {
      credencial: credencial?.trim() || '',
    });

    try {
      setCarregando(true);
      setErro(null);

      const loginResponse = await clienteRepository.login({
        credencial,
        senha,
      });

      setCliente(loginResponse.cliente);
      setAutenticado(true);
      setPrimeiraSenha(loginResponse.primeiraSenha === true);

      logSucesso('LOGIN_CLIENTE', {
        idCliente: loginResponse?.cliente?.idCliente,
        nome: loginResponse?.cliente?.nome,
        email: loginResponse?.cliente?.email,
        primeiraSenha: loginResponse?.primeiraSenha,
        deveTrocarPrimeiraSenha: loginResponse?.deveTrocarPrimeiraSenha,
        tokenType: loginResponse?.tokenType,
        expiresInMinutes: loginResponse?.expiresInMinutes,
      });

      return loginResponse;
    } catch (error) {
      logErro('LOGIN_CLIENTE', error);

      setErro(error.message || 'Erro ao fazer login.');

      setCliente(null);
      setAutenticado(false);
      setPrimeiraSenha(false);

      throw error;
    } finally {
      setCarregando(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // AUTO-REGISTO PÚBLICO DO CLIENTE
  // POST /api/clientes/registo
  // ─────────────────────────────────────────────────────────────

  async function registarCliente({
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
      setCarregando(true);
      setErro(null);

      const clienteCriado = await clienteRepository.registarCliente({
        nome,
        apelido,
        email,
        telefone,
        senha,
        confirmarSenha,
      });

      logSucesso('REGISTAR_CLIENTE', {
        idCliente: clienteCriado?.idCliente,
        nome: clienteCriado?.nome,
        apelido: clienteCriado?.apelido,
        email: clienteCriado?.email,
        telefone: clienteCriado?.telefone,
        primeiraSenha: clienteCriado?.primeiraSenha,
      });

      return clienteCriado;
    } catch (error) {
      logErro('REGISTAR_CLIENTE', error);

      setErro(error.message || 'Erro ao registar cliente.');
      throw error;
    } finally {
      setCarregando(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // TROCA OBRIGATÓRIA DA PRIMEIRA SENHA
  // PATCH /api/clientes/{idCliente}/primeira-senha
  // ─────────────────────────────────────────────────────────────

  async function trocarPrimeiraSenha({ novaSenha }) {
    logInicio('TROCAR_PRIMEIRA_SENHA', {
      idCliente: cliente?.idCliente,
    });

    try {
      setCarregando(true);
      setErro(null);

      const idCliente = cliente?.idCliente;

      if (!idCliente) {
        throw new Error('Cliente não identificado para trocar a primeira senha.');
      }

      await clienteRepository.trocarPrimeiraSenha(idCliente, {
        novaSenha,
      });

      const clienteActualizado = {
        ...cliente,
        primeiraSenha: false,
      };

      setCliente(clienteActualizado);
      setPrimeiraSenha(false);
      setAutenticado(true);

      logSucesso('TROCAR_PRIMEIRA_SENHA', {
        idCliente,
        primeiraSenha: false,
      });

      return true;
    } catch (error) {
      logErro('TROCAR_PRIMEIRA_SENHA', error);

      setErro(error.message || 'Erro ao trocar a primeira senha.');
      throw error;
    } finally {
      setCarregando(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ALTERAR SENHA NORMAL
  // PATCH /api/clientes/{idCliente}/senha
  // ─────────────────────────────────────────────────────────────

  async function alterarSenha({ senhaActual, novaSenha }) {
    logInicio('ALTERAR_SENHA', {
      idCliente: cliente?.idCliente,
    });

    try {
      setCarregando(true);
      setErro(null);

      const idCliente = cliente?.idCliente;

      if (!idCliente) {
        throw new Error('Cliente não identificado para alterar a senha.');
      }

      await clienteRepository.alterarSenha(idCliente, {
        senhaActual,
        novaSenha,
      });

      logSucesso('ALTERAR_SENHA', {
        idCliente,
      });

      return true;
    } catch (error) {
      logErro('ALTERAR_SENHA', error);

      setErro(error.message || 'Erro ao alterar senha.');
      throw error;
    } finally {
      setCarregando(false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────

  function logout() {
    logInicio('LOGOUT_CLIENTE', {
      idCliente: cliente?.idCliente,
      email: cliente?.email,
    });

    try {
      clienteRepository.logout();

      setCliente(null);
      setAutenticado(false);
      setPrimeiraSenha(false);
      setErro(null);

      logSucesso('LOGOUT_CLIENTE');
    } catch (error) {
      logErro('LOGOUT_CLIENTE', error);

      setCliente(null);
      setAutenticado(false);
      setPrimeiraSenha(false);
      setErro(null);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS DE PERFIL
  // ─────────────────────────────────────────────────────────────

  const perfilCliente = cliente?.perfilCliente?.nomePerfilCliente || '';
  const perfilNormalizado = perfilCliente.toLowerCase();

  const clienteEhEmpresarial =
    perfilNormalizado.includes('empresarial') ||
    perfilNormalizado.includes('empresa');

  const clienteEhSingular =
    perfilNormalizado.includes('singular') ||
    perfilNormalizado.includes('regular') ||
    perfilNormalizado.includes('comum');

  // ─────────────────────────────────────────────────────────────
  // VALUE DO CONTEXT
  // ─────────────────────────────────────────────────────────────

  const value = useMemo(
    () => ({
      cliente,
      perfilCliente,

      autenticado,
      primeiraSenha,

      carregando,
      erro,

      clienteEhEmpresarial,
      clienteEhSingular,

      login,
      logout,
      registarCliente,
      trocarPrimeiraSenha,
      alterarSenha,
      restaurarSessao,

      limparErro: () => setErro(null),
    }),
    [
      cliente,
      perfilCliente,
      autenticado,
      primeiraSenha,
      carregando,
      erro,
      clienteEhEmpresarial,
      clienteEhSingular,
    ]
  );

  return (
    <ClienteAuthContext.Provider value={value}>
      {children}
    </ClienteAuthContext.Provider>
  );
}