import '../models/movimento_estoque_model.dart';
import '../services/movimento_estoque_service.dart';

class MovimentoEstoqueRepository {
  final MovimentoEstoqueService service;

  MovimentoEstoqueRepository({
    required this.service,
  });

  Future<List<MovimentoEstoqueModel>> listarMovimentos({
    TipoItemEstoqueModel? tipoItem,
    TipoMovimentoEstoqueModel? tipoMovimento,
    int? idProduto,
    int? idIngrediente,
    int? idUsuario,
    DateTime? inicio,
    DateTime? fim,
  }) async {
    if ((inicio == null && fim != null) || (inicio != null && fim == null)) {
      throw Exception('Informe a data inicial e final para filtrar por período.');
    }

    if (inicio != null && fim != null && inicio.isAfter(fim)) {
      throw Exception('A data inicial não pode ser posterior à data final.');
    }

    return service.listarMovimentos(
      tipoItem: tipoItem,
      tipoMovimento: tipoMovimento,
      idProduto: idProduto,
      idIngrediente: idIngrediente,
      idUsuario: idUsuario,
      inicio: inicio,
      fim: fim,
    );
  }

  Future<MovimentoEstoqueModel> buscarPorId(
    int idMovimentoEstoque,
  ) async {
    if (idMovimentoEstoque <= 0) {
      throw Exception('ID do movimento de estoque inválido.');
    }

    return service.buscarPorId(idMovimentoEstoque);
  }

  Future<MovimentoEstoqueModel> movimentarEstoque(
    MovimentoEstoqueModel movimento,
  ) async {
    final normalizado = _normalizarMovimento(movimento);

    return service.movimentarEstoque(normalizado);
  }

  MovimentoEstoqueModel _normalizarMovimento(
    MovimentoEstoqueModel movimento,
  ) {
    final motivo = movimento.motivo.trim();

    if (motivo.isEmpty) {
      throw Exception('O motivo do movimento é obrigatório.');
    }

    if (movimento.idUsuario <= 0) {
      throw Exception('O usuário responsável é obrigatório.');
    }

    if (movimento.quantidadeMovimentada <= 0) {
      throw Exception('A quantidade movimentada deve ser maior que zero.');
    }

    switch (movimento.tipoItem) {
      case TipoItemEstoqueModel.produto:
        if (movimento.idProduto == null || movimento.idProduto! <= 0) {
          throw Exception('Informe o produto a movimentar.');
        }

        if (movimento.idIngrediente != null) {
          throw Exception(
            'Movimento de produto não deve informar ingrediente.',
          );
        }

        break;

      case TipoItemEstoqueModel.ingrediente:
        if (movimento.idIngrediente == null || movimento.idIngrediente! <= 0) {
          throw Exception('Informe o ingrediente a movimentar.');
        }

        if (movimento.idProduto != null) {
          throw Exception(
            'Movimento de ingrediente não deve informar produto.',
          );
        }

        break;
    }

    return movimento.copyWith(
      motivo: motivo,
      observacoes: _nullIfBlank(movimento.observacoes),
    );
  }

  String? _nullIfBlank(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) return null;

    return text;
  }
}