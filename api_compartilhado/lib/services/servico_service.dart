import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/servico_model.dart';

class ServicoService {
  static const String _basePath = '/api/catalogo/servicos';

  String get _servicosUrl {
    return '${ApiConfig.baseUrl}$_basePath';
  }

  String get _categoriasUrl {
    return '$_servicosUrl/categorias';
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────────────────────────

  Future<List<CategoriaServicoModel>> listarCategorias({
    bool somenteAtivas = false,
  }) async {
    final uri = Uri.parse(_categoriasUrl).replace(
      queryParameters: {
        if (somenteAtivas) 'somenteAtivas': 'true',
      },
    );

    debugPrint(
      '[ServicoService] LISTAR_CATEGORIAS_INICIO — somenteAtivas=$somenteAtivas',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaLista(response);

    final categorias = data
        .whereType<Map<String, dynamic>>()
        .map(CategoriaServicoModel.fromJson)
        .toList();

    debugPrint(
      '[ServicoService] LISTAR_CATEGORIAS_SUCESSO — total=${categorias.length}',
    );

    return categorias;
  }

  Future<CategoriaServicoModel> buscarCategoriaPorId(
    int idCategoriaServico,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaServico');

    debugPrint(
      '[ServicoService] BUSCAR_CATEGORIA_INICIO — id=$idCategoriaServico',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoria = CategoriaServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
    );

    return categoria;
  }

  Future<CategoriaServicoModel> criarCategoria(
    CategoriaServicoModel categoria,
  ) async {
    final uri = Uri.parse(_categoriasUrl);

    debugPrint(
      '[ServicoService] CRIAR_CATEGORIA_INICIO — nome=${categoria.nome}',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(categoria.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoriaCriada = CategoriaServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] CRIAR_CATEGORIA_SUCESSO — id=${categoriaCriada.idCategoriaServico}',
    );

    return categoriaCriada;
  }

  Future<CategoriaServicoModel> editarCategoria(
    int idCategoriaServico,
    CategoriaServicoModel categoria,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaServico');

    debugPrint(
      '[ServicoService] EDITAR_CATEGORIA_INICIO — id=$idCategoriaServico',
    );

    final response = await http
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(categoria.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoriaEditada = CategoriaServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
    );

    return categoriaEditada;
  }

  Future<CategoriaServicoModel> alterarEstadoCategoria(
    int idCategoriaServico,
    bool ativo,
  ) async {
    final uri = Uri.parse(
      '$_categoriasUrl/$idCategoriaServico/estado',
    );

    debugPrint(
      '[ServicoService] ALTERAR_ESTADO_CATEGORIA_INICIO — '
      'id=$idCategoriaServico ativo=$ativo',
    );

    final response = await http
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode({
            'ativo': ativo,
          }),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoria = CategoriaServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
      'id=$idCategoriaServico ativo=${categoria.ativo}',
    );

    return categoria;
  }

  Future<void> desativarCategoria(
    int idCategoriaServico,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaServico');

    debugPrint(
      '[ServicoService] DESATIVAR_CATEGORIA_INICIO — id=$idCategoriaServico',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    _tratarRespostaSemConteudo(response);

    debugPrint(
      '[ServicoService] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SERVIÇOS
  // ─────────────────────────────────────────────────────────────

  Future<List<ServicoModel>> listarServicos({
    bool somenteAtivos = false,
    bool somenteDisponiveis = false,
    bool somenteDestaques = false,
    int? idCategoriaServico,
  }) async {
    final uri = Uri.parse(_servicosUrl).replace(
      queryParameters: {
        if (somenteAtivos) 'somenteAtivos': 'true',
        if (somenteDisponiveis) 'somenteDisponiveis': 'true',
        if (somenteDestaques) 'somenteDestaques': 'true',
        if (idCategoriaServico != null)
          'idCategoriaServico': idCategoriaServico.toString(),
      },
    );

    debugPrint(
      '[ServicoService] LISTAR_SERVICOS_INICIO — '
      'somenteAtivos=$somenteAtivos, '
      'somenteDisponiveis=$somenteDisponiveis, '
      'somenteDestaques=$somenteDestaques, '
      'idCategoriaServico=$idCategoriaServico',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaLista(response);

    final servicos = data
        .whereType<Map<String, dynamic>>()
        .map(ServicoModel.fromJson)
        .toList();

    debugPrint(
      '[ServicoService] LISTAR_SERVICOS_SUCESSO — total=${servicos.length}',
    );

    return servicos;
  }

  Future<ServicoModel> buscarServicoPorId(
    int idServico,
  ) async {
    final uri = Uri.parse('$_servicosUrl/$idServico');

    debugPrint(
      '[ServicoService] BUSCAR_SERVICO_INICIO — id=$idServico',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servico = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] BUSCAR_SERVICO_SUCESSO — id=$idServico',
    );

    return servico;
  }

  Future<ServicoModel> criarServico(
    ServicoModel servico,
  ) async {
    final uri = Uri.parse(_servicosUrl);

    debugPrint(
      '[ServicoService] CRIAR_SERVICO_INICIO — nome=${servico.nome}',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
            servico.toJson(
              enviarImagens: true,
            ),
          ),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servicoCriado = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] CRIAR_SERVICO_SUCESSO — id=${servicoCriado.idServico}',
    );

    return servicoCriado;
  }

  Future<ServicoModel> editarServico(
    int idServico,
    ServicoModel servico, {
    bool enviarImagens = true,
  }) async {
    final uri = Uri.parse('$_servicosUrl/$idServico');

    debugPrint(
      '[ServicoService] EDITAR_SERVICO_INICIO — '
      'id=$idServico enviarImagens=$enviarImagens',
    );

    final response = await http
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
            servico.toJson(
              enviarImagens: enviarImagens,
            ),
          ),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servicoEditado = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] EDITAR_SERVICO_SUCESSO — id=$idServico',
    );

