// src/storage/sessaoClienteStorage.js

const TOKEN_KEY =
  import.meta.env.VITE_CLIENTE_TOKEN_STORAGE_KEY ||
  'hotel_restaurante_cliente_token';

const TOKEN_TYPE_KEY =
  import.meta.env.VITE_CLIENTE_TOKEN_TYPE_STORAGE_KEY ||
  'hotel_restaurante_cliente_token_type';

const CLIENTE_KEY =
  import.meta.env.VITE_CLIENTE_DATA_STORAGE_KEY ||
  'hotel_restaurante_cliente_data';

const PRIMEIRA_SENHA_KEY =
  import.meta.env.VITE_CLIENTE_PRIMEIRA_SENHA_STORAGE_KEY ||
  'hotel_restaurante_cliente_primeira_senha';

const EXPIRES_IN_KEY =
  import.meta.env.VITE_CLIENTE_EXPIRES_IN_STORAGE_KEY ||
  'hotel_restaurante_cliente_expires_in';

function logInicio(acao, payload = {}) {
  console.info(`[SessaoClienteStorage] ${acao}_INICIO`, payload);
}

function logSucesso(acao, payload = {}) {
  console.info(`[SessaoClienteStorage] ${acao}_SUCESSO`, payload);
}

function logErro(acao, error) {
  console.error(`[SessaoClienteStorage] ${acao}_ERRO`, {
    message: error?.message,
  });
}

