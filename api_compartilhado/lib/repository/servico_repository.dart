import 'package:flutter/foundation.dart';

import '../models/servico_model.dart';
import '../services/servico_service.dart';

class ServicoRepository {
  final ServicoService service;

  ServicoRepository({
    required this.service,
  });

  // ─────────────────────────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────────────────────────

  Future<List<CategoriaServicoModel>> listarCategorias({
    bool somenteAtivas = false,
  }) async {
    debugPrint(
      '[ServicoRepository] LISTAR_CATEGORIAS_INICIO — somenteAtivas=$somenteAtivas',
    );

    final categorias = await service.listarCategorias(
      somenteAtivas: somenteAtivas,
    );

    debugPrint(
      '[ServicoRepository] LISTAR_CATEGORIAS_SUCESSO — total=${categorias.length}',
    );

    return categorias;
  }

  Future<CategoriaServicoModel> buscarCategoriaPorId(
    int idCategoriaServico,
  ) async {
    _validarId(
      idCategoriaServico,
      'ID da categoria de serviço inválido.',
    );

    debugPrint(
      '[ServicoRepository] BUSCAR_CATEGORIA_INICIO — id=$idCategoriaServico',
    );

    final categoria = await service.buscarCategoriaPorId(
      idCategoriaServico,
    );

    debugPrint(
      '[ServicoRepository] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
    );

    return categoria;
  }

  Future<CategoriaServicoModel> criarCategoria(
    CategoriaServicoModel categoria,
  ) async {
    final categoriaNormalizada = _normalizarCategoria(
      categoria,
    );

    debugPrint(
      '[ServicoRepository] CRIAR_CATEGORIA_INICIO — nome=${categoriaNormalizada.nome}',
    );

    final categoriaCriada = await service.criarCategoria(
      categoriaNormalizada,
    );

    debugPrint(
      '[ServicoRepository] CRIAR_CATEGORIA_SUCESSO — id=${categoriaCriada.idCategoriaServico}',
    );

    return categoriaCriada;
  }

  Future<CategoriaServicoModel> editarCategoria(
    int idCategoriaServico,
    CategoriaServicoModel categoria,
  ) async {
    _validarId(
      idCategoriaServico,
      'ID da categoria de serviço inválido para edição.',
    );

    final categoriaNormalizada = _normalizarCategoria(
      categoria,
    );

    debugPrint(
      '[ServicoRepository] EDITAR_CATEGORIA_INICIO — id=$idCategoriaServico',
    );

    final categoriaEditada = await service.editarCategoria(
      idCategoriaServico,
      categoriaNormalizada,
    );

    debugPrint(
      '[ServicoRepository] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
    );

    return categoriaEditada;
  }

  Future<CategoriaServicoModel> alterarEstadoCategoria(
    int idCategoriaServico,
    bool ativo,
  ) async {
    _validarId(
      idCategoriaServico,
      'ID da categoria de serviço inválido para alteração de estado.',
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_ESTADO_CATEGORIA_INICIO — '
      'id=$idCategoriaServico ativo=$ativo',
    );

    final categoria = await service.alterarEstadoCategoria(
      idCategoriaServico,
      ativo,
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
      'id=$idCategoriaServico ativo=${categoria.ativo}',
    );

    return categoria;
  }

  Future<void> desativarCategoria(
    int idCategoriaServico,
  ) async {
    _validarId(
      idCategoriaServico,
      'ID da categoria de serviço inválido para desativação.',
    );

    debugPrint(
      '[ServicoRepository] DESATIVAR_CATEGORIA_INICIO — id=$idCategoriaServico',
    );

    await service.desativarCategoria(
      idCategoriaServico,
    );

    debugPrint(
      '[ServicoRepository] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
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
    if (idCategoriaServico != null) {
      _validarId(
        idCategoriaServico,
        'ID da categoria de serviço inválido para filtro.',
      );
    }

    debugPrint(
      '[ServicoRepository] LISTAR_SERVICOS_INICIO — '
      'somenteAtivos=$somenteAtivos, '
      'somenteDisponiveis=$somenteDisponiveis, '
      'somenteDestaques=$somenteDestaques, '
      'idCategoriaServico=$idCategoriaServico',
    );

    final servicos = await service.listarServicos(
      somenteAtivos: somenteAtivos,
      somenteDisponiveis: somenteDisponiveis,
      somenteDestaques: somenteDestaques,
      idCategoriaServico: idCategoriaServico,
    );

    debugPrint(
      '[ServicoRepository] LISTAR_SERVICOS_SUCESSO — total=${servicos.length}',
    );

    return servicos;
  }

  Future<ServicoModel> buscarServicoPorId(
    int idServico,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido.',
    );

    debugPrint(
      '[ServicoRepository] BUSCAR_SERVICO_INICIO — id=$idServico',
    );

    final servico = await service.buscarServicoPorId(
      idServico,
    );

    debugPrint(
      '[ServicoRepository] BUSCAR_SERVICO_SUCESSO — id=$idServico',
    );

    return servico;
  }

