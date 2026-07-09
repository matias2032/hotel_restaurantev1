import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/produto_model.dart';

class ProdutoService {
  static const String _basePath = '/api/catalogo/produtos';

  String get _produtosUrl {
    return '${ApiConfig.baseUrl}$_basePath';
  }

  String get _categoriasUrl {
    return '$_produtosUrl/categorias';
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────────────────────────

  Future<List<CategoriaProdutoModel>> listarCategorias({
    bool somenteAtivas = false,
  }) async {
    final uri = Uri.parse(_categoriasUrl).replace(
      queryParameters: {
        if (somenteAtivas) 'somenteAtivas': 'true',
      },
    );

    debugPrint(
      '[ProdutoService] LISTAR_CATEGORIAS_INICIO — somenteAtivas=$somenteAtivas',
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
        .map(CategoriaProdutoModel.fromJson)
        .toList();

    debugPrint(
      '[ProdutoService] LISTAR_CATEGORIAS_SUCESSO — total=${categorias.length}',
    );

    return categorias;
  }

  Future<CategoriaProdutoModel> buscarCategoriaPorId(
    int idCategoriaProduto,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaProduto');

    debugPrint(
      '[ProdutoService] BUSCAR_CATEGORIA_INICIO — id=$idCategoriaProduto',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoria = CategoriaProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
    );

    return categoria;
  }

  Future<CategoriaProdutoModel> criarCategoria(
    CategoriaProdutoModel categoria,
  ) async {
    final uri = Uri.parse(_categoriasUrl);

    debugPrint(
      '[ProdutoService] CRIAR_CATEGORIA_INICIO — nome=${categoria.nome}',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(categoria.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoriaCriada = CategoriaProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] CRIAR_CATEGORIA_SUCESSO — id=${categoriaCriada.idCategoriaProduto}',
    );

    return categoriaCriada;
  }

  Future<CategoriaProdutoModel> editarCategoria(
    int idCategoriaProduto,
    CategoriaProdutoModel categoria,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaProduto');

    debugPrint(
      '[ProdutoService] EDITAR_CATEGORIA_INICIO — id=$idCategoriaProduto',
    );

    final response = await http
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(categoria.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final categoriaEditada = CategoriaProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
    );

    return categoriaEditada;
  }

  Future<CategoriaProdutoModel> alterarEstadoCategoria(
    int idCategoriaProduto,
    bool ativo,
  ) async {
    final uri = Uri.parse(
      '$_categoriasUrl/$idCategoriaProduto/estado',
    );

    debugPrint(
      '[ProdutoService] ALTERAR_ESTADO_CATEGORIA_INICIO — '
      'id=$idCategoriaProduto ativo=$ativo',
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

    final categoria = CategoriaProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
      'id=$idCategoriaProduto ativo=${categoria.ativo}',
    );

    return categoria;
  }

  Future<void> desativarCategoria(
    int idCategoriaProduto,
  ) async {
    final uri = Uri.parse('$_categoriasUrl/$idCategoriaProduto');

    debugPrint(
      '[ProdutoService] DESATIVAR_CATEGORIA_INICIO — id=$idCategoriaProduto',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    _tratarRespostaSemConteudo(response);

    debugPrint(
      '[ProdutoService] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PRODUTOS
  // ─────────────────────────────────────────────────────────────

  Future<List<ProdutoModel>> listarProdutos({
    bool somenteAtivos = false,
    bool somenteDisponiveis = false,
    bool somenteDestaques = false,
    int? idCategoriaProduto,
  }) async {
    final uri = Uri.parse(_produtosUrl).replace(
      queryParameters: {
        if (somenteAtivos) 'somenteAtivos': 'true',
        if (somenteDisponiveis) 'somenteDisponiveis': 'true',
        if (somenteDestaques) 'somenteDestaques': 'true',
        if (idCategoriaProduto != null)
          'idCategoriaProduto': idCategoriaProduto.toString(),
      },
    );

    debugPrint(
      '[ProdutoService] LISTAR_PRODUTOS_INICIO — '
      'somenteAtivos=$somenteAtivos, '
      'somenteDisponiveis=$somenteDisponiveis, '
      'somenteDestaques=$somenteDestaques, '
      'idCategoriaProduto=$idCategoriaProduto',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaLista(response);

    final produtos = data
        .whereType<Map<String, dynamic>>()
        .map(ProdutoModel.fromJson)
        .toList();

    debugPrint(
      '[ProdutoService] LISTAR_PRODUTOS_SUCESSO — total=${produtos.length}',
    );

    return produtos;
  }

  Future<ProdutoModel> buscarProdutoPorId(
    int idProduto,
  ) async {
    final uri = Uri.parse('$_produtosUrl/$idProduto');

    debugPrint(
      '[ProdutoService] BUSCAR_PRODUTO_INICIO — id=$idProduto',
    );

    final response = await http
        .get(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] BUSCAR_PRODUTO_SUCESSO — id=$idProduto',
    );

    return produto;
  }

  Future<ProdutoModel> criarProduto(
    ProdutoModel produto,
  ) async {
    final uri = Uri.parse(_produtosUrl);

    debugPrint(
      '[ProdutoService] CRIAR_PRODUTO_INICIO — nome=${produto.nome}',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
         produto.toJson(
  enviarCategorias: true,
  enviarImagens: true,
  enviarIngredientes: true,
),
          ),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produtoCriado = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] CRIAR_PRODUTO_SUCESSO — id=${produtoCriado.idProduto}',
    );

    return produtoCriado;
  }

Future<ProdutoModel> editarProduto(
  int idProduto,
  ProdutoModel produto, {
  bool enviarCategorias = true,
  bool enviarImagens = true,
  bool enviarIngredientes = true,
}) async {
    final uri = Uri.parse('$_produtosUrl/$idProduto');

    debugPrint(
      '[ProdutoService] EDITAR_PRODUTO_INICIO — '
'id=$idProduto enviarCategorias=$enviarCategorias '
'enviarImagens=$enviarImagens '
'enviarIngredientes=$enviarIngredientes',
    );

    final response = await http
        .put(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(
            produto.toJson(
  enviarCategorias: enviarCategorias,
  enviarImagens: enviarImagens,
  enviarIngredientes: enviarIngredientes,
),
          ),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produtoEditado = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] EDITAR_PRODUTO_SUCESSO — id=$idProduto',
    );

    return produtoEditado;
  }

  Future<ProdutoModel> alterarDisponibilidadeProduto(
    int idProduto,
    bool disponivel,
  ) async {
    final uri = Uri.parse(
      '$_produtosUrl/$idProduto/disponibilidade',
    );

    debugPrint(
      '[ProdutoService] ALTERAR_DISPONIBILIDADE_PRODUTO_INICIO — '
      'id=$idProduto disponivel=$disponivel',
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

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] ALTERAR_DISPONIBILIDADE_PRODUTO_SUCESSO — '
      'id=$idProduto disponivel=${produto.disponivel}',
    );

    return produto;
  }

  Future<ProdutoModel> alterarDestaqueProduto(
    int idProduto,
    bool destaque,
  ) async {
    final uri = Uri.parse(
      '$_produtosUrl/$idProduto/destaque',
    );

    debugPrint(
      '[ProdutoService] ALTERAR_DESTAQUE_PRODUTO_INICIO — '
      'id=$idProduto destaque=$destaque',
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

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] ALTERAR_DESTAQUE_PRODUTO_SUCESSO — '
      'id=$idProduto destaque=${produto.destaque}',
    );

    return produto;
  }

