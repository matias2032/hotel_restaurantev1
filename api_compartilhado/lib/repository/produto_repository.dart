import 'package:flutter/foundation.dart';

import '../models/produto_model.dart';
import '../services/produto_service.dart';

class ProdutoRepository {
  final ProdutoService service;

  ProdutoRepository({
    required this.service,
  });

  // ─────────────────────────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────────────────────────

  Future<List<CategoriaProdutoModel>> listarCategorias({
    bool somenteAtivas = false,
  }) async {
    debugPrint(
      '[ProdutoRepository] LISTAR_CATEGORIAS_INICIO — somenteAtivas=$somenteAtivas',
    );

    final categorias = await service.listarCategorias(
      somenteAtivas: somenteAtivas,
    );

    debugPrint(
      '[ProdutoRepository] LISTAR_CATEGORIAS_SUCESSO — total=${categorias.length}',
    );

    return categorias;
  }

  Future<CategoriaProdutoModel> buscarCategoriaPorId(
    int idCategoriaProduto,
  ) async {
    _validarId(
      idCategoriaProduto,
      'ID da categoria de produto inválido.',
    );

    debugPrint(
      '[ProdutoRepository] BUSCAR_CATEGORIA_INICIO — id=$idCategoriaProduto',
    );

    final categoria = await service.buscarCategoriaPorId(
      idCategoriaProduto,
    );

    debugPrint(
      '[ProdutoRepository] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
    );

    return categoria;
  }

  Future<CategoriaProdutoModel> criarCategoria(
    CategoriaProdutoModel categoria,
  ) async {
    final categoriaNormalizada = _normalizarCategoria(
      categoria,
    );

    debugPrint(
      '[ProdutoRepository] CRIAR_CATEGORIA_INICIO — nome=${categoriaNormalizada.nome}',
    );

    final categoriaCriada = await service.criarCategoria(
      categoriaNormalizada,
    );

    debugPrint(
      '[ProdutoRepository] CRIAR_CATEGORIA_SUCESSO — id=${categoriaCriada.idCategoriaProduto}',
    );

    return categoriaCriada;
  }

  Future<CategoriaProdutoModel> editarCategoria(
    int idCategoriaProduto,
    CategoriaProdutoModel categoria,
  ) async {
    _validarId(
      idCategoriaProduto,
      'ID da categoria de produto inválido para edição.',
    );

    final categoriaNormalizada = _normalizarCategoria(
      categoria,
    );

    debugPrint(
      '[ProdutoRepository] EDITAR_CATEGORIA_INICIO — id=$idCategoriaProduto',
    );

    final categoriaEditada = await service.editarCategoria(
      idCategoriaProduto,
      categoriaNormalizada,
    );

    debugPrint(
      '[ProdutoRepository] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
    );

    return categoriaEditada;
  }

  Future<CategoriaProdutoModel> alterarEstadoCategoria(
    int idCategoriaProduto,
    bool ativo,
  ) async {
    _validarId(
      idCategoriaProduto,
      'ID da categoria de produto inválido para alteração de estado.',
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_ESTADO_CATEGORIA_INICIO — '
      'id=$idCategoriaProduto ativo=$ativo',
    );

    final categoria = await service.alterarEstadoCategoria(
      idCategoriaProduto,
      ativo,
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
      'id=$idCategoriaProduto ativo=${categoria.ativo}',
    );

    return categoria;
  }

  Future<void> desativarCategoria(
    int idCategoriaProduto,
  ) async {
    _validarId(
      idCategoriaProduto,
      'ID da categoria de produto inválido para desativação.',
    );

    debugPrint(
      '[ProdutoRepository] DESATIVAR_CATEGORIA_INICIO — id=$idCategoriaProduto',
    );

    await service.desativarCategoria(
      idCategoriaProduto,
    );

    debugPrint(
      '[ProdutoRepository] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
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
    if (idCategoriaProduto != null) {
      _validarId(
        idCategoriaProduto,
        'ID da categoria de produto inválido para filtro.',
      );
    }

    debugPrint(
      '[ProdutoRepository] LISTAR_PRODUTOS_INICIO — '
      'somenteAtivos=$somenteAtivos, '
      'somenteDisponiveis=$somenteDisponiveis, '
      'somenteDestaques=$somenteDestaques, '
      'idCategoriaProduto=$idCategoriaProduto',
    );

    final produtos = await service.listarProdutos(
      somenteAtivos: somenteAtivos,
      somenteDisponiveis: somenteDisponiveis,
      somenteDestaques: somenteDestaques,
      idCategoriaProduto: idCategoriaProduto,
    );

    debugPrint(
      '[ProdutoRepository] LISTAR_PRODUTOS_SUCESSO — total=${produtos.length}',
    );

    return produtos;
  }

  Future<ProdutoModel> buscarProdutoPorId(
    int idProduto,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido.',
    );

    debugPrint(
      '[ProdutoRepository] BUSCAR_PRODUTO_INICIO — id=$idProduto',
    );

    final produto = await service.buscarProdutoPorId(
      idProduto,
    );

    debugPrint(
      '[ProdutoRepository] BUSCAR_PRODUTO_SUCESSO — id=$idProduto',
    );

    return produto;
  }