  Future<ServicoModel> criarServico(
    ServicoModel servico,
  ) async {
    final servicoNormalizado = _normalizarServico(
      servico,
      validarImagens: true,
    );

    debugPrint(
      '[ServicoRepository] CRIAR_SERVICO_INICIO — nome=${servicoNormalizado.nome}',
    );

    final servicoCriado = await service.criarServico(
      servicoNormalizado,
    );

    debugPrint(
      '[ServicoRepository] CRIAR_SERVICO_SUCESSO — id=${servicoCriado.idServico}',
    );

    return servicoCriado;
  }

  Future<ServicoModel> editarServico(
    int idServico,
    ServicoModel servico, {
    bool enviarImagens = true,
  }) async {
    _validarId(
      idServico,
      'ID do serviço inválido para edição.',
    );

    final servicoNormalizado = _normalizarServico(
      servico,
      validarImagens: enviarImagens,
    );

    debugPrint(
      '[ServicoRepository] EDITAR_SERVICO_INICIO — '
      'id=$idServico enviarImagens=$enviarImagens',
    );

    final servicoEditado = await service.editarServico(
      idServico,
      servicoNormalizado,
      enviarImagens: enviarImagens,
    );

    debugPrint(
      '[ServicoRepository] EDITAR_SERVICO_SUCESSO — id=$idServico',
    );

    return servicoEditado;
  }

  Future<ServicoModel> alterarDisponibilidadeServico(
    int idServico,
    bool disponivel,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para alteração de disponibilidade.',
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_DISPONIBILIDADE_SERVICO_INICIO — '
      'id=$idServico disponivel=$disponivel',
    );

    final servico = await service.alterarDisponibilidadeServico(
      idServico,
      disponivel,
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_DISPONIBILIDADE_SERVICO_SUCESSO — '
      'id=$idServico disponivel=${servico.disponivel}',
    );

