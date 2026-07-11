import 'package:flutter/foundation.dart';

import '../models/ingrediente_model.dart';
import '../repository/ingrediente_repository.dart';

class IngredienteProvider extends ChangeNotifier {
  final IngredienteRepository repository;

  IngredienteProvider({
    required this.repository,
  });

  List<CategoriaIngredienteModel> _categorias = [];
  List<IngredienteModel> _ingredientes = [];

  IngredienteModel? _ingredienteSelecionado;
  CategoriaIngredienteModel? _categoriaSelecionada;

  bool _carregando = false;
  String? _erro;

  List<CategoriaIngredienteModel> get categorias {
    return List.unmodifiable(_categorias);
  }

  List<IngredienteModel> get ingredientes {
    return List.unmodifiable(_ingredientes);
  }

  IngredienteModel? get ingredienteSelecionado => _ingredienteSelecionado;

  CategoriaIngredienteModel? get categoriaSelecionada => _categoriaSelecionada;

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
          '[IngredienteProvider] CARREGAR_CATEGORIAS_SUCESSO — total=${_categorias.length}',
        );
      },
    );
  }

  Future<CategoriaIngredienteModel?> buscarCategoriaPorId(
    int idCategoriaIngrediente,
  ) async {
    CategoriaIngredienteModel? categoria;

    await _executar(
      'BUSCAR_CATEGORIA',
      () async {
        categoria = await repository.buscarCategoriaPorId(
          idCategoriaIngrediente,
        );

        _categoriaSelecionada = categoria;

        _actualizarCategoriaNaLista(categoria!);

        debugPrint(
          '[IngredienteProvider] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
        );
      },
    );

    return categoria;
  }

  Future<bool> criarCategoria(
    CategoriaIngredienteModel categoria,
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
          '[IngredienteProvider] CRIAR_CATEGORIA_SUCESSO — id=${criada.idCategoriaIngrediente}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> editarCategoria(
    int idCategoriaIngrediente,
    CategoriaIngredienteModel categoria,
  ) async {
    var sucesso = false;

    await _executar(
      'EDITAR_CATEGORIA',
      () async {
        final editada = await repository.editarCategoria(
          idCategoriaIngrediente,
          categoria,
        );

        _actualizarCategoriaNaLista(editada);

        if (_categoriaSelecionada?.idCategoriaIngrediente ==
            idCategoriaIngrediente) {
          _categoriaSelecionada = editada;
        }

        sucesso = true;

        debugPrint(
          '[IngredienteProvider] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
        );
      },
    );

    return sucesso;
  }

  Future<bool> alterarEstadoCategoria(
    int idCategoriaIngrediente,
    bool ativo,
  ) async {
    var sucesso = false;

    await _executar(
      'ALTERAR_ESTADO_CATEGORIA',
      () async {
        final categoria = await repository.alterarEstadoCategoria(
          idCategoriaIngrediente,
          ativo,
        );

        _actualizarCategoriaNaLista(categoria);

        if (_categoriaSelecionada?.idCategoriaIngrediente ==
            idCategoriaIngrediente) {
          _categoriaSelecionada = categoria;
        }

        sucesso = true;

        debugPrint(
          '[IngredienteProvider] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
          'id=$idCategoriaIngrediente ativo=${categoria.ativo}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> desativarCategoria(
    int idCategoriaIngrediente,
  ) async {
    var sucesso = false;

    await _executar(
      'DESATIVAR_CATEGORIA',
      () async {
        await repository.desativarCategoria(
          idCategoriaIngrediente,
        );

        _categorias = _categorias
            .map((categoria) {
              if (categoria.idCategoriaIngrediente == idCategoriaIngrediente) {
                return categoria.copyWith(
                  ativo: false,
                );
              }

              return categoria;
            })
            .toList()
          ..sort(_compararCategorias);

        if (_categoriaSelecionada?.idCategoriaIngrediente ==
            idCategoriaIngrediente) {
          _categoriaSelecionada = _categoriaSelecionada?.copyWith(
            ativo: false,
          );
        }

        sucesso = true;

        debugPrint(
          '[IngredienteProvider] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaIngrediente',
        );
      },
    );

    return sucesso;
  }

  // ─────────────────────────────────────────────────────────────
  // INGREDIENTES
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarIngredientes({
    bool somenteAtivos = false,
    bool somenteDisponiveis = false,
    int? idCategoriaIngrediente,
  }) async {
    await _executar(
      'CARREGAR_INGREDIENTES',
      () async {
        _ingredientes = await repository.listarIngredientes(
          somenteAtivos: somenteAtivos,
          somenteDisponiveis: somenteDisponiveis,
          idCategoriaIngrediente: idCategoriaIngrediente,
        );

        debugPrint(
          '[IngredienteProvider] CARREGAR_INGREDIENTES_SUCESSO — total=${_ingredientes.length}',
        );
      },
    );
  }

  Future<IngredienteModel?> buscarIngredientePorId(
    int idIngrediente,
  ) async {
    IngredienteModel? ingrediente;

    await _executar(
      'BUSCAR_INGREDIENTE',
      () async {
        ingrediente = await repository.buscarIngredientePorId(
          idIngrediente,
        );

        _ingredienteSelecionado = ingrediente;

        _actualizarIngredienteNaLista(ingrediente!);

        debugPrint(
          '[IngredienteProvider] BUSCAR_INGREDIENTE_SUCESSO — id=$idIngrediente',
        );
      },
    );

    return ingrediente;
  }

  Future<bool> criarIngrediente(
    IngredienteModel ingrediente,
  ) async {
    var sucesso = false;

    await _executar(
      'CRIAR_INGREDIENTE',
      () async {
        final criado = await repository.criarIngrediente(
          ingrediente,
        );

        _ingredientes = [
          ..._ingredientes,
          criado,
        ]..sort(_compararIngredientes);

        _ingredienteSelecionado = criado;
        sucesso = true;

        debugPrint(
          '[IngredienteProvider] CRIAR_INGREDIENTE_SUCESSO — id=${criado.idIngrediente}',
        );
      },
    );

    return sucesso;
  }

Future<bool> editarIngrediente(
  int idIngrediente,
  IngredienteModel ingrediente, {
  bool enviarCategorias = true,
  bool enviarImagens = true,
}) async {
    var sucesso = false;

    await _executar(
      'EDITAR_INGREDIENTE',
      () async {
        final editado = await repository.editarIngrediente(
  idIngrediente,
  ingrediente,
  enviarCategorias: enviarCategorias,
  enviarImagens: enviarImagens,
);

        _actualizarIngredienteNaLista(editado);

        if (_ingredienteSelecionado?.idIngrediente == idIngrediente) {
          _ingredienteSelecionado = editado;
        }

        sucesso = true;

        debugPrint(
          '[IngredienteProvider] EDITAR_INGREDIENTE_SUCESSO — '
          'id=$idIngrediente enviarCategorias=$enviarCategorias enviarImagens=$enviarImagens',
        );
      },
    );

    return sucesso;
  }



Future<bool> alterarEstadoIngrediente(
  int idIngrediente,
  bool ativo,
) async {
  var sucesso = false;

  await _executar(
    'ALTERAR_ESTADO_INGREDIENTE',
    () async {
      final ingrediente =
          await repository.alterarEstadoIngrediente(
        idIngrediente,
        ativo,
      );

      _actualizarIngredienteNaLista(ingrediente);

      if (_ingredienteSelecionado?.idIngrediente ==
          idIngrediente) {
        _ingredienteSelecionado = ingrediente;
      }

      sucesso = true;

      debugPrint(
        '[IngredienteProvider] '
        'ALTERAR_ESTADO_INGREDIENTE_SUCESSO — '
        'id=$idIngrediente '
        'ativo=${ingrediente.ativo} '
        'disponivelCalculado='
        '${ingrediente.disponivelCalculado}',
      );
    },
  );

  return sucesso;
}

 Future<bool> desativarIngrediente(
  int idIngrediente,
) async {
  var sucesso = false;

  await _executar(
    'DESATIVAR_INGREDIENTE',
    () async {
      await repository.desativarIngrediente(
        idIngrediente,
      );

      _ingredientes = _ingredientes
          .map((ingrediente) {
            if (ingrediente.idIngrediente !=
                idIngrediente) {
              return ingrediente;
            }

            return ingrediente.copyWith(
              ativo: false,
              disponivelCalculado: false,
              motivoIndisponibilidade:
                  'Ingrediente inativo.',
            );
          })
          .toList()
        ..sort(_compararIngredientes);

      if (_ingredienteSelecionado?.idIngrediente ==
          idIngrediente) {
        _ingredienteSelecionado =
            _ingredienteSelecionado?.copyWith(
          ativo: false,
          disponivelCalculado: false,
          motivoIndisponibilidade:
              'Ingrediente inativo.',
        );
      }

      sucesso = true;

      debugPrint(
        '[IngredienteProvider] '
        'DESATIVAR_INGREDIENTE_SUCESSO — '
        'id=$idIngrediente',
      );
    },
  );

  return sucesso;
}
  // ─────────────────────────────────────────────────────────────
  // IMAGENS
  // ─────────────────────────────────────────────────────────────

  Future<bool> adicionarImagemAoIngrediente(
    int idIngrediente,
    IngredienteImagemModel imagem,
  ) async {
    var sucesso = false;

    await _executar(
      'ADICIONAR_IMAGEM_INGREDIENTE',
      () async {
        final ingrediente = await repository.adicionarImagemAoIngrediente(
          idIngrediente,
          imagem,
        );

        _actualizarIngredienteNaLista(ingrediente);

        if (_ingredienteSelecionado?.idIngrediente == idIngrediente) {
          _ingredienteSelecionado = ingrediente;
        }

        sucesso = true;

        debugPrint(
          '[IngredienteProvider] ADICIONAR_IMAGEM_INGREDIENTE_SUCESSO — '
          'idIngrediente=$idIngrediente totalImagens=${ingrediente.imagens.length}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> definirImagemPrincipal(
    int idIngrediente,
    int idIngredienteImagem,
  ) async {
    var sucesso = false;

    await _executar(
      'DEFINIR_IMAGEM_PRINCIPAL',
      () async {
        final ingrediente = await repository.definirImagemPrincipal(
          idIngrediente,
          idIngredienteImagem,
        );

        _actualizarIngredienteNaLista(ingrediente);

        if (_ingredienteSelecionado?.idIngrediente == idIngrediente) {
          _ingredienteSelecionado = ingrediente;
        }

        sucesso = true;

        debugPrint(
          '[IngredienteProvider] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
          'idIngrediente=$idIngrediente idImagem=$idIngredienteImagem',
        );
      },
    );

    return sucesso;
  }

  Future<bool> removerImagemDoIngrediente(
    int idIngrediente,
    int idIngredienteImagem,
  ) async {
    var sucesso = false;

    await _executar(
      'REMOVER_IMAGEM_INGREDIENTE',
      () async {
        final ingrediente = await repository.removerImagemDoIngrediente(
          idIngrediente,
          idIngredienteImagem,
        );

        _actualizarIngredienteNaLista(ingrediente);

        if (_ingredienteSelecionado?.idIngrediente == idIngrediente) {
          _ingredienteSelecionado = ingrediente;
        }

        sucesso = true;

        debugPrint(
          '[IngredienteProvider] REMOVER_IMAGEM_INGREDIENTE_SUCESSO — '
          'idIngrediente=$idIngrediente idImagem=$idIngredienteImagem '
          'totalImagens=${ingrediente.imagens.length}',
        );
      },
    );

    return sucesso;
  }

  // ─────────────────────────────────────────────────────────────
  // SELEÇÃO / UTILITÁRIOS
  // ─────────────────────────────────────────────────────────────

  void selecionarIngrediente(
    IngredienteModel? ingrediente,
  ) {
    _ingredienteSelecionado = ingrediente;

    debugPrint(
      '[IngredienteProvider] SELECIONAR_INGREDIENTE — id=${ingrediente?.idIngrediente}',
    );

    notifyListeners();
  }

  void selecionarCategoria(
    CategoriaIngredienteModel? categoria,
  ) {
    _categoriaSelecionada = categoria;

    debugPrint(
      '[IngredienteProvider] SELECIONAR_CATEGORIA — id=${categoria?.idCategoriaIngrediente}',
    );

    notifyListeners();
  }

  void limparSelecao() {
    _ingredienteSelecionado = null;
    _categoriaSelecionada = null;

    debugPrint(
      '[IngredienteProvider] LIMPAR_SELECAO',
    );

    notifyListeners();
  }

  void limparErro() {
    _erro = null;

    debugPrint(
      '[IngredienteProvider] LIMPAR_ERRO',
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
      '[IngredienteProvider] ${acao}_INICIO',
    );

    try {
      await operacao();
    } catch (e, stackTrace) {
      _erro = _normalizarErro(e);

      debugPrint(
        '[IngredienteProvider] ${acao}_ERRO — $_erro',
      );

      debugPrint(
        stackTrace.toString(),
      );
    } finally {
      _carregando = false;

      debugPrint(
        '[IngredienteProvider] ${acao}_FIM',
      );

      notifyListeners();
    }
  }

  void _actualizarCategoriaNaLista(
    CategoriaIngredienteModel categoria,
  ) {
    final id = categoria.idCategoriaIngrediente;

    if (id == null) {
      return;
    }

    final index = _categorias.indexWhere(
      (item) => item.idCategoriaIngrediente == id,
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

  void _actualizarIngredienteNaLista(
    IngredienteModel ingrediente,
  ) {
    final id = ingrediente.idIngrediente;

    if (id == null) {
      return;
    }

    final index = _ingredientes.indexWhere(
      (item) => item.idIngrediente == id,
    );

    if (index >= 0) {
      final novaLista = [..._ingredientes];
      novaLista[index] = ingrediente;
      _ingredientes = novaLista..sort(_compararIngredientes);
    } else {
      _ingredientes = [
        ..._ingredientes,
        ingrediente,
      ]..sort(_compararIngredientes);
    }
  }

  int _compararCategorias(
    CategoriaIngredienteModel a,
    CategoriaIngredienteModel b,
  ) {
    final ordem = a.ordem.compareTo(b.ordem);

    if (ordem != 0) {
      return ordem;
    }

    return a.nome.toLowerCase().compareTo(
          b.nome.toLowerCase(),
        );
  }

  int _compararIngredientes(
    IngredienteModel a,
    IngredienteModel b,
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