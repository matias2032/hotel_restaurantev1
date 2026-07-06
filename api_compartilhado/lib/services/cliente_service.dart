import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/cliente_model.dart';

class ClienteService {
  final http.Client _client;

  ClienteService({
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  // ─────────────────────────────────────────────────────────────
  // PERFIS DE CLIENTE
  // ─────────────────────────────────────────────────────────────

  Future<List<PerfilClienteModel>> listarPerfisCliente() async {
    final uri = Uri.parse(ApiConfig.perfisClienteUrl);

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    return data
        .map((e) => PerfilClienteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PerfilClienteModel> buscarPerfilClientePorId(
    int idPerfilCliente,
  ) async {
    final uri = Uri.parse(ApiConfig.perfilClientePorIdUrl(idPerfilCliente));

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return PerfilClienteModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<PerfilClienteModel> criarPerfilCliente(
    PerfilClienteModel perfil,
  ) async {
    final uri = Uri.parse(ApiConfig.perfisClienteUrl);

    final response = await _client
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(perfil.toCreateJson()),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return PerfilClienteModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<PerfilClienteModel> editarPerfilCliente({
    required int idPerfilCliente,
    required PerfilClienteModel perfil,
  }) async {
    final uri = Uri.parse(ApiConfig.perfilClientePorIdUrl(idPerfilCliente));

    final response = await _client
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(perfil.toUpdateJson()),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return PerfilClienteModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CLIENTES
  // ─────────────────────────────────────────────────────────────

  Future<List<ClienteModel>> listarClientes({
    bool somenteAtivos = false,
  }) async {
    final url = somenteAtivos
        ? '${ApiConfig.clientesUrl}?somenteAtivos=true'
        : ApiConfig.clientesUrl;

    final uri = Uri.parse(url);

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    return data
        .map((e) => ClienteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClienteModel>> listarClientesResumo() async {
    final uri = Uri.parse('${ApiConfig.clientesUrl}/resumo');

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    return data
        .map((e) => ClienteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClienteModel> buscarClientePorId(int idCliente) async {
    final uri = Uri.parse(ApiConfig.clientePorIdUrl(idCliente));

    final response = await _client
        .get(uri, headers: ApiConfig.authHeaders)
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return ClienteModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<ClienteModel> criarCliente({
    required ClienteModel cliente,
    required int idPerfilCliente,
  }) async {
    final uri = Uri.parse(ApiConfig.clientesUrl);

    final response = await _client
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
            cliente.toCreateJson(idPerfilCliente: idPerfilCliente),
          ),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return ClienteModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<ClienteModel> editarCliente({
    required int idCliente,
    required ClienteModel cliente,
    required int idPerfilCliente,
  }) async {
    final uri = Uri.parse(ApiConfig.clientePorIdUrl(idCliente));

    final response = await _client
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
            cliente.toUpdateJson(idPerfilCliente: idPerfilCliente),
          ),
        )
        .timeout(ApiConfig.timeout);

    _validarResposta(response);

    return ClienteModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MÉTODOS REMOVIDOS DO FLUTTER ADMIN
  // ─────────────────────────────────────────────────────────────
  //
  // Estes fluxos foram removidos do painel administrativo Flutter:
  //
  // - alterarAtivoCliente(...)
  // - resetarSenhaPadrao(...)
  // - eliminarCliente(...)
  //
  // Motivo:
  // O cliente terá fluxo próprio de recuperação/reinício de senha via email,
  // e a desactivação manual pelo admin ficará indisponível neste momento.

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