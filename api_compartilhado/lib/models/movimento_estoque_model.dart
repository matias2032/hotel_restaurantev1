

enum TipoItemEstoqueModel {
  produto,
  ingrediente;

  String get apiValue {
    return switch (this) {
      TipoItemEstoqueModel.produto => 'PRODUTO',
      TipoItemEstoqueModel.ingrediente => 'INGREDIENTE',
    };
  }

  String get label {
    return switch (this) {
      TipoItemEstoqueModel.produto => 'Produto',
      TipoItemEstoqueModel.ingrediente => 'Ingrediente',
    };
  }

  static TipoItemEstoqueModel? fromJson(dynamic value) {
    final text = value?.toString().trim().toUpperCase();

    return switch (text) {
      'PRODUTO' => TipoItemEstoqueModel.produto,
      'INGREDIENTE' => TipoItemEstoqueModel.ingrediente,
      _ => null,
    };
  }
}

enum TipoMovimentoEstoqueModel {
  entrada,
  saida,
  ajuste,
  perda,
  correcao,
  inventario,
  vencimento,
  outros;

  String get apiValue {
    return switch (this) {
      TipoMovimentoEstoqueModel.entrada => 'ENTRADA',
      TipoMovimentoEstoqueModel.saida => 'SAIDA',
      TipoMovimentoEstoqueModel.ajuste => 'AJUSTE',
      TipoMovimentoEstoqueModel.perda => 'PERDA',
      TipoMovimentoEstoqueModel.correcao => 'CORRECAO',
      TipoMovimentoEstoqueModel.inventario => 'INVENTARIO',
      TipoMovimentoEstoqueModel.vencimento => 'VENCIMENTO',
      TipoMovimentoEstoqueModel.outros => 'OUTROS',
    };
  }

  String get label {
    return switch (this) {
      TipoMovimentoEstoqueModel.entrada => 'Entrada',
      TipoMovimentoEstoqueModel.saida => 'Saída',
      TipoMovimentoEstoqueModel.ajuste => 'Ajuste',
      TipoMovimentoEstoqueModel.perda => 'Perda',
      TipoMovimentoEstoqueModel.correcao => 'Correção',
      TipoMovimentoEstoqueModel.inventario => 'Inventário',
      TipoMovimentoEstoqueModel.vencimento => 'Vencimento',
      TipoMovimentoEstoqueModel.outros => 'Outros',
    };
  }

  bool get defineQuantidadeFinal {
    return switch (this) {
      TipoMovimentoEstoqueModel.ajuste ||
      TipoMovimentoEstoqueModel.correcao ||
      TipoMovimentoEstoqueModel.inventario =>
        true,
      _ => false,
    };
  }

  static TipoMovimentoEstoqueModel? fromJson(dynamic value) {
    final text = value?.toString().trim().toUpperCase();

    return switch (text) {
      'ENTRADA' => TipoMovimentoEstoqueModel.entrada,
      'SAIDA' => TipoMovimentoEstoqueModel.saida,
      'AJUSTE' => TipoMovimentoEstoqueModel.ajuste,
      'PERDA' => TipoMovimentoEstoqueModel.perda,
      'CORRECAO' => TipoMovimentoEstoqueModel.correcao,
      'INVENTARIO' => TipoMovimentoEstoqueModel.inventario,
      'VENCIMENTO' => TipoMovimentoEstoqueModel.vencimento,
      'OUTROS' => TipoMovimentoEstoqueModel.outros,
      _ => null,
    };
  }
}

enum OrigemMovimentoEstoqueModel {
  manual;

  String get apiValue {
    return switch (this) {
      OrigemMovimentoEstoqueModel.manual => 'MANUAL',
    };
  }

  String get label {
    return switch (this) {
      OrigemMovimentoEstoqueModel.manual => 'Manual',
    };
  }

  static OrigemMovimentoEstoqueModel? fromJson(dynamic value) {
    final text = value?.toString().trim().toUpperCase();

    return switch (text) {
      'MANUAL' => OrigemMovimentoEstoqueModel.manual,
      _ => null,
    };
  }
}

class MovimentoEstoqueModel {
  final int? idMovimentoEstoque;

  final TipoItemEstoqueModel tipoItem;

  final int? idProduto;
  final String? nomeProduto;

  final int? idIngrediente;
  final String? nomeIngrediente;

  final TipoMovimentoEstoqueModel tipoMovimento;

  final String motivo;
  final String? observacoes;

  final double quantidadeMovimentada;
  final double? quantidadeAnterior;
  final double? quantidadePosterior;

  final int idUsuario;
  final String? nomeUsuario;
  final String? apelidoUsuario;
  final String? nomeCompletoUsuario;

  final OrigemMovimentoEstoqueModel? origem;

  final DateTime? movimentadoEm;
  final DateTime? createdAt;

  const MovimentoEstoqueModel({
    this.idMovimentoEstoque,
    required this.tipoItem,
    this.idProduto,
    this.nomeProduto,
    this.idIngrediente,
    this.nomeIngrediente,
    required this.tipoMovimento,
    required this.motivo,
    this.observacoes,
    required this.quantidadeMovimentada,
    this.quantidadeAnterior,
    this.quantidadePosterior,
    required this.idUsuario,
    this.nomeUsuario,
    this.apelidoUsuario,
    this.nomeCompletoUsuario,
    this.origem,
    this.movimentadoEm,
    this.createdAt,
  });

