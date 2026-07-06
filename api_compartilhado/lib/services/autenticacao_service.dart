import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/auth_model.dart';
import '../models/usuario_model.dart';
import 'sessao_service.dart';

class AutenticacaoService {
  final http.Client _client;

  AutenticacaoService({
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  Future<ResultadoAutenticacao> login({
    required String credencial,
    required String senha,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConfig.authLoginUrl),
            headers: ApiConfig.authHeaders,
            body: jsonEncode({
              'credencial': credencial.trim(),
              'senha': senha,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(
          utf8.decode(response.bodyBytes),
        ) as Map<String, dynamic>;

        final usuarioJson = data['usuario'];

        final accessToken = data['accessToken']?.toString();
final tokenType = data['tokenType']?.toString() ?? 'Bearer';
final expiresInMinutes = int.tryParse(
  data['expiresInMinutes']?.toString() ?? '',
);

        if (usuarioJson is! Map<String, dynamic>) {
          return const ResultadoAutenticacao(
            status: StatusAutenticacao.erroDesconhecido,
            mensagem: 'Resposta de login inválida.',
          );
        }

        final usuario = UsuarioModel.fromJson(usuarioJson);

        if (!usuario.ativo) {
          return const ResultadoAutenticacao(
            status: StatusAutenticacao.usuarioInativo,
            mensagem: 'Este usuário está inactivo.',
          );
        }

SessaoService.instance.iniciar(
  usuario,
  accessToken: accessToken,
  tokenType: tokenType,
);

        if (usuario.primeiraSenha) {
      return ResultadoAutenticacao(
  status: StatusAutenticacao.primeiraSenha,
  mensagem: 'É necessário definir uma nova senha.',
  usuario: usuario,
  accessToken: accessToken,
  tokenType: tokenType,
  expiresInMinutes: expiresInMinutes,
);
        }

    return ResultadoAutenticacao(
  status: StatusAutenticacao.sucesso,
  mensagem: 'Login realizado com sucesso.',
  usuario: usuario,
  accessToken: accessToken,
  tokenType: tokenType,
  expiresInMinutes: expiresInMinutes,
);

        
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return ResultadoAutenticacao(
          status: StatusAutenticacao.credenciaisInvalidas,
          mensagem: _extrairMensagemErro(
            response,
            fallback: 'Credencial ou senha incorrectos.',
          ),
        );
      }

      return ResultadoAutenticacao(
        status: StatusAutenticacao.erroDesconhecido,
        mensagem: _extrairMensagemErro(
          response,
          fallback: 'Erro inesperado ao iniciar sessão.',
        ),
      );
    } catch (e) {
      return ResultadoAutenticacao(
        status: StatusAutenticacao.erroDesconhecido,
        mensagem: 'Erro de conexão: $e',
      );
    }
  }

  Future<ResultadoAutenticacao> trocarPrimeiraSenha({
  required int idUsuario,
  required String novaSenha,
}) async {
  try {
    final response = await _client
        .patch(
          Uri.parse(ApiConfig.authPrimeiraSenhaUrl(idUsuario)),
          headers: ApiConfig.authHeaders,
          body: jsonEncode({
            'novaSenha': novaSenha,
          }),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      SessaoService.instance.encerrar();

      return const ResultadoAutenticacao(
        status: StatusAutenticacao.sucesso,
        mensagem: 'Senha alterada com sucesso.',
      );
    }

    return ResultadoAutenticacao(
      status: StatusAutenticacao.erroDesconhecido,
      mensagem: _extrairMensagemErro(
        response,
        fallback: 'Não foi possível alterar a senha.',
      ),
    );
  } catch (e) {
    return ResultadoAutenticacao(
      status: StatusAutenticacao.erroDesconhecido,
      mensagem: 'Erro de conexão: $e',
    );
  }
}

  String _extrairMensagemErro(
    http.Response response, {
    required String fallback,
  }) {
    try {
      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['erro']?.toString() ??
            decoded['error']?.toString() ??
            fallback;
      }

      return fallback;
    } catch (_) {
      return response.body.isNotEmpty ? response.body : fallback;
    }
  }
}