import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/ingrediente_model.dart';

class IngredienteService {
  static const String _basePath = '/api/catalogo/ingredientes';

  String get _ingredientesUrl {
    return '${ApiConfig.baseUrl}$_basePath';
  }

  String get _categoriasUrl {
    return '$_ingredientesUrl/categorias';
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────────────────────────

  Future<List<CategoriaIngredienteModel>> listarCategorias({
    bool somenteAtivas = false,
  }) async {
    final uri = Uri.parse(_categoriasUrl).replace(
      queryParameters: {
        if (somenteAtivas) 'somenteAtivas': 'true',
      },
    );

    debugPrint(
      '[IngredienteService] LISTAR_CATEGORIAS_INICIO — somenteAtivas=$somenteAtivas',
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
        .map(CategoriaIngredienteModel.fromJson)
        .toList();

    debugPrint(
      '[IngredienteService] LISTAR_CATEGORIAS_SUCESSO — total=${categorias.length}',
    );

    return categorias;
  }

  Future<CategoriaIngredienteModel> buscarCategoriaPorId(
    int idCategoriaIngrediente,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaIngrediente');

    debugPrint(
      '[IngredienteService] BUSCAR_CATEGORIA_INICIO — id=$idCategoriaIngrediente',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoria = CategoriaIngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
    );

    return categoria;
  }

  Future<CategoriaIngredienteModel> criarCategoria(
    CategoriaIngredienteModel categoria,
  ) async {
    final uri = Uri.parse(_categoriasUrl);

    debugPrint(
      '[IngredienteService] CRIAR_CATEGORIA_INICIO — nome=${categoria.nome}',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(categoria.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoriaCriada = CategoriaIngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] CRIAR_CATEGORIA_SUCESSO — id=${categoriaCriada.idCategoriaIngrediente}',
    );

    return categoriaCriada;
  }

  Future<CategoriaIngredienteModel> editarCategoria(
    int idCategoriaIngrediente,
    CategoriaIngredienteModel categoria,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaIngrediente');

    debugPrint(
      '[IngredienteService] EDITAR_CATEGORIA_INICIO — id=$idCategoriaIngrediente',
    );

    final response = await http
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(categoria.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoriaEditada = CategoriaIngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
    );

    return categoriaEditada;
  }

  Future<CategoriaIngredienteModel> alterarEstadoCategoria(
    int idCategoriaIngrediente,
    bool ativo,
  ) async {
    final uri = Uri.parse(
      '$_categoriasUrl/$idCategoriaIngrediente/estado',
    );

    debugPrint(
      '[IngredienteService] ALTERAR_ESTADO_CATEGORIA_INICIO — id=$idCategoriaIngrediente ativo=$ativo',
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

    final categoria = CategoriaIngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] ALTERAR_ESTADO_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente ativo=${categoria.ativo}',
    );

    return categoria;
  }

  Future<void> desativarCategoria(
    int idCategoriaIngrediente,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaIngrediente');

    debugPrint(
      '[IngredienteService] DESATIVAR_CATEGORIA_INICIO — id=$idCategoriaIngrediente',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    _tratarRespostaSemConteudo(response);

    debugPrint(
      '[IngredienteService] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INGREDIENTES
  // ─────────────────────────────────────────────────────────────

  Future<List<IngredienteModel>> listarIngredientes({
    bool somenteAtivos = false,
    bool somenteDisponiveis = false,
    int? idCategoriaIngrediente,
  }) async {
    final uri = Uri.parse(_ingredientesUrl).replace(
      queryParameters: {
        if (somenteAtivos) 'somenteAtivos': 'true',
        if (somenteDisponiveis) 'somenteDisponiveis': 'true',
        if (idCategoriaIngrediente != null)
          'idCategoriaIngrediente': idCategoriaIngrediente.toString(),
      },
    );

    debugPrint(
      '[IngredienteService] LISTAR_INGREDIENTES_INICIO — '
      'somenteAtivos=$somenteAtivos, '
      'somenteDisponiveis=$somenteDisponiveis, '
      'idCategoriaIngrediente=$idCategoriaIngrediente',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaLista(response);

    final ingredientes = data
        .whereType<Map<String, dynamic>>()
        .map(IngredienteModel.fromJson)
        .toList();

    debugPrint(
      '[IngredienteService] LISTAR_INGREDIENTES_SUCESSO — total=${ingredientes.length}',
    );

    return ingredientes;
  }

  Future<IngredienteModel> buscarIngredientePorId(
    int idIngrediente,
  ) async {
    final uri = Uri.parse('$_ingredientesUrl/$idIngrediente');

    debugPrint(
      '[IngredienteService] BUSCAR_INGREDIENTE_INICIO — id=$idIngrediente',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final ingrediente = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] BUSCAR_INGREDIENTE_SUCESSO — id=$idIngrediente',
    );

    return ingrediente;
  }

  Future<IngredienteModel> criarIngrediente(
    IngredienteModel ingrediente,
  ) async {
    final uri = Uri.parse(_ingredientesUrl);

    debugPrint(
      '[IngredienteService] CRIAR_INGREDIENTE_INICIO — nome=${ingrediente.nome}',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
            ingrediente.toJson(
  enviarCategorias: true,
  enviarImagens: true,
),
          ),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final ingredienteCriado = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] CRIAR_INGREDIENTE_SUCESSO — id=${ingredienteCriado.idIngrediente}',
    );

    return ingredienteCriado;
  }

Future<IngredienteModel> editarIngrediente(
  int idIngrediente,
  IngredienteModel ingrediente, {
  bool enviarCategorias = true,
  bool enviarImagens = true,
}) async {
    final uri = Uri.parse('$_ingredientesUrl/$idIngrediente');

    debugPrint(
      '[IngredienteService] EDITAR_INGREDIENTE_INICIO — '
'id=$idIngrediente enviarCategorias=$enviarCategorias enviarImagens=$enviarImagens',
    );

    final response = await http
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
            ingrediente.toJson(
  enviarCategorias: enviarCategorias,
  enviarImagens: enviarImagens,
),
          ),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final ingredienteEditado = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] EDITAR_INGREDIENTE_SUCESSO — id=$idIngrediente',
    );

