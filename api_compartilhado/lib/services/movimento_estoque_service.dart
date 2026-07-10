import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/movimento_estoque_model.dart';

class MovimentoEstoqueService {
  final http.Client _client;

  MovimentoEstoqueService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<MovimentoEstoqueModel>> listarMovimentos({
    TipoItemEstoqueModel? tipoItem,
    TipoMovimentoEstoqueModel? tipoMovimento,
    int? idProduto,
    int? idIngrediente,
    int? idUsuario,
    DateTime? inicio,
    DateTime? fim,
  }) async {
    final uri = Uri.parse(ApiConfig.movimentosEstoqueUrl).replace(
      queryParameters: {
        if (tipoItem != null) 'tipoItem': tipoItem.apiValue,
        if (tipoMovimento != null) 'tipoMovimento': tipoMovimento.apiValue,
        if (idProduto != null) 'idProduto': idProduto.toString(),
        if (idIngrediente != null) 'idIngrediente': idIngrediente.toString(),
        if (idUsuario != null) 'idUsuario': idUsuario.toString(),
        if (inicio != null) 'inicio': inicio.toIso8601String(),
        if (fim != null) 'fim': fim.toIso8601String(),
      },
    );

    final response = await _client
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(MovimentoEstoqueModel.fromJson)
            .toList();
      }

      throw Exception('Resposta inválida ao listar movimentos de estoque.');
    }

    throw Exception(_extrairMensagemErro(response));
  }

  Future<MovimentoEstoqueModel> buscarPorId(
    int idMovimentoEstoque,
  ) async {
    final uri = Uri.parse(
      ApiConfig.movimentoEstoquePorIdUrl(idMovimentoEstoque),
    );

    final response = await _client
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        return MovimentoEstoqueModel.fromJson(decoded);
      }

      throw Exception('Resposta inválida ao buscar movimento de estoque.');
    }

    throw Exception(_extrairMensagemErro(response));
  }

  Future<MovimentoEstoqueModel> movimentarEstoque(
    MovimentoEstoqueModel movimento,
  ) async {
    final uri = Uri.parse(ApiConfig.movimentosEstoqueUrl);

    final response = await _client
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(movimento.toRequestJson()),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        return MovimentoEstoqueModel.fromJson(decoded);
      }

      throw Exception('Resposta inválida ao movimentar estoque.');
    }

    throw Exception(_extrairMensagemErro(response));
  }

  String _extrairMensagemErro(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ??
            decoded['mensagem'] ??
            decoded['error'] ??
            decoded['erro'];

        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // mantém fallback
    }

    return 'Erro ${response.statusCode}: ${response.reasonPhrase ?? 'Falha na comunicação com o servidor.'}';
  }
}