import 'package:flutter/foundation.dart';

import '../models/movimento_estoque_model.dart';
import '../repository/movimento_estoque_repository.dart';

class MovimentoEstoqueProvider extends ChangeNotifier {
  final MovimentoEstoqueRepository repository;

  MovimentoEstoqueProvider({
    required this.repository,
  });

  List<MovimentoEstoqueModel> _movimentos = [];
  MovimentoEstoqueModel? _movimentoSelecionado;

  bool _carregando = false;
  String? _erro;

  List<MovimentoEstoqueModel> get movimentos => List.unmodifiable(_movimentos);

  MovimentoEstoqueModel? get movimentoSelecionado => _movimentoSelecionado;

  bool get carregando => _carregando;

  String? get erro => _erro;

  bool get temErro => _erro != null;

  Future<void> carregarMovimentos({
    TipoItemEstoqueModel? tipoItem,
    TipoMovimentoEstoqueModel? tipoMovimento,
    int? idProduto,
    int? idIngrediente,
    int? idUsuario,
    DateTime? inicio,
    DateTime? fim,
  }) async {
    await _executar('Carregar movimentos de estoque', () async {
      _movimentos = await repository.listarMovimentos(
        tipoItem: tipoItem,
        tipoMovimento: tipoMovimento,
        idProduto: idProduto,
        idIngrediente: idIngrediente,
        idUsuario: idUsuario,
        inicio: inicio,
        fim: fim,
      );
    });
  }

  Future<void> buscarMovimentoPorId(
    int idMovimentoEstoque,
  ) async {
    await _executar('Buscar movimento de estoque', () async {
      _movimentoSelecionado = await repository.buscarPorId(
        idMovimentoEstoque,
      );
    });
  }

  Future<MovimentoEstoqueModel?> movimentarEstoque(
    MovimentoEstoqueModel movimento,
  ) async {
    MovimentoEstoqueModel? movimentoCriado;

    await _executar('Movimentar estoque', () async {
      movimentoCriado = await repository.movimentarEstoque(movimento);

      _movimentos = [
        movimentoCriado!,
        ..._movimentos.where(
          (item) =>
              item.idMovimentoEstoque != movimentoCriado!.idMovimentoEstoque,
        ),
      ];

      _movimentoSelecionado = movimentoCriado;
    });

    return movimentoCriado;
  }

  void limparSelecionado() {
    _movimentoSelecionado = null;
    notifyListeners();
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  Future<void> _executar(
    String acao,
    Future<void> Function() callback,
  ) async {
    _setCarregando(true);
    _erro = null;

    try {
      await callback();
    } catch (e, stackTrace) {
      _erro = e.toString().replaceFirst('Exception: ', '');

      debugPrint('❌ $acao: $_erro');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _setCarregando(false);
    }
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}