    return servico;
  }

  Future<ServicoModel> alterarDestaqueServico(
    int idServico,
    bool destaque,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para alteração de destaque.',
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_DESTAQUE_SERVICO_INICIO — '
      'id=$idServico destaque=$destaque',
    );

    final servico = await service.alterarDestaqueServico(
      idServico,
      destaque,
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_DESTAQUE_SERVICO_SUCESSO — '
      'id=$idServico destaque=${servico.destaque}',
    );

    return servico;
  }

  Future<ServicoModel> alterarEstadoServico(
    int idServico,
    bool ativo,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para alteração de estado.',
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_ESTADO_SERVICO_INICIO — '
      'id=$idServico ativo=$ativo',
    );

    final servico = await service.alterarEstadoServico(
      idServico,
      ativo,
    );

    debugPrint(
      '[ServicoRepository] ALTERAR_ESTADO_SERVICO_SUCESSO — '
      'id=$idServico ativo=${servico.ativo} '
      'disponivel=${servico.disponivel} destaque=${servico.destaque}',
    );

    return servico;
  }

  Future<void> desativarServico(
    int idServico,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para desativação.',
    );

    debugPrint(
      '[ServicoRepository] DESATIVAR_SERVICO_INICIO — id=$idServico',
    );

    await service.desativarServico(
      idServico,
    );

    debugPrint(
      '[ServicoRepository] DESATIVAR_SERVICO_SUCESSO — id=$idServico',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGENS DO SERVIÇO
  // ─────────────────────────────────────────────────────────────

  Future<List<ServicoImagemModel>> listarImagensDoServico(
    int idServico,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para listar imagens.',
    );

    debugPrint(
      '[ServicoRepository] LISTAR_IMAGENS_SERVICO_INICIO — idServico=$idServico',
    );

    final imagens = await service.listarImagensDoServico(
      idServico,
    );

    debugPrint(
      '[ServicoRepository] LISTAR_IMAGENS_SERVICO_SUCESSO — '
      'idServico=$idServico total=${imagens.length}',
    );

    return imagens;
  }

  Future<ServicoModel> adicionarImagemAoServico(
    int idServico,
    ServicoImagemModel imagem,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para adicionar imagem.',
    );

    final imagemNormalizada = _normalizarImagem(
      imagem,
    );

    debugPrint(
      '[ServicoRepository] ADICIONAR_IMAGEM_SERVICO_INICIO — '
      'idServico=$idServico',
    );

    final servico = await service.adicionarImagemAoServico(
      idServico,
      imagemNormalizada,
    );

    debugPrint(
      '[ServicoRepository] ADICIONAR_IMAGEM_SERVICO_SUCESSO — '
      'idServico=$idServico totalImagens=${servico.imagens.length}',
    );

    return servico;
  }

  Future<ServicoModel> definirImagemPrincipal(
    int idServico,
    int idServicoImagem,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para definir imagem principal.',
    );

    _validarId(
      idServicoImagem,
      'ID da imagem do serviço inválido para definir principal.',
    );

    debugPrint(
      '[ServicoRepository] DEFINIR_IMAGEM_PRINCIPAL_INICIO — '
      'idServico=$idServico idImagem=$idServicoImagem',
    );

    final servico = await service.definirImagemPrincipal(
      idServico,
      idServicoImagem,
    );

    debugPrint(
      '[ServicoRepository] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
      'idServico=$idServico imagemPrincipal=${servico.imagemPrincipalUrl}',
    );

    return servico;
  }

  Future<ServicoModel> removerImagemDoServico(
    int idServico,
    int idServicoImagem,
  ) async {
    _validarId(
      idServico,
      'ID do serviço inválido para remover imagem.',
    );

    _validarId(
      idServicoImagem,
      'ID da imagem do serviço inválido para remoção.',
    );

    debugPrint(
      '[ServicoRepository] REMOVER_IMAGEM_SERVICO_INICIO — '
      'idServico=$idServico idImagem=$idServicoImagem',
    );

    final servico = await service.removerImagemDoServico(
      idServico,
      idServicoImagem,
    );

    debugPrint(
      '[ServicoRepository] REMOVER_IMAGEM_SERVICO_SUCESSO — '
      'idServico=$idServico totalImagens=${servico.imagens.length}',
    );

    return servico;
  }

  // ─────────────────────────────────────────────────────────────
  // NORMALIZAÇÕES
  // ─────────────────────────────────────────────────────────────

  CategoriaServicoModel _normalizarCategoria(
    CategoriaServicoModel categoria,
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

  ServicoModel _normalizarServico(
    ServicoModel servico, {
    required bool validarImagens,
  }) {
    final nome = servico.nome.trim();

    if (nome.isEmpty) {
      throw Exception('O nome do serviço é obrigatório.');
    }

    if (servico.preco < 0) {
      throw Exception('O preço do serviço não pode ser negativo.');
    }

    final idCategoria = servico.categoriaServico?.idCategoriaServico;

    if (idCategoria != null) {
      _validarId(
        idCategoria,
        'ID da categoria de serviço inválido.',
      );
    }

    if (!servico.ativo && servico.disponivel) {
      throw Exception(
        'Não é possível disponibilizar um serviço inativo.',
      );
    }

    final imagensNormalizadas = validarImagens
        ? servico.imagens.map(_normalizarImagem).toList()
        : servico.imagens;

    return servico.copyWith(
      nome: nome,
      descricao: _normalizarTextoOpcional(servico.descricao),
      preco: servico.preco,
      imagemPrincipalUrl: _normalizarTextoOpcional(
        servico.imagemPrincipalUrl,
      ),
      disponivel: servico.ativo ? servico.disponivel : false,
      destaque: servico.ativo ? servico.destaque : false,
      imagens: imagensNormalizadas,
    );
  }

  ServicoImagemModel _normalizarImagem(
    ServicoImagemModel imagem,
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