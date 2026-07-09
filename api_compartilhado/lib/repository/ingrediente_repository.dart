import 'package:flutter/foundation.dart';

import '../models/ingrediente_model.dart';
import '../services/ingrediente_service.dart';

class IngredienteRepository {
  final IngredienteService service;

  IngredienteRepository({
    required this.service,
  });

  // ─────────────────────────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────────────────────────

  Future<List<CategoriaIngredienteModel>> listarCategorias({
    bool somenteAtivas = false,
  }) async {
    debugPrint(
      '[IngredienteRepository] LISTAR_CATEGORIAS_INICIO — somenteAtivas=$somenteAtivas',
    );

    final categorias = await service.listarCategorias(
      somenteAtivas: somenteAtivas,
    );

    debugPrint(
      '[IngredienteRepository] LISTAR_CATEGORIAS_SUCESSO — total=${categorias.length}',
    );

    return categorias;
  }

  Future<CategoriaIngredienteModel> buscarCategoriaPorId(
    int idCategoriaIngrediente,
  ) async {
    _validarId(
      idCategoriaIngrediente,
      'ID da categoria de ingrediente inválido.',
    );

    debugPrint(
      '[IngredienteRepository] BUSCAR_CATEGORIA_INICIO — id=$idCategoriaIngrediente',
    );

    final categoria = await service.buscarCategoriaPorId(
      idCategoriaIngrediente,
    );

    debugPrint(
      '[IngredienteRepository] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
    );

    return categoria;
  }

  Future<CategoriaIngredienteModel> criarCategoria(
    CategoriaIngredienteModel categoria,
  ) async {
    final categoriaNormalizada = _normalizarCategoria(categoria);

    debugPrint(
      '[IngredienteRepository] CRIAR_CATEGORIA_INICIO — nome=${categoriaNormalizada.nome}',
    );

    final categoriaCriada = await service.criarCategoria(
      categoriaNormalizada,
    );

    debugPrint(
      '[IngredienteRepository] CRIAR_CATEGORIA_SUCESSO — id=${categoriaCriada.idCategoriaIngrediente}',
    );

    return categoriaCriada;
  }

  Future<CategoriaIngredienteModel> editarCategoria(
    int idCategoriaIngrediente,
    CategoriaIngredienteModel categoria,
  ) async {
    _validarId(
      idCategoriaIngrediente,
      'ID da categoria de ingrediente inválido para edição.',
    );

    final categoriaNormalizada = _normalizarCategoria(categoria);

    debugPrint(
      '[IngredienteRepository] EDITAR_CATEGORIA_INICIO — id=$idCategoriaIngrediente',
    );

    final categoriaEditada = await service.editarCategoria(
      idCategoriaIngrediente,
      categoriaNormalizada,
    );

    debugPrint(
      '[IngredienteRepository] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
    );

    return categoriaEditada;
  }

  Future<CategoriaIngredienteModel> alterarEstadoCategoria(
    int idCategoriaIngrediente,
    bool ativo,
  ) async {
    _validarId(
      idCategoriaIngrediente,
      'ID da categoria de ingrediente inválido para alteração de estado.',
    );

    debugPrint(
      '[IngredienteRepository] ALTERAR_ESTADO_CATEGORIA_INICIO — '
      'id=$idCategoriaIngrediente ativo=$ativo',
    );

    final categoria = await service.alterarEstadoCategoria(
      idCategoriaIngrediente,
      ativo,
    );

    debugPrint(
      '[IngredienteRepository] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
      'id=$idCategoriaIngrediente ativo=${categoria.ativo}',
    );

    return categoria;
  }

  Future<void> desativarCategoria(
    int idCategoriaIngrediente,
  ) async {
    _validarId(
      idCategoriaIngrediente,
      'ID da categoria de ingrediente inválido para desativação.',
    );

    debugPrint(
      '[IngredienteRepository] DESATIVAR_CATEGORIA_INICIO — id=$idCategoriaIngrediente',
    );

    await service.desativarCategoria(
      idCategoriaIngrediente,
    );

    debugPrint(
      '[IngredienteRepository] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
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
    if (idCategoriaIngrediente != null) {
      _validarId(
        idCategoriaIngrediente,
        'ID da categoria de ingrediente inválido para filtro.',
      );
    }

    debugPrint(
      '[IngredienteRepository] LISTAR_INGREDIENTES_INICIO — '
      'somenteAtivos=$somenteAtivos, '
      'somenteDisponiveis=$somenteDisponiveis, '
      'idCategoriaIngrediente=$idCategoriaIngrediente',
    );

    final ingredientes = await service.listarIngredientes(
      somenteAtivos: somenteAtivos,
      somenteDisponiveis: somenteDisponiveis,
      idCategoriaIngrediente: idCategoriaIngrediente,
    );

    debugPrint(
      '[IngredienteRepository] LISTAR_INGREDIENTES_SUCESSO — total=${ingredientes.length}',
    );

    return ingredientes;
  }

  Future<IngredienteModel> buscarIngredientePorId(
    int idIngrediente,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido.',
    );

    debugPrint(
      '[IngredienteRepository] BUSCAR_INGREDIENTE_INICIO — id=$idIngrediente',
    );

    final ingrediente = await service.buscarIngredientePorId(
      idIngrediente,
    );

    debugPrint(
      '[IngredienteRepository] BUSCAR_INGREDIENTE_SUCESSO — id=$idIngrediente',
    );

    return ingrediente;
  }

