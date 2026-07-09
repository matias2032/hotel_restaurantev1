import 'package:flutter/foundation.dart';

import '../models/servico_model.dart';
import '../repository/servico_repository.dart';

class ServicoProvider extends ChangeNotifier {
  final ServicoRepository repository;

  ServicoProvider({
    required this.repository,
  });

  List<CategoriaServicoModel> _categorias = [];
  List<ServicoModel> _servicos = [];

  ServicoModel? _servicoSelecionado;
  CategoriaServicoModel? _categoriaSelecionada;

  bool _carregando = false;
  String? _erro;

  List<CategoriaServicoModel> get categorias {
    return List.unmodifiable(_categorias);
  }

  List<ServicoModel> get servicos {
    return List.unmodifiable(_servicos);
  }

  ServicoModel? get servicoSelecionado => _servicoSelecionado;

  CategoriaServicoModel? get categoriaSelecionada => _categoriaSelecionada;

  bool get carregando => _carregando;

  String? get erro => _erro;

  bool get temErro => _erro != null;

  // ─────────────────────────────────────────────────────────────
  // CATEGORIAS
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarCategorias({
    bool somenteAtivas = false,
  }) async {
    await _executar(
      'CARREGAR_CATEGORIAS',
      () async {
        _categorias = await repository.listarCategorias(
          somenteAtivas: somenteAtivas,
        );

        debugPrint(
          '[ServicoProvider] CARREGAR_CATEGORIAS_SUCESSO — total=${_categorias.length}',
        );
      },
    );
  }

  Future<CategoriaServicoModel?> buscarCategoriaPorId(
    int idCategoriaServico,
  ) async {
    CategoriaServicoModel? categoria;

    await _executar(
      'BUSCAR_CATEGORIA',
      () async {
        categoria = await repository.buscarCategoriaPorId(
          idCategoriaServico,
        );

        _categoriaSelecionada = categoria;

        _actualizarCategoriaNaLista(categoria!);

        debugPrint(
          '[ServicoProvider] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
        );
      },
    );

    return categoria;
  }

