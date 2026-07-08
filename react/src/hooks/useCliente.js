// src/hooks/useCliente.js

import { useContext, useMemo } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';

import { ClienteAuthContext } from '../contexts/clienteAuthContext';

// ─────────────────────────────────────────────────────────────
// LOGS
// ─────────────────────────────────────────────────────────────

function logInicio(acao, payload = {}) {
  console.info(`[useCliente] ${acao}_INICIO`, payload);
}

function logSucesso(acao, payload = {}) {
  console.info(`[useCliente] ${acao}_SUCESSO`, payload);
}

function logErro(acao, error) {
  console.error(`[useCliente] ${acao}_ERRO`, {
    status: error?.status,
    message: error?.message,
    data: error?.data,
  });
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

function limparTexto(valor) {
  return valor?.trim() || '';
}

function calcularForcaSenha(senha) {
  const value = senha || '';

  let score = 0;

  if (value.length >= 8) score += 1;
  if (/[A-Z]/.test(value)) score += 1;
  if (/[0-9]/.test(value)) score += 1;
  if (/[!@#$%^&*(),.?":{}|<>_\-+=]/.test(value)) score += 1;

  return score;
}

function getForcaSenhaLabel(score) {
  switch (score) {
    case 0:
    case 1:
      return 'Fraca';
    case 2:
      return 'Razoável';
    case 3:
      return 'Boa';
    case 4:
      return 'Excelente';
    default:
      return '';
  }
}

function getForcaSenhaClassName(score) {
  switch (score) {
    case 0:
    case 1:
      return 'senha-forca--fraca';
    case 2:
      return 'senha-forca--razoavel';
    case 3:
    case 4:
      return 'senha-forca--boa';
    default:
      return 'senha-forca--vazia';
  }
}

function obterDestinoTentado(location) {
  return location?.state?.from || null;
}

// ─────────────────────────────────────────────────────────────
// HOOK PRINCIPAL DO CLIENTE
// ─────────────────────────────────────────────────────────────

export function useCliente() {
  const context = useContext(ClienteAuthContext);
  const navigate = useNavigate();
  const location = useLocation();

  if (!context) {
    throw new Error('useCliente deve ser usado dentro de ClienteAuthProvider.');
  }

  const {
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
    limparErro,
    actualizarDadosCliente,
  } = context;

  // ─────────────────────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────────────────────

  async function executarLogin({ credencial, senha, destinoTentado }) {
    const credencialNormalizada = limparTexto(credencial);
    const destinoFinal = destinoTentado || obterDestinoTentado(location);

    logInicio('LOGIN_CLIENTE', {
      credencial: credencialNormalizada,
      destinoTentado: destinoFinal,
    });

    try {
      const response = await login({
        credencial: credencialNormalizada,
        senha,
      });

      logSucesso('LOGIN_CLIENTE', {
        idCliente: response?.cliente?.idCliente,
        nome: response?.cliente?.nome,
        email: response?.cliente?.email,
        primeiraSenha: response?.primeiraSenha,
        destinoTentado: destinoFinal,
      });

      if (response?.primeiraSenha === true) {
        navigate('/cliente/primeira-senha', { replace: true });
        return response;
      }

      navigate(destinoFinal || '/menu', { replace: true });

      return response;
    } catch (error) {
      logErro('LOGIN_CLIENTE', error);
      throw error;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // REGISTO PÚBLICO DO CLIENTE
  // ─────────────────────────────────────────────────────────────

  async function executarCadastroCliente({
    nome,
    apelido,
    email,
    telefone,
    senha,
    confirmarSenha,
  }) {
    logInicio('CADASTRO_CLIENTE', {
      nome: limparTexto(nome),
      apelido: limparTexto(apelido),
      email: limparTexto(email),
      telefone: limparTexto(telefone),
    });

    try {
      const clienteCriado = await registarCliente({
        nome,
        apelido,
        email,
        telefone,
        senha,
        confirmarSenha,
      });

      logSucesso('CADASTRO_CLIENTE', {
        idCliente: clienteCriado?.idCliente,
        nome: clienteCriado?.nome,
        email: clienteCriado?.email,
        telefone: clienteCriado?.telefone,
        primeiraSenha: clienteCriado?.primeiraSenha,
      });

      navigate('/cliente/login', {
        replace: true,
        state: {
          mensagem:
            'Conta criada com sucesso. Agora entre com o seu email ou telefone.',
        },
      });

      return clienteCriado;
    } catch (error) {
      logErro('CADASTRO_CLIENTE', error);
      throw error;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // TROCA OBRIGATÓRIA DA PRIMEIRA SENHA
  // ─────────────────────────────────────────────────────────────

  async function executarTrocaPrimeiraSenha({ novaSenha }) {
    logInicio('TROCAR_PRIMEIRA_SENHA_CLIENTE', {
      idCliente: cliente?.idCliente,
    });

    try {
      const result = await trocarPrimeiraSenha({
        novaSenha,
      });

      logSucesso('TROCAR_PRIMEIRA_SENHA_CLIENTE', {
        idCliente: cliente?.idCliente,
      });

      navigate('/menu', { replace: true });

      return result;
    } catch (error) {
      logErro('TROCAR_PRIMEIRA_SENHA_CLIENTE', error);
      throw error;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ALTERAR SENHA NORMAL
  // Depois de alterar, desloga o cliente
  // ─────────────────────────────────────────────────────────────

  async function executarAlterarSenha({ senhaActual, novaSenha }) {
    logInicio('ALTERAR_SENHA_CLIENTE', {
      idCliente: cliente?.idCliente,
    });

    try {
      const result = await alterarSenha({
        senhaActual,
        novaSenha,
      });

      logSucesso('ALTERAR_SENHA_CLIENTE', {
        idCliente: cliente?.idCliente,
        acaoPosterior: 'logout',
      });

      logout();

      navigate('/cliente/login', {
        replace: true,
        state: {
          mensagem:
            'Senha alterada com sucesso. Faça login novamente com a nova senha.',
        },
      });

      return result;
    } catch (error) {
      logErro('ALTERAR_SENHA_CLIENTE', error);
      throw error;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────

  function executarLogout() {
    logInicio('LOGOUT_CLIENTE', {
      idCliente: cliente?.idCliente,
      email: cliente?.email,
    });

    logout();

    logSucesso('LOGOUT_CLIENTE');

    navigate('/menu', { replace: true });
  }

  // ─────────────────────────────────────────────────────────────
// EDITAR DADOS DO CLIENTE
// Depois de actualizar, desloga o cliente
// ─────────────────────────────────────────────────────────────

async function executarEditarDadosCliente({
  nome,
  apelido,
  email,
  telefone,
}) {
  logInicio('EDITAR_DADOS_CLIENTE', {
    idCliente: cliente?.idCliente,
    nome: limparTexto(nome),
    apelido: limparTexto(apelido),
    email: limparTexto(email),
    telefone: limparTexto(telefone),
  });

  try {
    const clienteActualizado = await actualizarDadosCliente({
      nome,
      apelido,
      email,
      telefone,
    });

    logSucesso('EDITAR_DADOS_CLIENTE', {
      idCliente: clienteActualizado?.idCliente,
      nome: clienteActualizado?.nome,
      email: clienteActualizado?.email,
      acaoPosterior: 'logout',
    });

    logout();

    navigate('/cliente/login', {
      replace: true,
      state: {
        mensagem:
          'Dados actualizados com sucesso. Faça login novamente para continuar.',
      },
    });

    return clienteActualizado;
  } catch (error) {
    logErro('EDITAR_DADOS_CLIENTE', error);
    throw error;
  }
}


  // ─────────────────────────────────────────────────────────────
  // FORÇA DA SENHA
  // ─────────────────────────────────────────────────────────────

  function analisarSenha(senha, confirmarSenha = '') {
    const score = calcularForcaSenha(senha);
    const label = senha ? getForcaSenhaLabel(score) : '';
    const className = getForcaSenhaClassName(score);

    const requisitos = {
      minimo8: senha.length >= 8,
      diferentePadrao: senha.length > 0 && senha !== '12345678',
      temMaiuscula: /[A-Z]/.test(senha),
      temNumero: /[0-9]/.test(senha),
      temEspecial: /[!@#$%^&*(),.?":{}|<>_\-+=]/.test(senha),
      confirmacaoIgual:
        senha.length > 0 &&
        confirmarSenha.length > 0 &&
        senha === confirmarSenha,
    };

    const senhaValida =
      requisitos.minimo8 &&
      requisitos.diferentePadrao &&
      requisitos.confirmacaoIgual;

    const resultado = {
      score,
      label,
      className,
      requisitos,
      senhaValida,
    };

    console.info('[useCliente] ANALISAR_SENHA_RESULTADO', {
      score,
      label,
      senhaValida,
      requisitos,
    });

    return resultado;
  }

  // ─────────────────────────────────────────────────────────────
  // DADOS DERIVADOS DO CLIENTE
  // ─────────────────────────────────────────────────────────────

  const nomeCompletoCliente = useMemo(() => {
    if (!cliente) return '';

    return `${cliente.nome || ''} ${cliente.apelido || ''}`.trim();
  }, [cliente]);

  const iniciaisCliente = useMemo(() => {
    const nomeBase = nomeCompletoCliente || cliente?.email || 'Cliente';

    const partes = nomeBase.trim().split(/\s+/);

    if (!partes.length || !partes[0]) {
      return 'CL';
    }

    if (partes.length === 1) {
      return partes[0].substring(0, 2).toUpperCase();
    }

    return `${partes[0][0]}${partes[partes.length - 1][0]}`.toUpperCase();
  }, [nomeCompletoCliente, cliente]);

  return {
    // Estado
    cliente,
    perfilCliente,
    nomeCompletoCliente,
    iniciaisCliente,

    autenticado,
    primeiraSenha,

    carregando,
    erro,

    clienteEhEmpresarial,
    clienteEhSingular,

    // Acções
    executarLogin,
    executarCadastroCliente,
    executarTrocaPrimeiraSenha,
    executarAlterarSenha,
    executarLogout,

    restaurarSessao,
    limparErro,

    // Utilitários
    analisarSenha,
    executarEditarDadosCliente,
  };
}