  Future<IngredienteModel> criarIngrediente(
    IngredienteModel ingrediente,
  ) async {
    final ingredienteNormalizado = _normalizarIngrediente(
      ingrediente,
      validarImagens: true,
    );

    debugPrint(
      '[IngredienteRepository] CRIAR_INGREDIENTE_INICIO — nome=${ingredienteNormalizado.nome}',
    );

    final ingredienteCriado = await service.criarIngrediente(
      ingredienteNormalizado,
    );

    debugPrint(
      '[IngredienteRepository] CRIAR_INGREDIENTE_SUCESSO — id=${ingredienteCriado.idIngrediente}',
    );

    return ingredienteCriado;
  }

Future<IngredienteModel> editarIngrediente(
  int idIngrediente,
  IngredienteModel ingrediente, {
  bool enviarCategorias = true,
  bool enviarImagens = true,
}) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para edição.',
    );

    final ingredienteNormalizado = _normalizarIngrediente(
      ingrediente,
      validarImagens: enviarImagens,
    );

    debugPrint(
      '[IngredienteRepository] EDITAR_INGREDIENTE_INICIO — '
      'id=$idIngrediente enviarImagens=$enviarImagens',
    );

final ingredienteEditado = await service.editarIngrediente(
  idIngrediente,
  ingredienteNormalizado,
  enviarCategorias: enviarCategorias,
  enviarImagens: enviarImagens,
);

    debugPrint(
      '[IngredienteRepository] EDITAR_INGREDIENTE_SUCESSO — id=$idIngrediente',
    );

    return ingredienteEditado;
  }

  Future<IngredienteModel> alterarDisponibilidadeIngrediente(
    int idIngrediente,
    bool disponivel,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para alteração de disponibilidade.',
    );

    debugPrint(
      '[IngredienteRepository] ALTERAR_DISPONIBILIDADE_INGREDIENTE_INICIO — '
      'id=$idIngrediente disponivel=$disponivel',
    );

    final ingrediente = await service.alterarDisponibilidadeIngrediente(
      idIngrediente,
      disponivel,
    );

    debugPrint(
      '[IngredienteRepository] ALTERAR_DISPONIBILIDADE_INGREDIENTE_SUCESSO — '
      'id=$idIngrediente disponivel=${ingrediente.disponivel}',
    );

    return ingrediente;
  }

  Future<IngredienteModel> alterarEstadoIngrediente(
    int idIngrediente,
    bool ativo,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para alteração de estado.',
    );

    debugPrint(
      '[IngredienteRepository] ALTERAR_ESTADO_INGREDIENTE_INICIO — '
      'id=$idIngrediente ativo=$ativo',
    );

    final ingrediente = await service.alterarEstadoIngrediente(
      idIngrediente,
      ativo,
    );

    debugPrint(
      '[IngredienteRepository] ALTERAR_ESTADO_INGREDIENTE_SUCESSO — '
      'id=$idIngrediente ativo=${ingrediente.ativo} disponivel=${ingrediente.disponivel}',
    );

    return ingrediente;
  }

  Future<void> desativarIngrediente(
    int idIngrediente,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para desativação.',
    );

    debugPrint(
      '[IngredienteRepository] DESATIVAR_INGREDIENTE_INICIO — id=$idIngrediente',
    );

    await service.desativarIngrediente(
      idIngrediente,
    );

    debugPrint(
      '[IngredienteRepository] DESATIVAR_INGREDIENTE_SUCESSO — id=$idIngrediente',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGENS
  // ─────────────────────────────────────────────────────────────

  Future<List<IngredienteImagemModel>> listarImagensDoIngrediente(
    int idIngrediente,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para listar imagens.',
    );

    debugPrint(
      '[IngredienteRepository] LISTAR_IMAGENS_INGREDIENTE_INICIO — idIngrediente=$idIngrediente',
    );

    final imagens = await service.listarImagensDoIngrediente(
      idIngrediente,
    );

    debugPrint(
      '[IngredienteRepository] LISTAR_IMAGENS_INGREDIENTE_SUCESSO — '
      'idIngrediente=$idIngrediente total=${imagens.length}',
    );

    return imagens;
  }

  Future<IngredienteModel> adicionarImagemAoIngrediente(
    int idIngrediente,
    IngredienteImagemModel imagem,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para adicionar imagem.',
    );

    final imagemNormalizada = _normalizarImagem(imagem);

    debugPrint(
      '[IngredienteRepository] ADICIONAR_IMAGEM_INGREDIENTE_INICIO — '
      'idIngrediente=$idIngrediente',
    );

    final ingrediente = await service.adicionarImagemAoIngrediente(
      idIngrediente,
      imagemNormalizada,
    );

    debugPrint(
      '[IngredienteRepository] ADICIONAR_IMAGEM_INGREDIENTE_SUCESSO — '
      'idIngrediente=$idIngrediente totalImagens=${ingrediente.imagens.length}',
    );

    return ingrediente;
  }

  Future<IngredienteModel> definirImagemPrincipal(
    int idIngrediente,
    int idIngredienteImagem,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para definir imagem principal.',
    );

    _validarId(
      idIngredienteImagem,
      'ID da imagem do ingrediente inválido para definir principal.',
    );

    debugPrint(
      '[IngredienteRepository] DEFINIR_IMAGEM_PRINCIPAL_INICIO — '
      'idIngrediente=$idIngrediente idImagem=$idIngredienteImagem',
    );

    final ingrediente = await service.definirImagemPrincipal(
      idIngrediente,
      idIngredienteImagem,
    );

    debugPrint(
      '[IngredienteRepository] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
      'idIngrediente=$idIngrediente imagemPrincipal=${ingrediente.imagemPrincipalUrl}',
    );

    return ingrediente;
  }

  Future<IngredienteModel> removerImagemDoIngrediente(
    int idIngrediente,
    int idIngredienteImagem,
  ) async {
    _validarId(
      idIngrediente,
      'ID do ingrediente inválido para remover imagem.',
    );

    _validarId(
      idIngredienteImagem,
      'ID da imagem do ingrediente inválido para remoção.',
    );

    debugPrint(
      '[IngredienteRepository] REMOVER_IMAGEM_INGREDIENTE_INICIO — '
      'idIngrediente=$idIngrediente idImagem=$idIngredienteImagem',
    );

    final ingrediente = await service.removerImagemDoIngrediente(
      idIngrediente,
      idIngredienteImagem,
    );

    debugPrint(
      '[IngredienteRepository] REMOVER_IMAGEM_INGREDIENTE_SUCESSO — '
      'idIngrediente=$idIngrediente totalImagens=${ingrediente.imagens.length}',
    );

    return ingrediente;
  }

  // ─────────────────────────────────────────────────────────────
  // NORMALIZAÇÕES
  // ─────────────────────────────────────────────────────────────

  CategoriaIngredienteModel _normalizarCategoria(
    CategoriaIngredienteModel categoria,
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

  IngredienteModel _normalizarIngrediente(
    IngredienteModel ingrediente, {
    required bool validarImagens,
  }) {
    final nome = ingrediente.nome.trim();

    if (nome.isEmpty) {
      throw Exception('O nome do ingrediente é obrigatório.');
    }

    if (ingrediente.precoAdicional < 0) {
      throw Exception('O preço adicional não pode ser negativo.');
    }

    if (ingrediente.quantidadeEstoque != null &&
        ingrediente.quantidadeEstoque! < 0) {
      throw Exception('A quantidade em estoque não pode ser negativa.');
    }

    for (final categoria in ingrediente.categoriasIngrediente) {
  final idCategoria = categoria.idCategoriaIngrediente;

  if (idCategoria == null) {
    throw Exception('Categoria de ingrediente inválida.');
  }

  _validarId(
    idCategoria,
    'ID da categoria de ingrediente inválido.',
  );
}

final idsCategorias = ingrediente.categoriasIngrediente
    .map((categoria) => categoria.idCategoriaIngrediente)
    .whereType<int>()
    .toList();

final idsUnicos = idsCategorias.toSet();

if (idsCategorias.length != idsUnicos.length) {
  throw Exception('Não é permitido associar a mesma categoria mais de uma vez.');
}

    final imagensNormalizadas = validarImagens
        ? ingrediente.imagens.map(_normalizarImagem).toList()
        : ingrediente.imagens;

return ingrediente.copyWith(
  nome: nome,
  descricao: _normalizarTextoOpcional(ingrediente.descricao),
  precoAdicional: ingrediente.precoAdicional,
  controlaEstoque: ingrediente.controlaEstoque,
  quantidadeEstoque: ingrediente.controlaEstoque
      ? ingrediente.quantidadeEstoque
      : null,
  categoriasIngrediente: ingrediente.categoriasIngrediente,
  imagens: imagensNormalizadas,
);

    
  }

  IngredienteImagemModel _normalizarImagem(
    IngredienteImagemModel imagem,
  ) {
    final imagemUrl = imagem.imagemUrl.trim();

    if (imagemUrl.isEmpty) {
      throw Exception('A URL da imagem é obrigatória quando uma imagem é enviada.');
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