  Future<bool> criarCategoria(
    CategoriaServicoModel categoria,
  ) async {
    var sucesso = false;

    await _executar(
      'CRIAR_CATEGORIA',
      () async {
        final criada = await repository.criarCategoria(
          categoria,
        );

        _categorias = [
          ..._categorias,
          criada,
        ]..sort(_compararCategorias);

        _categoriaSelecionada = criada;
        sucesso = true;

        debugPrint(
          '[ServicoProvider] CRIAR_CATEGORIA_SUCESSO — id=${criada.idCategoriaServico}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> editarCategoria(
    int idCategoriaServico,
    CategoriaServicoModel categoria,
  ) async {
    var sucesso = false;

    await _executar(
      'EDITAR_CATEGORIA',
      () async {
        final editada = await repository.editarCategoria(
          idCategoriaServico,
          categoria,
        );

        _actualizarCategoriaNaLista(editada);

        if (_categoriaSelecionada?.idCategoriaServico == idCategoriaServico) {
          _categoriaSelecionada = editada;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
        );
      },
    );

    return sucesso;
  }

  Future<bool> alterarEstadoCategoria(
    int idCategoriaServico,
    bool ativo,
  ) async {
    var sucesso = false;

    await _executar(
      'ALTERAR_ESTADO_CATEGORIA',
      () async {
        final categoria = await repository.alterarEstadoCategoria(
          idCategoriaServico,
          ativo,
        );

        _actualizarCategoriaNaLista(categoria);

        if (_categoriaSelecionada?.idCategoriaServico == idCategoriaServico) {
          _categoriaSelecionada = categoria;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
          'id=$idCategoriaServico ativo=${categoria.ativo}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> desativarCategoria(
    int idCategoriaServico,
  ) async {
    var sucesso = false;

    await _executar(
      'DESATIVAR_CATEGORIA',
      () async {
        await repository.desativarCategoria(
          idCategoriaServico,
        );

        _categorias = _categorias
            .map((categoria) {
              if (categoria.idCategoriaServico == idCategoriaServico) {
                return categoria.copyWith(
                  ativo: false,
                );
              }

              return categoria;
            })
            .toList()
          ..sort(_compararCategorias);

        if (_categoriaSelecionada?.idCategoriaServico == idCategoriaServico) {
          _categoriaSelecionada = _categoriaSelecionada?.copyWith(
            ativo: false,
          );
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaServico',
        );
      },
    );

    return sucesso;
  }

  // ─────────────────────────────────────────────────────────────
  // SERVIÇOS
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarServicos({
    bool somenteAtivos = false,
    bool somenteDisponiveis = false,
    bool somenteDestaques = false,
    int? idCategoriaServico,
  }) async {
    await _executar(
      'CARREGAR_SERVICOS',
      () async {
        _servicos = await repository.listarServicos(
          somenteAtivos: somenteAtivos,
          somenteDisponiveis: somenteDisponiveis,
          somenteDestaques: somenteDestaques,
          idCategoriaServico: idCategoriaServico,
        );

        debugPrint(
          '[ServicoProvider] CARREGAR_SERVICOS_SUCESSO — total=${_servicos.length}',
        );
      },
    );
  }

  Future<ServicoModel?> buscarServicoPorId(
    int idServico,
  ) async {
    ServicoModel? servico;

    await _executar(
      'BUSCAR_SERVICO',
      () async {
        servico = await repository.buscarServicoPorId(
          idServico,
        );

        _servicoSelecionado = servico;

        _actualizarServicoNaLista(servico!);

        debugPrint(
          '[ServicoProvider] BUSCAR_SERVICO_SUCESSO — id=$idServico',
        );
      },
    );

    return servico;
  }

  Future<bool> criarServico(
    ServicoModel servico,
  ) async {
    var sucesso = false;

    await _executar(
      'CRIAR_SERVICO',
      () async {
        final criado = await repository.criarServico(
          servico,
        );

        _servicos = [
          ..._servicos,
          criado,
        ]..sort(_compararServicos);

        _servicoSelecionado = criado;
        sucesso = true;

        debugPrint(
          '[ServicoProvider] CRIAR_SERVICO_SUCESSO — id=${criado.idServico}',
        );
      },
    );

    return sucesso;
  }

Future<bool> editarServico(
  int idServico,
  ServicoModel servico, {
  bool enviarCategorias = true,
  bool enviarImagens = true,
}) async {
    var sucesso = false;

    await _executar(
      'EDITAR_SERVICO',
      () async {
final editado = await repository.editarServico(
  idServico,
  servico,
  enviarCategorias: enviarCategorias,
  enviarImagens: enviarImagens,
);

        _actualizarServicoNaLista(editado);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = editado;
        }

        sucesso = true;

        debugPrint(
'[ServicoProvider] EDITAR_SERVICO_SUCESSO — '
'id=$idServico enviarCategorias=$enviarCategorias '
'enviarImagens=$enviarImagens',
        );
      },
    );

    return sucesso;
  }

  Future<bool> alterarDisponibilidadeServico(
    int idServico,
    bool disponivel,
  ) async {
    var sucesso = false;

    await _executar(
      'ALTERAR_DISPONIBILIDADE_SERVICO',
      () async {
        final servico = await repository.alterarDisponibilidadeServico(
          idServico,
          disponivel,
        );

        _actualizarServicoNaLista(servico);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = servico;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] ALTERAR_DISPONIBILIDADE_SERVICO_SUCESSO — '
          'id=$idServico disponivel=${servico.disponivel}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> alterarDestaqueServico(
    int idServico,
    bool destaque,
  ) async {
    var sucesso = false;

    await _executar(
      'ALTERAR_DESTAQUE_SERVICO',
      () async {
        final servico = await repository.alterarDestaqueServico(
          idServico,
          destaque,
        );

        _actualizarServicoNaLista(servico);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = servico;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] ALTERAR_DESTAQUE_SERVICO_SUCESSO — '
          'id=$idServico destaque=${servico.destaque}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> alterarEstadoServico(
    int idServico,
    bool ativo,
  ) async {
    var sucesso = false;

    await _executar(
      'ALTERAR_ESTADO_SERVICO',
      () async {
        final servico = await repository.alterarEstadoServico(
          idServico,
          ativo,
        );

        _actualizarServicoNaLista(servico);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = servico;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] ALTERAR_ESTADO_SERVICO_SUCESSO — '
          'id=$idServico ativo=${servico.ativo} '
          'disponivel=${servico.disponivel} destaque=${servico.destaque}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> desativarServico(
    int idServico,
  ) async {
    var sucesso = false;

    await _executar(
      'DESATIVAR_SERVICO',
      () async {
        await repository.desativarServico(
          idServico,
        );

        _servicos = _servicos
            .map((servico) {
              if (servico.idServico == idServico) {
                return servico.copyWith(
                  ativo: false,
                  disponivel: false,
                  destaque: false,
                );
              }

              return servico;
            })
            .toList()
          ..sort(_compararServicos);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = _servicoSelecionado?.copyWith(
            ativo: false,
            disponivel: false,
            destaque: false,
          );
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] DESATIVAR_SERVICO_SUCESSO — id=$idServico',
        );
      },
    );

    return sucesso;
  }

  // ─────────────────────────────────────────────────────────────
  // IMAGENS DO SERVIÇO
  // ─────────────────────────────────────────────────────────────

  Future<List<ServicoImagemModel>> listarImagensDoServico(
    int idServico,
  ) async {
    List<ServicoImagemModel> imagens = [];

    await _executar(
      'LISTAR_IMAGENS_SERVICO',
      () async {
        imagens = await repository.listarImagensDoServico(
          idServico,
        );

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = _servicoSelecionado?.copyWith(
            imagens: imagens,
          );

          _actualizarServicoNaLista(_servicoSelecionado!);
        }

        debugPrint(
          '[ServicoProvider] LISTAR_IMAGENS_SERVICO_SUCESSO — '
          'idServico=$idServico total=${imagens.length}',
        );
      },
    );

    return imagens;
  }

  Future<bool> adicionarImagemAoServico(
    int idServico,
    ServicoImagemModel imagem,
  ) async {
    var sucesso = false;

    await _executar(
      'ADICIONAR_IMAGEM_SERVICO',
      () async {
        final servico = await repository.adicionarImagemAoServico(
          idServico,
          imagem,
        );

        _actualizarServicoNaLista(servico);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = servico;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] ADICIONAR_IMAGEM_SERVICO_SUCESSO — '
          'idServico=$idServico totalImagens=${servico.imagens.length}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> definirImagemPrincipal(
    int idServico,
    int idServicoImagem,
  ) async {
    var sucesso = false;

    await _executar(
      'DEFINIR_IMAGEM_PRINCIPAL',
      () async {
        final servico = await repository.definirImagemPrincipal(
          idServico,
          idServicoImagem,
        );

        _actualizarServicoNaLista(servico);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = servico;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
          'idServico=$idServico idImagem=$idServicoImagem',
        );
      },
    );

    return sucesso;
  }

  Future<bool> removerImagemDoServico(
    int idServico,
    int idServicoImagem,
  ) async {
    var sucesso = false;

    await _executar(
      'REMOVER_IMAGEM_SERVICO',
      () async {
        final servico = await repository.removerImagemDoServico(
          idServico,
          idServicoImagem,
        );

        _actualizarServicoNaLista(servico);

        if (_servicoSelecionado?.idServico == idServico) {
          _servicoSelecionado = servico;
        }

        sucesso = true;

        debugPrint(
          '[ServicoProvider] REMOVER_IMAGEM_SERVICO_SUCESSO — '
          'idServico=$idServico idImagem=$idServicoImagem '
          'totalImagens=${servico.imagens.length}',
        );
      },
    );

    return sucesso;
  }

  // ─────────────────────────────────────────────────────────────
  // SELEÇÃO / UTILITÁRIOS
  // ─────────────────────────────────────────────────────────────

  void selecionarServico(
    ServicoModel? servico,
  ) {
    _servicoSelecionado = servico;

    debugPrint(
      '[ServicoProvider] SELECIONAR_SERVICO — id=${servico?.idServico}',
    );

    notifyListeners();
  }

  void selecionarCategoria(
    CategoriaServicoModel? categoria,
  ) {
    _categoriaSelecionada = categoria;

    debugPrint(
      '[ServicoProvider] SELECIONAR_CATEGORIA — id=${categoria?.idCategoriaServico}',
    );

    notifyListeners();
  }

  void limparSelecao() {
    _servicoSelecionado = null;
    _categoriaSelecionada = null;

    debugPrint(
      '[ServicoProvider] LIMPAR_SELECAO',
    );

    notifyListeners();
  }

  void limparErro() {
    _erro = null;

    debugPrint(
      '[ServicoProvider] LIMPAR_ERRO',
    );

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS INTERNOS
  // ─────────────────────────────────────────────────────────────

  Future<void> _executar(
    String acao,
    Future<void> Function() operacao,
  ) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    debugPrint(
      '[ServicoProvider] ${acao}_INICIO',
    );

    try {
      await operacao();
    } catch (e, stackTrace) {
      _erro = _normalizarErro(e);

      debugPrint(
        '[ServicoProvider] ${acao}_ERRO — $_erro',
      );

      debugPrint(
        stackTrace.toString(),
      );
    } finally {
      _carregando = false;

      debugPrint(
        '[ServicoProvider] ${acao}_FIM',
      );

      notifyListeners();
    }
  }

  void _actualizarCategoriaNaLista(
    CategoriaServicoModel categoria,
  ) {
    final id = categoria.idCategoriaServico;

    if (id == null) {
      return;
    }

    final index = _categorias.indexWhere(
      (item) => item.idCategoriaServico == id,
    );

    if (index >= 0) {
      final novaLista = [..._categorias];
      novaLista[index] = categoria;
      _categorias = novaLista..sort(_compararCategorias);
    } else {
      _categorias = [
        ..._categorias,
        categoria,
      ]..sort(_compararCategorias);
    }
  }

  void _actualizarServicoNaLista(
    ServicoModel servico,
  ) {
    final id = servico.idServico;

    if (id == null) {
      return;
    }

    final index = _servicos.indexWhere(
      (item) => item.idServico == id,
    );

    if (index >= 0) {
      final novaLista = [..._servicos];
      novaLista[index] = servico;
      _servicos = novaLista..sort(_compararServicos);
    } else {
      _servicos = [
        ..._servicos,
        servico,
      ]..sort(_compararServicos);
    }
  }

  int _compararCategorias(
    CategoriaServicoModel a,
    CategoriaServicoModel b,
  ) {
    final ordem = a.ordem.compareTo(b.ordem);

    if (ordem != 0) {
      return ordem;
    }

    return a.nome.toLowerCase().compareTo(
          b.nome.toLowerCase(),
        );
  }

  int _compararServicos(
    ServicoModel a,
    ServicoModel b,
  ) {
    return a.nome.toLowerCase().compareTo(
          b.nome.toLowerCase(),
        );
  }

  String _normalizarErro(
    Object erro,
  ) {
    final mensagem = erro.toString();

    if (mensagem.startsWith('Exception: ')) {
      return mensagem.replaceFirst('Exception: ', '').trim();
    }

    return mensagem.trim();
  }
}