  Future<ProdutoModel> alterarEstadoProduto(
    int idProduto,
    bool ativo,
  ) async {
    final uri = Uri.parse(
      '$_produtosUrl/$idProduto/estado',
    );

    debugPrint(
      '[ProdutoService] ALTERAR_ESTADO_PRODUTO_INICIO — '
      'id=$idProduto ativo=$ativo',
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

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] ALTERAR_ESTADO_PRODUTO_SUCESSO — '
      'id=$idProduto ativo=${produto.ativo} '
      'disponivel=${produto.disponivel} destaque=${produto.destaque}',
    );

    return produto;
  }

  Future<void> desativarProduto(
    int idProduto,
  ) async {
    final uri = Uri.parse('$_produtosUrl/$idProduto');

    debugPrint(
      '[ProdutoService] DESATIVAR_PRODUTO_INICIO — id=$idProduto',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    _tratarRespostaSemConteudo(response);

    debugPrint(
      '[ProdutoService] DESATIVAR_PRODUTO_SUCESSO — id=$idProduto',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGENS DO PRODUTO
  // ─────────────────────────────────────────────────────────────

  Future<List<ProdutoImagemModel>> listarImagensDoProduto(
    int idProduto,
  ) async {
    final uri = Uri.parse('$_produtosUrl/$idProduto/imagens');

    debugPrint(
      '[ProdutoService] LISTAR_IMAGENS_PRODUTO_INICIO — idProduto=$idProduto',
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
        .map(ProdutoImagemModel.fromJson)
        .toList();

    debugPrint(
      '[ProdutoService] LISTAR_IMAGENS_PRODUTO_SUCESSO — '
      'idProduto=$idProduto total=${imagens.length}',
    );

    return imagens;
  }

  Future<ProdutoModel> adicionarImagemAoProduto(
    int idProduto,
    ProdutoImagemModel imagem,
  ) async {
    final uri = Uri.parse('$_produtosUrl/$idProduto/imagens');

    debugPrint(
      '[ProdutoService] ADICIONAR_IMAGEM_PRODUTO_INICIO — '
      'idProduto=$idProduto',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(imagem.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] ADICIONAR_IMAGEM_PRODUTO_SUCESSO — '
      'idProduto=$idProduto totalImagens=${produto.imagens.length}',
    );

    return produto;
  }

  Future<ProdutoModel> definirImagemPrincipal(
    int idProduto,
    int idProdutoImagem,
  ) async {
    final uri = Uri.parse(
      '$_produtosUrl/$idProduto/imagens/$idProdutoImagem/principal',
    );

    debugPrint(
      '[ProdutoService] DEFINIR_IMAGEM_PRINCIPAL_INICIO — '
      'idProduto=$idProduto idImagem=$idProdutoImagem',
    );

    final response = await http
        .patch(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
      'idProduto=$idProduto imagemPrincipal=${produto.imagemPrincipalUrl}',
    );

    return produto;
  }

  Future<ProdutoModel> removerImagemDoProduto(
    int idProduto,
    int idProdutoImagem,
  ) async {
    final uri = Uri.parse(
      '$_produtosUrl/$idProduto/imagens/$idProdutoImagem',
    );

    debugPrint(
      '[ProdutoService] REMOVER_IMAGEM_PRODUTO_INICIO — '
      'idProduto=$idProduto idImagem=$idProdutoImagem',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] REMOVER_IMAGEM_PRODUTO_SUCESSO — '
      'idProduto=$idProduto totalImagens=${produto.imagens.length}',
    );

    return produto;
  }

  // ─────────────────────────────────────────────────────────────
  // INGREDIENTES DO PRODUTO
  // ─────────────────────────────────────────────────────────────

  Future<List<ProdutoIngredienteModel>> listarIngredientesDoProduto(
    int idProduto,
  ) async {
    final uri = Uri.parse('$_produtosUrl/$idProduto/ingredientes');

    debugPrint(
      '[ProdutoService] LISTAR_INGREDIENTES_PRODUTO_INICIO — idProduto=$idProduto',
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
        .map(ProdutoIngredienteModel.fromJson)
        .toList();

    debugPrint(
      '[ProdutoService] LISTAR_INGREDIENTES_PRODUTO_SUCESSO — '
      'idProduto=$idProduto total=${ingredientes.length}',
    );

    return ingredientes;
  }

  Future<ProdutoModel> adicionarIngredienteAoProduto(
    int idProduto,
    ProdutoIngredienteModel ingrediente,
  ) async {
    final uri = Uri.parse('$_produtosUrl/$idProduto/ingredientes');

    debugPrint(
      '[ProdutoService] ADICIONAR_INGREDIENTE_PRODUTO_INICIO — '
      'idProduto=$idProduto idIngrediente=${ingrediente.idIngrediente}',
    );

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders,
          body: jsonEncode(ingrediente.toJson()),
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] ADICIONAR_INGREDIENTE_PRODUTO_SUCESSO — '
      'idProduto=$idProduto totalIngredientes=${produto.ingredientes.length}',
    );

    return produto;
  }

  Future<ProdutoModel> removerIngredienteDoProduto(
    int idProduto,
    int idIngrediente,
  ) async {
    final uri = Uri.parse(
      '$_produtosUrl/$idProduto/ingredientes/$idIngrediente',
    );

    debugPrint(
      '[ProdutoService] REMOVER_INGREDIENTE_PRODUTO_INICIO — '
      'idProduto=$idProduto idIngrediente=$idIngrediente',
    );

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders,
        )
        .timeout(ApiConfig.timeout);

    final data = _tratarRespostaObjeto(response);

    final produto = ProdutoModel.fromJson(data);

    debugPrint(
      '[ProdutoService] REMOVER_INGREDIENTE_PRODUTO_SUCESSO — '
      'idProduto=$idProduto totalIngredientes=${produto.ingredientes.length}',
    );

    return produto;
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
      '[ProdutoService] Resposta inesperada: era esperada uma lista.',
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
      '[ProdutoService] Resposta inesperada: era esperado um objecto.',
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
      '[ProdutoService] ERRO_HTTP — status=$status mensagem=$mensagem',
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