  Future<ProdutoModel> criarProduto(
    ProdutoModel produto,
  ) async {
    final produtoNormalizado = _normalizarProduto(
      produto,
      validarImagens: true,
      validarIngredientes: true,
    );

    debugPrint(
      '[ProdutoRepository] CRIAR_PRODUTO_INICIO — nome=${produtoNormalizado.nome}',
    );

    final produtoCriado = await service.criarProduto(
      produtoNormalizado,
    );

    debugPrint(
      '[ProdutoRepository] CRIAR_PRODUTO_SUCESSO — id=${produtoCriado.idProduto}',
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
    _validarId(
      idProduto,
      'ID do produto inválido para edição.',
    );

    final produtoNormalizado = _normalizarProduto(
      produto,
      validarImagens: enviarImagens,
      validarIngredientes: enviarIngredientes,
    );

    debugPrint(
      '[ProdutoRepository] EDITAR_PRODUTO_INICIO — '
 'id=$idProduto enviarCategorias=$enviarCategorias '
'enviarImagens=$enviarImagens '
'enviarIngredientes=$enviarIngredientes',
    );

    final produtoEditado = await service.editarProduto(
  idProduto,
  produtoNormalizado,
  enviarCategorias: enviarCategorias,
  enviarImagens: enviarImagens,
  enviarIngredientes: enviarIngredientes,
);

    debugPrint(
      '[ProdutoRepository] EDITAR_PRODUTO_SUCESSO — id=$idProduto',
    );

    return produtoEditado;
  }

  Future<ProdutoModel> alterarDisponibilidadeProduto(
    int idProduto,
    bool disponivel,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para alteração de disponibilidade.',
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_DISPONIBILIDADE_PRODUTO_INICIO — '
      'id=$idProduto disponivel=$disponivel',
    );

    final produto = await service.alterarDisponibilidadeProduto(
      idProduto,
      disponivel,
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_DISPONIBILIDADE_PRODUTO_SUCESSO — '
      'id=$idProduto disponivel=${produto.disponivel}',
    );

    return produto;
  }

  Future<ProdutoModel> alterarDestaqueProduto(
    int idProduto,
    bool destaque,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para alteração de destaque.',
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_DESTAQUE_PRODUTO_INICIO — '
      'id=$idProduto destaque=$destaque',
    );

    final produto = await service.alterarDestaqueProduto(
      idProduto,
      destaque,
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_DESTAQUE_PRODUTO_SUCESSO — '
      'id=$idProduto destaque=${produto.destaque}',
    );