    return servicoEditado;
  }

  Future<ServicoModel> alterarDisponibilidadeServico(
    int idServico,
    bool disponivel,
  ) async {
    final uri = Uri.parse(
      '$_servicosUrl/$idServico/disponibilidade',
    );

    debugPrint(
      '[ServicoService] ALTERAR_DISPONIBILIDADE_SERVICO_INICIO — '
      'id=$idServico disponivel=$disponivel',
    );

    final response = await http
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode({
            'disponivel': disponivel,
          }),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servico = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] ALTERAR_DISPONIBILIDADE_SERVICO_SUCESSO — '
      'id=$idServico disponivel=${servico.disponivel}',
    );

    return servico;
  }

  Future<ServicoModel> alterarDestaqueServico(
    int idServico,
    bool destaque,
  ) async {
    final uri = Uri.parse(
      '$_servicosUrl/$idServico/destaque',
    );

    debugPrint(
      '[ServicoService] ALTERAR_DESTAQUE_SERVICO_INICIO — '
      'id=$idServico destaque=$destaque',
    );

    final response = await http
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode({
            'destaque': destaque,
          }),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servico = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] ALTERAR_DESTAQUE_SERVICO_SUCESSO — '
      'id=$idServico destaque=${servico.destaque}',
    );

    return servico;
  }

  Future<ServicoModel> alterarEstadoServico(
    int idServico,
    bool ativo,
  ) async {
    final uri = Uri.parse(
      '$_servicosUrl/$idServico/estado',
    );

    debugPrint(
      '[ServicoService] ALTERAR_ESTADO_SERVICO_INICIO — '
      'id=$idServico ativo=$ativo',
    );

    final response = await http
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode({
            'ativo': ativo,
          }),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servico = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] ALTERAR_ESTADO_SERVICO_SUCESSO — '
      'id=$idServico ativo=${servico.ativo} '
      'disponivel=${servico.disponivel} destaque=${servico.destaque}',
    );

    return servico;
  }

  Future<void> desativarServico(
    int idServico,
  ) async {
    final uri = Uri.parse('$_servicosUrl/$idServico');

    debugPrint(
      '[ServicoService] DESATIVAR_SERVICO_INICIO — id=$idServico',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    _tratarRespostaSemConteudo(response);

    debugPrint(
      '[ServicoService] DESATIVAR_SERVICO_SUCESSO — id=$idServico',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGENS DO SERVIÇO
  // ─────────────────────────────────────────────────────────────

  Future<List<ServicoImagemModel>> listarImagensDoServico(
    int idServico,
  ) async {
    final uri = Uri.parse('$_servicosUrl/$idServico/imagens');

    debugPrint(
      '[ServicoService] LISTAR_IMAGENS_SERVICO_INICIO — idServico=$idServico',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaLista(response);

    final imagens = data
        .whereType<Map<String, dynamic>>()
        .map(ServicoImagemModel.fromJson)
        .toList();

    debugPrint(
      '[ServicoService] LISTAR_IMAGENS_SERVICO_SUCESSO — '
      'idServico=$idServico total=${imagens.length}',
    );

    return imagens;
  }

  Future<ServicoModel> adicionarImagemAoServico(
    int idServico,
    ServicoImagemModel imagem,
  ) async {
    final uri = Uri.parse('$_servicosUrl/$idServico/imagens');

    debugPrint(
      '[ServicoService] ADICIONAR_IMAGEM_SERVICO_INICIO — '
      'idServico=$idServico',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(imagem.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servico = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] ADICIONAR_IMAGEM_SERVICO_SUCESSO — '
      'idServico=$idServico totalImagens=${servico.imagens.length}',
    );

    return servico;
  }

  Future<ServicoModel> definirImagemPrincipal(
    int idServico,
    int idServicoImagem,
  ) async {
    final uri = Uri.parse(
      '$_servicosUrl/$idServico/imagens/$idServicoImagem/principal',
    );

    debugPrint(
      '[ServicoService] DEFINIR_IMAGEM_PRINCIPAL_INICIO — '
      'idServico=$idServico idImagem=$idServicoImagem',
    );

    final response = await http
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servico = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
      'idServico=$idServico imagemPrincipal=${servico.imagemPrincipalUrl}',
    );

    return servico;
  }

  Future<ServicoModel> removerImagemDoServico(
    int idServico,
    int idServicoImagem,
  ) async {
    final uri = Uri.parse(
      '$_servicosUrl/$idServico/imagens/$idServicoImagem',
    );

    debugPrint(
      '[ServicoService] REMOVER_IMAGEM_SERVICO_INICIO — '
      'idServico=$idServico idImagem=$idServicoImagem',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final servico = ServicoModel.fromJson(data);

    debugPrint(
      '[ServicoService] REMOVER_IMAGEM_SERVICO_SUCESSO — '
      'idServico=$idServico totalImagens=${servico.imagens.length}',
    );

    return servico;
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS — RESPOSTAS HTTP
  // ─────────────────────────────────────────────────────────────

  List<dynamic> _tratarRespostaLista(
    http.Response response,
  ) {
    _validarStatus(response);

    if (response.body.trim().isEmpty) {
      return [];
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is List) {
      return decoded;
    }

    throw Exception(
      '[ServicoService] Resposta inesperada: era esperada uma lista.',
    );
  }

  Map<String, dynamic> _tratarRespostaObjeto(
    http.Response response,
  ) {
    _validarStatus(response);

    if (response.body.trim().isEmpty) {
      return {};
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception(
      '[ServicoService] Resposta inesperada: era esperado um objecto.',
    );
  }

  void _tratarRespostaSemConteudo(
    http.Response response,
  ) {
    _validarStatus(response);
  }

  void _validarStatus(
    http.Response response,
  ) {
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      return;
    }

    final mensagem = _extrairMensagemErro(response);

    debugPrint(
      '[ServicoService] ERRO_HTTP — status=$status mensagem=$mensagem',
    );

    throw Exception(mensagem);
  }

  String _extrairMensagemErro(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return 'Erro HTTP ${response.statusCode} ao comunicar com o servidor.';
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        final mensagem = decoded['message'] ??
            decoded['mensagem'] ??
            decoded['error'] ??
            decoded['erro'] ??
            decoded['detail'];

        if (mensagem != null && mensagem.toString().trim().isNotEmpty) {
          return mensagem.toString();
        }

        final errors = decoded['errors'];

        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }

        if (errors is Map && errors.isNotEmpty) {
          return errors.values.first.toString();
        }
      }

      return decoded.toString();
    } catch (_) {
      return response.body;
    }
  }
}