    return ingredienteEditado;
  }

  Future<IngredienteModel> alterarDisponibilidadeIngrediente(
    int idIngrediente,
    bool disponivel,
  ) async {
    final uri = Uri.parse(
      '$_ingredientesUrl/$idIngrediente/disponibilidade',
    );

    debugPrint(
      '[IngredienteService] ALTERAR_DISPONIBILIDADE_INGREDIENTE_INICIO — '
      'id=$idIngrediente disponivel=$disponivel',
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

    final ingrediente = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] ALTERAR_DISPONIBILIDADE_INGREDIENTE_SUCESSO — '
      'id=$idIngrediente disponivel=${ingrediente.disponivel}',
    );

    return ingrediente;
  }

  Future<IngredienteModel> alterarEstadoIngrediente(
    int idIngrediente,
    bool ativo,
  ) async {
    final uri = Uri.parse(
      '$_ingredientesUrl/$idIngrediente/estado',
    );

    debugPrint(
      '[IngredienteService] ALTERAR_ESTADO_INGREDIENTE_INICIO — '
      'id=$idIngrediente ativo=$ativo',
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

    final ingrediente = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] ALTERAR_ESTADO_INGREDIENTE_SUCESSO — '
      'id=$idIngrediente ativo=${ingrediente.ativo} disponivel=${ingrediente.disponivel}',
    );

    return ingrediente;
  }

  Future<void> desativarIngrediente(
    int idIngrediente,
  ) async {
    final uri = Uri.parse('$_ingredientesUrl/$idIngrediente');

    debugPrint(
      '[IngredienteService] DESATIVAR_INGREDIENTE_INICIO — id=$idIngrediente',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    _tratarRespostaSemConteudo(response);

    debugPrint(
      '[IngredienteService] DESATIVAR_INGREDIENTE_SUCESSO — id=$idIngrediente',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGENS
  // ─────────────────────────────────────────────────────────────

  Future<List<IngredienteImagemModel>> listarImagensDoIngrediente(
    int idIngrediente,
  ) async {
    final uri = Uri.parse('$_ingredientesUrl/$idIngrediente/imagens');

    debugPrint(
      '[IngredienteService] LISTAR_IMAGENS_INGREDIENTE_INICIO — idIngrediente=$idIngrediente',
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
        .map(IngredienteImagemModel.fromJson)
        .toList();

    debugPrint(
      '[IngredienteService] LISTAR_IMAGENS_INGREDIENTE_SUCESSO — '
      'idIngrediente=$idIngrediente total=${imagens.length}',
    );

    return imagens;
  }

  Future<IngredienteModel> adicionarImagemAoIngrediente(
    int idIngrediente,
    IngredienteImagemModel imagem,
  ) async {
    final uri = Uri.parse('$_ingredientesUrl/$idIngrediente/imagens');

    debugPrint(
      '[IngredienteService] ADICIONAR_IMAGEM_INGREDIENTE_INICIO — '
      'idIngrediente=$idIngrediente',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(imagem.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final ingrediente = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] ADICIONAR_IMAGEM_INGREDIENTE_SUCESSO — '
      'idIngrediente=$idIngrediente totalImagens=${ingrediente.imagens.length}',
    );

    return ingrediente;
  }

  Future<IngredienteModel> definirImagemPrincipal(
    int idIngrediente,
    int idIngredienteImagem,
  ) async {
    final uri = Uri.parse(
      '$_ingredientesUrl/$idIngrediente/imagens/$idIngredienteImagem/principal',
    );

    debugPrint(
      '[IngredienteService] DEFINIR_IMAGEM_PRINCIPAL_INICIO — '
      'idIngrediente=$idIngrediente idImagem=$idIngredienteImagem',
    );

    final response = await http
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final ingrediente = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
      'idIngrediente=$idIngrediente imagemPrincipal=${ingrediente.imagemPrincipalUrl}',
    );

    return ingrediente;
  }

  Future<IngredienteModel> removerImagemDoIngrediente(
    int idIngrediente,
    int idIngredienteImagem,
  ) async {
    final uri = Uri.parse(
      '$_ingredientesUrl/$idIngrediente/imagens/$idIngredienteImagem',
    );

    debugPrint(
      '[IngredienteService] REMOVER_IMAGEM_INGREDIENTE_INICIO — '
      'idIngrediente=$idIngrediente idImagem=$idIngredienteImagem',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final ingrediente = IngredienteModel.fromJson(data);

    debugPrint(
      '[IngredienteService] REMOVER_IMAGEM_INGREDIENTE_SUCESSO — '
      'idIngrediente=$idIngrediente totalImagens=${ingrediente.imagens.length}',
    );

    return ingrediente;
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
      '[IngredienteService] Resposta inesperada: era esperada uma lista.',
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
      '[IngredienteService] Resposta inesperada: era esperado um objecto.',
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
      '[IngredienteService] ERRO_HTTP — status=$status mensagem=$mensagem',
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