export const sessaoClienteStorage = {
  salvarSessao(loginResponse) {
    logInicio('SALVAR_SESSAO_CLIENTE');

    try {
      if (!loginResponse) {
        console.warn('[SessaoClienteStorage] SALVAR_SESSAO_CLIENTE_IGNORADA', {
          motivo: 'loginResponse vazio',
        });

        return;
      }

      const {
        accessToken,
        tokenType,
        cliente,
        primeiraSenha,
        expiresInMinutes,
      } = loginResponse;

      if (accessToken) {
        localStorage.setItem(TOKEN_KEY, accessToken);
      }

      localStorage.setItem(TOKEN_TYPE_KEY, tokenType || 'Bearer');

      if (cliente) {
        localStorage.setItem(CLIENTE_KEY, JSON.stringify(cliente));
      }

      localStorage.setItem(
        PRIMEIRA_SENHA_KEY,
        primeiraSenha === true ? 'true' : 'false'
      );

      if (expiresInMinutes !== undefined && expiresInMinutes !== null) {
        localStorage.setItem(EXPIRES_IN_KEY, String(expiresInMinutes));
      }

      logSucesso('SALVAR_SESSAO_CLIENTE', {
        idCliente: cliente?.idCliente,
        email: cliente?.email,
        primeiraSenha: primeiraSenha === true,
        tokenType: tokenType || 'Bearer',
        expiresInMinutes,
      });
    } catch (error) {
      logErro('SALVAR_SESSAO_CLIENTE', error);
      throw error;
    }
  },

  obterAccessToken() {
    logInicio('OBTER_ACCESS_TOKEN_CLIENTE');

    try {
      const token = localStorage.getItem(TOKEN_KEY);

      logSucesso('OBTER_ACCESS_TOKEN_CLIENTE', {
        existeToken: Boolean(token),
      });

      return token;
    } catch (error) {
      logErro('OBTER_ACCESS_TOKEN_CLIENTE', error);
      return null;
    }
  },

  obterTokenType() {
    logInicio('OBTER_TOKEN_TYPE_CLIENTE');

    try {
      const tokenType = localStorage.getItem(TOKEN_TYPE_KEY) || 'Bearer';

      logSucesso('OBTER_TOKEN_TYPE_CLIENTE', {
        tokenType,
      });

      return tokenType;
    } catch (error) {
      logErro('OBTER_TOKEN_TYPE_CLIENTE', error);
      return 'Bearer';
    }
  },

  obterAuthorizationHeader() {
    logInicio('OBTER_AUTHORIZATION_HEADER_CLIENTE');

    try {
      const token = this.obterAccessToken();

      if (!token) {
        logSucesso('OBTER_AUTHORIZATION_HEADER_CLIENTE', {
          existeAuthorization: false,
        });

        return null;
      }

      const tokenType = this.obterTokenType();
      const authorization = `${tokenType} ${token}`;

      logSucesso('OBTER_AUTHORIZATION_HEADER_CLIENTE', {
        existeAuthorization: true,
        tokenType,
      });

      return authorization;
    } catch (error) {
      logErro('OBTER_AUTHORIZATION_HEADER_CLIENTE', error);
      return null;
    }
  },

  obterCliente() {
    logInicio('OBTER_CLIENTE_LOGADO');

    try {
      const raw = localStorage.getItem(CLIENTE_KEY);

      if (!raw) {
        logSucesso('OBTER_CLIENTE_LOGADO', {
          existeCliente: false,
        });

        return null;
      }

      const cliente = JSON.parse(raw);

      logSucesso('OBTER_CLIENTE_LOGADO', {
        existeCliente: true,
        idCliente: cliente?.idCliente,
        email: cliente?.email,
      });

      return cliente;
    } catch (error) {
      logErro('OBTER_CLIENTE_LOGADO', error);
      return null;
    }
  },

  clienteTemPrimeiraSenha() {
    logInicio('VERIFICAR_PRIMEIRA_SENHA_CLIENTE');

    try {
      const primeiraSenha =
        localStorage.getItem(PRIMEIRA_SENHA_KEY) === 'true';

      logSucesso('VERIFICAR_PRIMEIRA_SENHA_CLIENTE', {
        primeiraSenha,
      });

      return primeiraSenha;
    } catch (error) {
      logErro('VERIFICAR_PRIMEIRA_SENHA_CLIENTE', error);
      return false;
    }
  },

  actualizarPrimeiraSenha(valor) {
    logInicio('ACTUALIZAR_PRIMEIRA_SENHA_CLIENTE', {
      primeiraSenha: valor === true,
    });

    try {
      localStorage.setItem(
        PRIMEIRA_SENHA_KEY,
        valor === true ? 'true' : 'false'
      );

      const cliente = this.obterCliente();

      if (cliente) {
        const clienteActualizado = {
          ...cliente,
          primeiraSenha: valor === true,
        };

        localStorage.setItem(CLIENTE_KEY, JSON.stringify(clienteActualizado));
      }

      logSucesso('ACTUALIZAR_PRIMEIRA_SENHA_CLIENTE', {
        primeiraSenha: valor === true,
        idCliente: cliente?.idCliente,
      });
    } catch (error) {
      logErro('ACTUALIZAR_PRIMEIRA_SENHA_CLIENTE', error);
      throw error;
    }
  },

  obterExpiresInMinutes() {
    logInicio('OBTER_EXPIRACAO_CLIENTE');

    try {
      const value = localStorage.getItem(EXPIRES_IN_KEY);

      if (!value) {
        logSucesso('OBTER_EXPIRACAO_CLIENTE', {
          expiresInMinutes: null,
        });

        return null;
      }

      const parsed = Number(value);
      const expiresInMinutes = Number.isNaN(parsed) ? null : parsed;

      logSucesso('OBTER_EXPIRACAO_CLIENTE', {
        expiresInMinutes,
      });

      return expiresInMinutes;
    } catch (error) {
      logErro('OBTER_EXPIRACAO_CLIENTE', error);
      return null;
    }
  },

  estaAutenticado() {
    logInicio('VERIFICAR_AUTENTICACAO_CLIENTE');

    try {
      const autenticado = Boolean(this.obterAccessToken());

      logSucesso('VERIFICAR_AUTENTICACAO_CLIENTE', {
        autenticado,
      });

      return autenticado;
    } catch (error) {
      logErro('VERIFICAR_AUTENTICACAO_CLIENTE', error);
      return false;
    }
  },

  limparSessao() {
    logInicio('LIMPAR_SESSAO_CLIENTE');

    try {
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem(TOKEN_TYPE_KEY);
      localStorage.removeItem(CLIENTE_KEY);
      localStorage.removeItem(PRIMEIRA_SENHA_KEY);
      localStorage.removeItem(EXPIRES_IN_KEY);

      logSucesso('LIMPAR_SESSAO_CLIENTE');
    } catch (error) {
      logErro('LIMPAR_SESSAO_CLIENTE', error);
      throw error;
    }
  },
};