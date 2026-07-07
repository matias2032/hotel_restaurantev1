// src/api/httpClient.js

import axios from 'axios';
import { API_BASE_URL, API_TIMEOUT_MS } from './apiConfig';
import { sessaoClienteStorage } from '../storage/sessaoClienteStorage';

export const httpClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT_MS,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
});

httpClient.interceptors.request.use(
  (config) => {
    console.info('[HttpClient] REQUEST_INICIO', {
      method: config.method?.toUpperCase(),
      url: config.url,
      baseURL: config.baseURL,
    });

    const authorization = sessaoClienteStorage.obterAuthorizationHeader();

    if (authorization) {
      config.headers.Authorization = authorization;

      console.info('[HttpClient] REQUEST_AUTH_HEADER_ADICIONADO', {
        url: config.url,
        tokenPresente: true,
      });
    } else {
      console.info('[HttpClient] REQUEST_SEM_AUTH_HEADER', {
        url: config.url,
        tokenPresente: false,
      });
    }

    return config;
  },
  (error) => {
    console.error('[HttpClient] REQUEST_ERRO', {
      message: error?.message,
    });

    return Promise.reject(error);
  }
);

httpClient.interceptors.response.use(
  (response) => {
    console.info('[HttpClient] RESPONSE_SUCESSO', {
      method: response.config?.method?.toUpperCase(),
      url: response.config?.url,
      status: response.status,
    });

    return response;
  },
  (error) => {
    const status = error.response?.status;

    const message =
      error.response?.data?.message ||
      error.response?.data?.error ||
      error.response?.data?.detail ||
      error.response?.data?.title ||
      error.message ||
      'Erro inesperado ao comunicar com o servidor.';

    console.error('[HttpClient] RESPONSE_ERRO', {
      method: error.config?.method?.toUpperCase(),
      url: error.config?.url,
      status,
      message,
      data: error.response?.data,
    });

    if (status === 401) {
      console.warn('[HttpClient] TOKEN_INVALIDO_OU_EXPIRADO_LIMPANDO_SESSAO');
      sessaoClienteStorage.limparSessao();
    }

    return Promise.reject({
      original: error,
      status,
      message,
      data: error.response?.data,
    });
  }
);