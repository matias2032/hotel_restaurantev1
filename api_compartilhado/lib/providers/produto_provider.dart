import 'package:flutter/foundation.dart';

import '../models/produto_model.dart';
import '../repository/produto_repository.dart';

class ProdutoProvider extends ChangeNotifier {
  final ProdutoRepository repository;

  ProdutoProvider({
    required this.repository,
  });

  List<CategoriaProdutoModel> _categorias = [];
  List<ProdutoModel> _produtos = [];

  ProdutoModel? _produtoSelecionado;
  CategoriaProdutoModel? _categoriaSelecionada;

  bool _carregando = false;
  String? _erro;

  List<CategoriaProdutoModel> get categorias {
    return List.unmodifiable(_categorias);
  }

  List<ProdutoModel> get produtos {
    return List.unmodifiable(_produtos);
  }

  ProdutoModel? get produtoSelecionado => _produtoSelecionado;

  CategoriaProdutoModel? get categoriaSelecionada => _categoriaSelecionada;

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
          '[ProdutoProvider] CARREGAR_CATEGORIAS_SUCESSO — total=${_categorias.length}',
        );
      },
    );
  }

  Future<CategoriaProdutoModel?> buscarCategoriaPorId(
    int idCategoriaProduto,
  ) async {
    CategoriaProdutoModel? categoria;

    await _executar(
      'BUSCAR_CATEGORIA',
      () async {
        categoria = await repository.buscarCategoriaPorId(
          idCategoriaProduto,
        );

        _categoriaSelecionada = categoria;

        _actualizarCategoriaNaLista(categoria!);

        debugPrint(
          '[ProdutoProvider] BUSCAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
        );
      },
    );

    return categoria;
  }

  Future<bool> criarCategoria(
    CategoriaProdutoModel categoria,
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
          '[ProdutoProvider] CRIAR_CATEGORIA_SUCESSO — id=${criada.idCategoriaProduto}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> editarCategoria(
    int idCategoriaProduto,
    CategoriaProdutoModel categoria,
  ) async {
    var sucesso = false;

    await _executar(
      'EDITAR_CATEGORIA',
      () async {
        final editada = await repository.editarCategoria(
          idCategoriaProduto,
          categoria,
        );

        _actualizarCategoriaNaLista(editada);

        if (_categoriaSelecionada?.idCategoriaProduto == idCategoriaProduto) {
          _categoriaSelecionada = editada;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] EDITAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
        );
      },
    );

    return sucesso;
  }

  Future<bool> alterarEstadoCategoria(
    int idCategoriaProduto,
    bool ativo,
  ) async {
    var sucesso = false;

    await _executar(
      'ALTERAR_ESTADO_CATEGORIA',
      () async {
        final categoria = await repository.alterarEstadoCategoria(
          idCategoriaProduto,
          ativo,
        );

        _actualizarCategoriaNaLista(categoria);

        if (_categoriaSelecionada?.idCategoriaProduto == idCategoriaProduto) {
          _categoriaSelecionada = categoria;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] ALTERAR_ESTADO_CATEGORIA_SUCESSO — '
          'id=$idCategoriaProduto ativo=${categoria.ativo}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> desativarCategoria(
    int idCategoriaProduto,
  ) async {
    var sucesso = false;

    await _executar(
      'DESATIVAR_CATEGORIA',
      () async {
        await repository.desativarCategoria(
          idCategoriaProduto,
        );

        _categorias = _categorias
            .map((categoria) {
              if (categoria.idCategoriaProduto == idCategoriaProduto) {
                return categoria.copyWith(
                  ativo: false,
                );
              }

              return categoria;
            })
            .toList()
          ..sort(_compararCategorias);

        if (_categoriaSelecionada?.idCategoriaProduto == idCategoriaProduto) {
          _categoriaSelecionada = _categoriaSelecionada?.copyWith(
            ativo: false,
          );
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] DESATIVAR_CATEGORIA_SUCESSO — id=$idCategoriaProduto',
        );
      },
    );

    return sucesso;
  }

  // ─────────────────────────────────────────────────────────────
  // PRODUTOS
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarProdutos({
    bool somenteAtivos = false,
    bool somenteDisponiveis = false,
    bool somenteDestaques = false,
    int? idCategoriaProduto,
  }) async {
    await _executar(
      'CARREGAR_PRODUTOS',
      () async {
        _produtos = await repository.listarProdutos(
          somenteAtivos: somenteAtivos,
          somenteDisponiveis: somenteDisponiveis,
          somenteDestaques: somenteDestaques,
          idCategoriaProduto: idCategoriaProduto,
        );

        debugPrint(
          '[ProdutoProvider] CARREGAR_PRODUTOS_SUCESSO — total=${_produtos.length}',
        );
      },
    );
  }

  Future<ProdutoModel?> buscarProdutoPorId(
    int idProduto,
  ) async {
    ProdutoModel? produto;

    await _executar(
      'BUSCAR_PRODUTO',
      () async {
        produto = await repository.buscarProdutoPorId(
          idProduto,
        );

        _produtoSelecionado = produto;

        _actualizarProdutoNaLista(produto!);

        debugPrint(
          '[ProdutoProvider] BUSCAR_PRODUTO_SUCESSO — id=$idProduto',
        );
      },
    );

    return produto;
  }

  Future<bool> criarProduto(
    ProdutoModel produto,
  ) async {
    var sucesso = false;

    await _executar(
      'CRIAR_PRODUTO',
      () async {
        final criado = await repository.criarProduto(
          produto,
        );

        _produtos = [
          ..._produtos,
          criado,
        ]..sort(_compararProdutos);

        _produtoSelecionado = criado;
        sucesso = true;

        debugPrint(
          '[ProdutoProvider] CRIAR_PRODUTO_SUCESSO — id=${criado.idProduto}',
        );
      },
    );

    return sucesso;
  }

Future<bool> editarProduto(
  int idProduto,
  ProdutoModel produto, {
  bool enviarCategorias = true,
  bool enviarImagens = true,
  bool enviarIngredientes = true,
}) async {
    var sucesso = false;

    await _executar(
      'EDITAR_PRODUTO',
      () async {
final editado = await repository.editarProduto(
  idProduto,
  produto,
  enviarCategorias: enviarCategorias,
  enviarImagens: enviarImagens,
  enviarIngredientes: enviarIngredientes,
);

        _actualizarProdutoNaLista(editado);

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = editado;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] EDITAR_PRODUTO_SUCESSO — '
      'id=$idProduto enviarCategorias=$enviarCategorias '
'enviarImagens=$enviarImagens '
'enviarIngredientes=$enviarIngredientes',
        );
      },
    );

    return sucesso;
  }



  Future<bool> alterarDestaqueProduto(
    int idProduto,
    bool destaque,
  ) async {
    var sucesso = false;

    await _executar(
      'ALTERAR_DESTAQUE_PRODUTO',
      () async {
        final produto = await repository.alterarDestaqueProduto(
          idProduto,
          destaque,
        );

        _actualizarProdutoNaLista(produto);

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = produto;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] ALTERAR_DESTAQUE_PRODUTO_SUCESSO — '
          'id=$idProduto destaque=${produto.destaque}',
        );
      },
    );

    return sucesso;
  }