  factory MovimentoEstoqueModel.fromJson(Map<String, dynamic> json) {
    return MovimentoEstoqueModel(
      idMovimentoEstoque: _parseIntOpt(json['idMovimentoEstoque']),
      tipoItem: TipoItemEstoqueModel.fromJson(json['tipoItem']) ??
          TipoItemEstoqueModel.produto,
      idProduto: _parseIntOpt(json['idProduto']),
      nomeProduto: _parseStringOpt(json['nomeProduto']),
      idIngrediente: _parseIntOpt(json['idIngrediente']),
      nomeIngrediente: _parseStringOpt(json['nomeIngrediente']),
      tipoMovimento:
          TipoMovimentoEstoqueModel.fromJson(json['tipoMovimento']) ??
              TipoMovimentoEstoqueModel.entrada,
      motivo: _parseStringOpt(json['motivo']) ?? '',
      observacoes: _parseStringOpt(json['observacoes']),
      quantidadeMovimentada:
          _parseDoubleOpt(json['quantidadeMovimentada']) ?? 0.0,
      quantidadeAnterior: _parseDoubleOpt(json['quantidadeAnterior']),
      quantidadePosterior: _parseDoubleOpt(json['quantidadePosterior']),
      idUsuario: _parseIntOpt(json['idUsuario']) ?? 0,
      nomeUsuario: _parseStringOpt(json['nomeUsuario']),
      apelidoUsuario: _parseStringOpt(json['apelidoUsuario']),
      nomeCompletoUsuario: _parseStringOpt(json['nomeCompletoUsuario']),
      origem: OrigemMovimentoEstoqueModel.fromJson(json['origem']),
      movimentadoEm: _parseDateTimeOpt(json['movimentadoEm']),
      createdAt: _parseDateTimeOpt(json['createdAt']),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'tipoItem': tipoItem.apiValue,
      'idProduto': idProduto,
      'idIngrediente': idIngrediente,
      'tipoMovimento': tipoMovimento.apiValue,
      'motivo': motivo.trim(),
      'observacoes': _nullIfBlank(observacoes),
      'quantidadeMovimentada': quantidadeMovimentada,
      'idUsuario': idUsuario,
    };
  }

  MovimentoEstoqueModel copyWith({
    int? idMovimentoEstoque,
    TipoItemEstoqueModel? tipoItem,
    int? idProduto,
    String? nomeProduto,
    int? idIngrediente,
    String? nomeIngrediente,
    TipoMovimentoEstoqueModel? tipoMovimento,
    String? motivo,
    String? observacoes,
    double? quantidadeMovimentada,
    double? quantidadeAnterior,
    double? quantidadePosterior,
    int? idUsuario,
    String? nomeUsuario,
    String? apelidoUsuario,
    String? nomeCompletoUsuario,
    OrigemMovimentoEstoqueModel? origem,
    DateTime? movimentadoEm,
    DateTime? createdAt,
  }) {
    return MovimentoEstoqueModel(
      idMovimentoEstoque: idMovimentoEstoque ?? this.idMovimentoEstoque,
      tipoItem: tipoItem ?? this.tipoItem,
      idProduto: idProduto ?? this.idProduto,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      idIngrediente: idIngrediente ?? this.idIngrediente,
      nomeIngrediente: nomeIngrediente ?? this.nomeIngrediente,
      tipoMovimento: tipoMovimento ?? this.tipoMovimento,
      motivo: motivo ?? this.motivo,
      observacoes: observacoes ?? this.observacoes,
      quantidadeMovimentada:
          quantidadeMovimentada ?? this.quantidadeMovimentada,
      quantidadeAnterior: quantidadeAnterior ?? this.quantidadeAnterior,
      quantidadePosterior: quantidadePosterior ?? this.quantidadePosterior,
      idUsuario: idUsuario ?? this.idUsuario,
      nomeUsuario: nomeUsuario ?? this.nomeUsuario,
      apelidoUsuario: apelidoUsuario ?? this.apelidoUsuario,
      nomeCompletoUsuario: nomeCompletoUsuario ?? this.nomeCompletoUsuario,
      origem: origem ?? this.origem,
      movimentadoEm: movimentadoEm ?? this.movimentadoEm,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get nomeItem {
    return switch (tipoItem) {
      TipoItemEstoqueModel.produto =>
        nomeProduto?.trim().isNotEmpty == true ? nomeProduto!.trim() : '-',
      TipoItemEstoqueModel.ingrediente =>
        nomeIngrediente?.trim().isNotEmpty == true
            ? nomeIngrediente!.trim()
            : '-',
    };
  }

  String get operador {
    final completo = nomeCompletoUsuario?.trim();

    if (completo != null && completo.isNotEmpty) {
      return completo;
    }

    final nome = nomeUsuario?.trim() ?? '';
    final apelido = apelidoUsuario?.trim() ?? '';

    final resultado = '$nome $apelido'.trim();

    return resultado.isEmpty ? '-' : resultado;
  }

  bool get isProduto {
    return tipoItem == TipoItemEstoqueModel.produto;
  }

  bool get isIngrediente {
    return tipoItem == TipoItemEstoqueModel.ingrediente;
  }

  static int? _parseIntOpt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double? _parseDoubleOpt(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  static String? _parseStringOpt(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDateTimeOpt(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }

  static String? _nullIfBlank(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) return null;

    return text;
  }
}