    return produto;
  }

  Future<ProdutoModel> alterarEstadoProduto(
    int idProduto,
    bool ativo,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para alteração de estado.',
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_ESTADO_PRODUTO_INICIO — '
      'id=$idProduto ativo=$ativo',
    );

    final produto = await service.alterarEstadoProduto(
      idProduto,
      ativo,
    );

    debugPrint(
      '[ProdutoRepository] ALTERAR_ESTADO_PRODUTO_SUCESSO — '
      'id=$idProduto ativo=${produto.ativo} '
      'disponivel=${produto.disponivel} destaque=${produto.destaque}',
    );

    return produto;
  }

  Future<void> desativarProduto(
    int idProduto,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para desativação.',
    );

    debugPrint(
      '[ProdutoRepository] DESATIVAR_PRODUTO_INICIO — id=$idProduto',
    );

    await service.desativarProduto(
      idProduto,
    );

    debugPrint(
      '[ProdutoRepository] DESATIVAR_PRODUTO_SUCESSO — id=$idProduto',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGENS DO PRODUTO
  // ─────────────────────────────────────────────────────────────

  Future<List<ProdutoImagemModel>> listarImagensDoProduto(
    int idProduto,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para listar imagens.',
    );

    debugPrint(
      '[ProdutoRepository] LISTAR_IMAGENS_PRODUTO_INICIO — idProduto=$idProduto',
    );

    final imagens = await service.listarImagensDoProduto(
      idProduto,
    );

    debugPrint(
      '[ProdutoRepository] LISTAR_IMAGENS_PRODUTO_SUCESSO — '
      'idProduto=$idProduto total=${imagens.length}',
    );

    return imagens;
  }

  Future<ProdutoModel> adicionarImagemAoProduto(
    int idProduto,
    ProdutoImagemModel imagem,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para adicionar imagem.',
    );

    final imagemNormalizada = _normalizarImagem(
      imagem,
    );

    debugPrint(
      '[ProdutoRepository] ADICIONAR_IMAGEM_PRODUTO_INICIO — '
      'idProduto=$idProduto',
    );

    final produto = await service.adicionarImagemAoProduto(
      idProduto,
      imagemNormalizada,
    );

    debugPrint(
      '[ProdutoRepository] ADICIONAR_IMAGEM_PRODUTO_SUCESSO — '
      'idProduto=$idProduto totalImagens=${produto.imagens.length}',
    );

    return produto;
  }

  Future<ProdutoModel> definirImagemPrincipal(
    int idProduto,
    int idProdutoImagem,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para definir imagem principal.',
    );

    _validarId(
      idProdutoImagem,
      'ID da imagem do produto inválido para definir principal.',
    );

    debugPrint(
      '[ProdutoRepository] DEFINIR_IMAGEM_PRINCIPAL_INICIO — '
      'idProduto=$idProduto idImagem=$idProdutoImagem',
    );

    final produto = await service.definirImagemPrincipal(
      idProduto,
      idProdutoImagem,
    );

    debugPrint(
      '[ProdutoRepository] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
      'idProduto=$idProduto imagemPrincipal=${produto.imagemPrincipalUrl}',
    );

    return produto;
  }

  Future<ProdutoModel> removerImagemDoProduto(
    int idProduto,
    int idProdutoImagem,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para remover imagem.',
    );

    _validarId(
      idProdutoImagem,
      'ID da imagem do produto inválido para remoção.',
    );

    debugPrint(
      '[ProdutoRepository] REMOVER_IMAGEM_PRODUTO_INICIO — '
      'idProduto=$idProduto idImagem=$idProdutoImagem',
    );

    final produto = await service.removerImagemDoProduto(
      idProduto,
      idProdutoImagem,
    );

    debugPrint(
      '[ProdutoRepository] REMOVER_IMAGEM_PRODUTO_SUCESSO — '
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
    _validarId(
      idProduto,
      'ID do produto inválido para listar ingredientes.',
    );

    debugPrint(
      '[ProdutoRepository] LISTAR_INGREDIENTES_PRODUTO_INICIO — idProduto=$idProduto',
    );

    final ingredientes = await service.listarIngredientesDoProduto(
      idProduto,
    );

    debugPrint(
      '[ProdutoRepository] LISTAR_INGREDIENTES_PRODUTO_SUCESSO — '
      'idProduto=$idProduto total=${ingredientes.length}',
    );

    return ingredientes;
  }

  Future<ProdutoModel> adicionarIngredienteAoProduto(
    int idProduto,
    ProdutoIngredienteModel ingrediente,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para adicionar ingrediente.',
    );

    final ingredienteNormalizado = _normalizarProdutoIngrediente(
      ingrediente,
    );

    debugPrint(
      '[ProdutoRepository] ADICIONAR_INGREDIENTE_PRODUTO_INICIO — '
      'idProduto=$idProduto idIngrediente=${ingredienteNormalizado.idIngrediente}',
    );

    final produto = await service.adicionarIngredienteAoProduto(
      idProduto,
      ingredienteNormalizado,
    );

    debugPrint(
      '[ProdutoRepository] ADICIONAR_INGREDIENTE_PRODUTO_SUCESSO — '
      'idProduto=$idProduto totalIngredientes=${produto.ingredientes.length}',
    );

    return produto;
  }

  Future<ProdutoModel> removerIngredienteDoProduto(
    int idProduto,
    int idIngrediente,
  ) async {
    _validarId(
      idProduto,
      'ID do produto inválido para remover ingrediente.',
    );

    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para remoção do produto.',
    );

    debugPrint(
      '[ProdutoRepository] REMOVER_INGREDIENTE_PRODUTO_INICIO — '
      'idProduto=$idProduto idIngrediente=$idIngrediente',
    );

    final produto = await service.removerIngredienteDoProduto(
      idProduto,
      idIngrediente,
    );

    debugPrint(
      '[ProdutoRepository] REMOVER_INGREDIENTE_PRODUTO_SUCESSO — '
      'idProduto=$idProduto totalIngredientes=${produto.ingredientes.length}',
    );

    return produto;
  }

  // ─────────────────────────────────────────────────────────────
  // NORMALIZAÇÕES
  // ─────────────────────────────────────────────────────────────

  CategoriaProdutoModel _normalizarCategoria(
    CategoriaProdutoModel categoria,
  ) {
    final nome = categoria.nome.trim();

    if (nome.isEmpty) {
      throw Exception('O nome da categoria é obrigatório.');
    }

    if (categoria.ordem < 0) {
      throw Exception('A ordem da categoria não pode ser negativa.');
    }

    return categoria.copyWith(
      nome: nome,
      descricao: _normalizarTextoOpcional(categoria.descricao),
      ordem: categoria.ordem,
    );
  }

  ProdutoModel _normalizarProduto(
    ProdutoModel produto, {
    required bool validarImagens,
    required bool validarIngredientes,
  }) {
    final nome = produto.nome.trim();

    if (nome.isEmpty) {
      throw Exception('O nome do produto é obrigatório.');
    }

    if (produto.preco < 0) {
      throw Exception('O preço do produto não pode ser negativo.');
    }

    if (produto.quantidadeEstoque != null &&
        produto.quantidadeEstoque! < 0) {
      throw Exception('A quantidade em estoque não pode ser negativa.');
    }

    if (produto.tempoPreparoMinutos != null &&
        produto.tempoPreparoMinutos! < 0) {
      throw Exception('O tempo de preparo não pode ser negativo.');
    }

for (final categoria in produto.categoriasProduto) {
  final idCategoria = categoria.idCategoriaProduto;

  if (idCategoria == null) {
    throw Exception('Categoria de produto inválida.');
  }

  _validarId(
    idCategoria,
    'ID da categoria de produto inválido.',
  );
}

final idsCategorias = produto.categoriasProduto
    .map((categoria) => categoria.idCategoriaProduto)
    .whereType<int>()
    .toList();

final idsUnicos = idsCategorias.toSet();

if (idsCategorias.length != idsUnicos.length) {
  throw Exception('Não é permitido associar a mesma categoria mais de uma vez.');
}

    final imagensNormalizadas = validarImagens
        ? produto.imagens.map(_normalizarImagem).toList()
        : produto.imagens;

    final ingredientesNormalizados = validarIngredientes
        ? _normalizarIngredientesProduto(produto.ingredientes)
        : produto.ingredientes;

return produto.copyWith(
  nome: nome,
  descricao: _normalizarTextoOpcional(produto.descricao),
  preco: produto.preco,
  imagemPrincipalUrl: _normalizarTextoOpcional(
    produto.imagemPrincipalUrl,
  ),
  controlaEstoque: produto.controlaEstoque,
  quantidadeEstoque: produto.controlaEstoque
      ? produto.quantidadeEstoque
      : null,
  categoriasProduto: produto.categoriasProduto,
  imagens: imagensNormalizadas,
  ingredientes: ingredientesNormalizados,
);
  }

  ProdutoImagemModel _normalizarImagem(
    ProdutoImagemModel imagem,
  ) {
    final imagemUrl = imagem.imagemUrl.trim();

    if (imagemUrl.isEmpty) {
      throw Exception(
        'A URL da imagem é obrigatória quando uma imagem é enviada.',
      );
    }

    if (imagem.ordem < 0) {
      throw Exception('A ordem da imagem não pode ser negativa.');
    }

    return imagem.copyWith(
      imagemUrl: imagemUrl,
      legenda: _normalizarTextoOpcional(imagem.legenda),
      ordem: imagem.ordem,
    );
  }

  List<ProdutoIngredienteModel> _normalizarIngredientesProduto(
    List<ProdutoIngredienteModel> ingredientes,
  ) {
    final ids = <int>{};

    return ingredientes.map((ingrediente) {
      final normalizado = _normalizarProdutoIngrediente(
        ingrediente,
      );

      final idIngrediente = normalizado.idIngrediente!;

      if (!ids.add(idIngrediente)) {
        throw Exception(
          'Não é permitido repetir o mesmo ingrediente no produto.',
        );
      }

      return normalizado;
    }).toList();
  }

  ProdutoIngredienteModel _normalizarProdutoIngrediente(
    ProdutoIngredienteModel ingrediente,
  ) {
    final idIngrediente = ingrediente.idIngrediente;

    if (idIngrediente == null || idIngrediente <= 0) {
      throw Exception(
        'ID do ingrediente é obrigatório quando um ingrediente é enviado.',
      );
    }

    if (ingrediente.quantidadePadrao <= 0) {
      throw Exception(
        'A quantidade padrão do ingrediente deve ser maior que zero.',
      );
    }

    return ingrediente.copyWith(
      idIngrediente: idIngrediente,
      nomeIngrediente: ingrediente.nomeIngrediente.trim(),
      quantidadePadrao: ingrediente.quantidadePadrao,
      obrigatorio: ingrediente.obrigatorio,
      removivel: ingrediente.removivel,
      permiteExtra: ingrediente.permiteExtra,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  void _validarId(
    int id,
    String mensagem,
  ) {
    if (id <= 0) {
      throw Exception(mensagem);
    }
  }

  String? _normalizarTextoOpcional(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final text = value.trim();

    return text.isEmpty ? null : text;
  }
}