Future<bool> alterarEstadoProduto(
  int idProduto,
  bool ativo,
) async {
  var sucesso = false;

  await _executar(
    'ALTERAR_ESTADO_PRODUTO',
    () async {
      final produto = await repository.alterarEstadoProduto(
        idProduto,
        ativo,
      );

      _actualizarProdutoNaLista(produto);

      if (_produtoSelecionado?.idProduto == idProduto) {
        _produtoSelecionado = produto;
      }

      sucesso = true;

      debugPrint(
        '[ProdutoProvider] ALTERAR_ESTADO_PRODUTO_SUCESSO — '
        'id=$idProduto '
        'ativo=${produto.ativo} '
        'disponivelCalculado=${produto.disponivelCalculado} '
        'destaque=${produto.destaque}',
      );
    },
  );

  return sucesso;
}

Future<bool> desativarProduto(
  int idProduto,
) async {
  var sucesso = false;

  await _executar(
    'DESATIVAR_PRODUTO',
    () async {
      await repository.desativarProduto(
        idProduto,
      );

      _produtos = _produtos
          .map((produto) {
            if (produto.idProduto != idProduto) {
              return produto;
            }

            return produto.copyWith(
              ativo: false,
              disponivelCalculado: false,
              quantidadeDisponivelCalculada: 0.0,
              motivoIndisponibilidade: 'Produto inativo.',
            );
          })
          .toList()
        ..sort(_compararProdutos);

      if (_produtoSelecionado?.idProduto == idProduto) {
        _produtoSelecionado = _produtoSelecionado?.copyWith(
          ativo: false,
          disponivelCalculado: false,
          quantidadeDisponivelCalculada: 0.0,
          motivoIndisponibilidade: 'Produto inativo.',
        );
      }

      sucesso = true;

      debugPrint(
        '[ProdutoProvider] DESATIVAR_PRODUTO_SUCESSO — '
        'id=$idProduto',
      );
    },
  );

  return sucesso;
}

  // ─────────────────────────────────────────────────────────────
  // IMAGENS DO PRODUTO
  // ─────────────────────────────────────────────────────────────

  Future<bool> adicionarImagemAoProduto(
    int idProduto,
    ProdutoImagemModel imagem,
  ) async {
    var sucesso = false;

    await _executar(
      'ADICIONAR_IMAGEM_PRODUTO',
      () async {
        final produto = await repository.adicionarImagemAoProduto(
          idProduto,
          imagem,
        );

        _actualizarProdutoNaLista(produto);

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = produto;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] ADICIONAR_IMAGEM_PRODUTO_SUCESSO — '
          'idProduto=$idProduto totalImagens=${produto.imagens.length}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> definirImagemPrincipal(
    int idProduto,
    int idProdutoImagem,
  ) async {
    var sucesso = false;

    await _executar(
      'DEFINIR_IMAGEM_PRINCIPAL',
      () async {
        final produto = await repository.definirImagemPrincipal(
          idProduto,
          idProdutoImagem,
        );

        _actualizarProdutoNaLista(produto);

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = produto;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] DEFINIR_IMAGEM_PRINCIPAL_SUCESSO — '
          'idProduto=$idProduto idImagem=$idProdutoImagem',
        );
      },
    );

    return sucesso;
  }

  Future<bool> removerImagemDoProduto(
    int idProduto,
    int idProdutoImagem,
  ) async {
    var sucesso = false;

    await _executar(
      'REMOVER_IMAGEM_PRODUTO',
      () async {
        final produto = await repository.removerImagemDoProduto(
          idProduto,
          idProdutoImagem,
        );

        _actualizarProdutoNaLista(produto);

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = produto;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] REMOVER_IMAGEM_PRODUTO_SUCESSO — '
          'idProduto=$idProduto idImagem=$idProdutoImagem '
          'totalImagens=${produto.imagens.length}',
        );
      },
    );

    return sucesso;
  }

  // ─────────────────────────────────────────────────────────────
  // INGREDIENTES DO PRODUTO
  // ─────────────────────────────────────────────────────────────

  Future<bool> adicionarIngredienteAoProduto(
    int idProduto,
    ProdutoIngredienteModel ingrediente,
  ) async {
    var sucesso = false;

    await _executar(
      'ADICIONAR_INGREDIENTE_PRODUTO',
      () async {
        final produto = await repository.adicionarIngredienteAoProduto(
          idProduto,
          ingrediente,
        );

        _actualizarProdutoNaLista(produto);

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = produto;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] ADICIONAR_INGREDIENTE_PRODUTO_SUCESSO — '
          'idProduto=$idProduto totalIngredientes=${produto.ingredientes.length}',
        );
      },
    );

    return sucesso;
  }

  Future<bool> removerIngredienteDoProduto(
    int idProduto,
    int idIngrediente,
  ) async {
    var sucesso = false;

    await _executar(
      'REMOVER_INGREDIENTE_PRODUTO',
      () async {
        final produto = await repository.removerIngredienteDoProduto(
          idProduto,
          idIngrediente,
        );

        _actualizarProdutoNaLista(produto);

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = produto;
        }

        sucesso = true;

        debugPrint(
          '[ProdutoProvider] REMOVER_INGREDIENTE_PRODUTO_SUCESSO — '
          'idProduto=$idProduto idIngrediente=$idIngrediente '
          'totalIngredientes=${produto.ingredientes.length}',
        );
      },
    );

    return sucesso;
  }

  Future<List<ProdutoImagemModel>> listarImagensDoProduto(
    int idProduto,
  ) async {
    List<ProdutoImagemModel> imagens = [];

    await _executar(
      'LISTAR_IMAGENS_PRODUTO',
      () async {
        imagens = await repository.listarImagensDoProduto(
          idProduto,
        );

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = _produtoSelecionado?.copyWith(
            imagens: imagens,
          );

          _actualizarProdutoNaLista(_produtoSelecionado!);
        }

        debugPrint(
          '[ProdutoProvider] LISTAR_IMAGENS_PRODUTO_SUCESSO — '
          'idProduto=$idProduto total=${imagens.length}',
        );
      },
    );

    return imagens;
  }

  Future<List<ProdutoIngredienteModel>> listarIngredientesDoProduto(
    int idProduto,
  ) async {
    List<ProdutoIngredienteModel> ingredientes = [];

    await _executar(
      'LISTAR_INGREDIENTES_PRODUTO',
      () async {
        ingredientes = await repository.listarIngredientesDoProduto(
          idProduto,
        );

        if (_produtoSelecionado?.idProduto == idProduto) {
          _produtoSelecionado = _produtoSelecionado?.copyWith(
            ingredientes: ingredientes,
          );

          _actualizarProdutoNaLista(_produtoSelecionado!);
        }

        debugPrint(
          '[ProdutoProvider] LISTAR_INGREDIENTES_PRODUTO_SUCESSO — '
          'idProduto=$idProduto total=${ingredientes.length}',
        );
      },
    );

    return ingredientes;
  }

  // ─────────────────────────────────────────────────────────────
  // SELEÇÃO / UTILITÁRIOS
  // ─────────────────────────────────────────────────────────────

  void selecionarProduto(
    ProdutoModel? produto,
  ) {
    _produtoSelecionado = produto;

    debugPrint(
      '[ProdutoProvider] SELECIONAR_PRODUTO — id=${produto?.idProduto}',
    );

    notifyListeners();
  }

  void selecionarCategoria(
    CategoriaProdutoModel? categoria,
  ) {
    _categoriaSelecionada = categoria;

    debugPrint(
      '[ProdutoProvider] SELECIONAR_CATEGORIA — id=${categoria?.idCategoriaProduto}',
    );

    notifyListeners();
  }

  void limparSelecao() {
    _produtoSelecionado = null;
    _categoriaSelecionada = null;

    debugPrint(
      '[ProdutoProvider] LIMPAR_SELECAO',
    );

    notifyListeners();
  }

  void limparErro() {
    _erro = null;

    debugPrint(
      '[ProdutoProvider] LIMPAR_ERRO',
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
      '[ProdutoProvider] ${acao}_INICIO',
    );

    try {
      await operacao();
    } catch (e, stackTrace) {
      _erro = _normalizarErro(e);

      debugPrint(
        '[ProdutoProvider] ${acao}_ERRO — $_erro',
      );

      debugPrint(
        stackTrace.toString(),
      );
    } finally {
      _carregando = false;

      debugPrint(
        '[ProdutoProvider] ${acao}_FIM',
      );

      notifyListeners();
    }
  }

  void _actualizarCategoriaNaLista(
    CategoriaProdutoModel categoria,
  ) {
    final id = categoria.idCategoriaProduto;

    if (id == null) {
      return;
    }

    final index = _categorias.indexWhere(
      (item) => item.idCategoriaProduto == id,
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

  void _actualizarProdutoNaLista(
    ProdutoModel produto,
  ) {
    final id = produto.idProduto;

    if (id == null) {
      return;
    }

    final index = _produtos.indexWhere(
      (item) => item.idProduto == id,
    );

    if (index >= 0) {
      final novaLista = [..._produtos];
      novaLista[index] = produto;
      _produtos = novaLista..sort(_compararProdutos);
    } else {
      _produtos = [
        ..._produtos,
        produto,
      ]..sort(_compararProdutos);
    }
  }

  int _compararCategorias(
    CategoriaProdutoModel a,
    CategoriaProdutoModel b,
  ) {
    final ordem = a.ordem.compareTo(b.ordem);

    if (ordem != 0) {
      return ordem;
    }

    return a.nome.toLowerCase().compareTo(
          b.nome.toLowerCase(),
        );
  }

  int _compararProdutos(
    ProdutoModel a,
    ProdutoModel b,
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