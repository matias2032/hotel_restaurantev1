import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  final http.Client _client;

  UsuarioService({
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  // ─────────────────────────────────────────────────────────────
  // PERFIS
  // ─────────────────────────────────────────────────────────────

  Future<List<PerfilModel>> listarPerfis({
    bool somenteAtivos = false,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.perfisUrl}?somenteAtivos=$somenteAtivos',
    );

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    return data
        .map((e) => PerfilModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PerfilModel> buscarPerfilPorId(int idPerfil) async {
    final uri = Uri.parse(ApiConfig.perfilPorIdUrl(idPerfil));

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return PerfilModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<PerfilModel> criarPerfil(PerfilModel perfil) async {
    final uri = Uri.parse(ApiConfig.perfisUrl);

    final response = await _client
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(perfil.toCreateJson()),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return PerfilModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<PerfilModel> editarPerfil({
    required int idPerfil,
    required PerfilModel perfil,
  }) async {
    final uri = Uri.parse(ApiConfig.perfilPorIdUrl(idPerfil));

    final response = await _client
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(perfil.toUpdateJson()),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return PerfilModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

Future<PerfilModel> alterarAtivoPerfil({
  required int idPerfil,
  required bool ativo,
}) async {
  final uri = Uri.parse(ApiConfig.perfilAtivoUrl(idPerfil, ativo));

  final response = await _client
      .patch(uri, headers: ApiConfig.authHeaders)
      .timeout(ApiConfig.timeout);

  _validarResposta(response);

  return PerfilModel.fromJson(
    jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
  );
}

Future<PerfilModel> activarPerfil(int idPerfil) {
  return alterarAtivoPerfil(
    idPerfil: idPerfil,
    ativo: true,
  );
}

Future<PerfilModel> desactivarPerfil(int idPerfil) {
  return alterarAtivoPerfil(
    idPerfil: idPerfil,
    ativo: false,
  );
}

  // ─────────────────────────────────────────────────────────────
  // USUÁRIOS
  // ─────────────────────────────────────────────────────────────

  Future<List<UsuarioModel>> listarUsuarios({
    bool somenteAtivos = false,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.usuariosUrl}?somenteAtivos=$somenteAtivos',
    );

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    return data
        .map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UsuarioModel>> listarUsuariosResumo() async {
    final uri = Uri.parse('${ApiConfig.usuariosUrl}/resumo');

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    return data
        .map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UsuarioModel> buscarUsuarioPorId(int idUsuario) async {
    final uri = Uri.parse(ApiConfig.usuarioPorIdUrl(idUsuario));

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return UsuarioModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<UsuarioModel> criarUsuario({
    required UsuarioModel usuario,
    required int idPerfil,
  }) async {
    final uri = Uri.parse(ApiConfig.usuariosUrl);

    final response = await _client
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(usuario.toCreateJson(idPerfil: idPerfil)),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return UsuarioModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<UsuarioModel> editarUsuario({
    required int idUsuario,
    required UsuarioModel usuario,
    required int idPerfil,
  }) async {
    final uri = Uri.parse(ApiConfig.usuarioPorIdUrl(idUsuario));

    final response = await _client
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(usuario.toUpdateJson(idPerfil: idPerfil)),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return UsuarioModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

Future<UsuarioModel> alterarAtivoUsuario({
  required int idUsuario,
  required bool ativo,
}) async {
  final uri = Uri.parse(ApiConfig.usuarioAtivoUrl(idUsuario, ativo));

  final response = await _client
      .patch(uri, headers: ApiConfig.authHeaders)
      .timeout(ApiConfig.timeout);

  _validarResposta(response);

  return UsuarioModel.fromJson(
    jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
  );
}

  Future<void> alterarSenha({
    required int idUsuario,
    required String senhaActual,
    required String novaSenha,
  }) async {
    final uri = Uri.parse(ApiConfig.usuarioAlterarSenhaUrl(idUsuario));

    final response = await _client
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode({
            'senhaActual': senhaActual,
            'novaSenha': novaSenha,
          }),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);
  }

  Future<void> trocarPrimeiraSenha({
    required int idUsuario,
    required String novaSenha,
  }) async {
    final uri = Uri.parse(ApiConfig.usuarioPrimeiraSenhaUrl(idUsuario));

    final response = await _client
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode({
            'novaSenha': novaSenha,
          }),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);
  }

  Future<void> resetarSenhaPadrao(int idUsuario) async {
    final uri = Uri.parse(ApiConfig.usuarioResetarSenhaUrl(idUsuario));

    final response = await _client
        .patch(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);
  }

  Future<void> eliminarUsuario(int idUsuario) async {
    final uri = Uri.parse(ApiConfig.usuarioPorIdUrl(idUsuario));

    final response = await _client
        .delete(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  void _validarResposta(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String mensagem = 'Erro HTTP ${response.statusCode}';

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        mensagem = decoded['message']?.toString() ??
            decoded['erro']?.toString() ??
            decoded['error']?.toString() ??
            mensagem;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        mensagem = response.body;
      }
    }

    throw Exception(mensagem);
  }
}