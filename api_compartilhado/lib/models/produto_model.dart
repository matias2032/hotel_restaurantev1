class CategoriaProdutoModel {
  final int? idCategoriaProduto;
  final String nome;
  final String? descricao;
  final int ordem;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoriaProdutoModel({
    this.idCategoriaProduto,
    required this.nome,
    this.descricao,
    this.ordem = 0,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoriaProdutoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaProdutoModel(
      idCategoriaProduto: _parseIntOpt(json['idCategoriaProduto']),
      nome: _parseString(json['nome']),
      descricao: _parseStringOpt(json['descricao']),
      ordem: _parseInt(json['ordem'], defaultValue: 0),
      ativo: _parseBool(json['ativo'], defaultValue: true),
      createdAt: _parseDateTimeOpt(json['createdAt']),
      updatedAt: _parseDateTimeOpt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome.trim(),
      'descricao': _nullIfBlank(descricao),
      'ordem': ordem,
      'ativo': ativo,
    };
  }

  CategoriaProdutoModel copyWith({
    int? idCategoriaProduto,
    String? nome,
    String? descricao,
    int? ordem,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoriaProdutoModel(
      idCategoriaProduto: idCategoriaProduto ?? this.idCategoriaProduto,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ordem: ordem ?? this.ordem,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CategoriaProdutoResumoModel {
  final int? idCategoriaProduto;
  final String nome;

  const CategoriaProdutoResumoModel({
    this.idCategoriaProduto,
    required this.nome,
  });

  factory CategoriaProdutoResumoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaProdutoResumoModel(
      idCategoriaProduto: _parseIntOpt(json['idCategoriaProduto']),
      nome: _parseString(json['nome']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategoriaProduto': idCategoriaProduto,
      'nome': nome.trim(),
    };
  }

  CategoriaProdutoResumoModel copyWith({
    int? idCategoriaProduto,
    String? nome,
  }) {
    return CategoriaProdutoResumoModel(
      idCategoriaProduto: idCategoriaProduto ?? this.idCategoriaProduto,
      nome: nome ?? this.nome,
    );
  }
}

class ProdutoImagemModel {
  final int? idProdutoImagem;
  final String imagemUrl;
  final String? legenda;
  final bool principal;
  final int ordem;
  final DateTime? createdAt;

  const ProdutoImagemModel({
    this.idProdutoImagem,
    required this.imagemUrl,
    this.legenda,
    this.principal = false,
    this.ordem = 0,
    this.createdAt,
  });

  factory ProdutoImagemModel.fromJson(Map<String, dynamic> json) {
    return ProdutoImagemModel(
      idProdutoImagem: _parseIntOpt(json['idProdutoImagem']),
      imagemUrl: _parseString(json['imagemUrl']),
      legenda: _parseStringOpt(json['legenda']),
      principal: _parseBool(json['principal'], defaultValue: false),
      ordem: _parseInt(json['ordem'], defaultValue: 0),
      createdAt: _parseDateTimeOpt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagemUrl': imagemUrl.trim(),
      'legenda': _nullIfBlank(legenda),
      'principal': principal,
      'ordem': ordem,
    };
  }

  ProdutoImagemModel copyWith({
    int? idProdutoImagem,
    String? imagemUrl,
    String? legenda,
    bool? principal,
    int? ordem,
    DateTime? createdAt,
  }) {
    return ProdutoImagemModel(
      idProdutoImagem: idProdutoImagem ?? this.idProdutoImagem,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      legenda: legenda ?? this.legenda,
      principal: principal ?? this.principal,
      ordem: ordem ?? this.ordem,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProdutoIngredienteModel {
  final int? idIngrediente;
  final String nomeIngrediente;
  final bool obrigatorio;
  final bool removivel;
  final bool permiteExtra;
  final double quantidadePadrao;

  const ProdutoIngredienteModel({
    required this.idIngrediente,
    required this.nomeIngrediente,
    this.obrigatorio = false,
    this.removivel = true,
    this.permiteExtra = true,
    this.quantidadePadrao = 1.0,
  });

  factory ProdutoIngredienteModel.fromJson(Map<String, dynamic> json) {
    return ProdutoIngredienteModel(
      idIngrediente: _parseIntOpt(json['idIngrediente']),
      nomeIngrediente: _parseString(
        json['nomeIngrediente'] ?? json['ingredienteNome'] ?? json['nome'],
      ),
      obrigatorio: _parseBool(json['obrigatorio'], defaultValue: false),
      removivel: _parseBool(json['removivel'], defaultValue: true),
      permiteExtra: _parseBool(json['permiteExtra'], defaultValue: true),
      quantidadePadrao: _parseDouble(
        json['quantidadePadrao'],
        defaultValue: 1.0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idIngrediente': idIngrediente,
      'obrigatorio': obrigatorio,
      'removivel': removivel,
      'permiteExtra': permiteExtra,
      'quantidadePadrao': quantidadePadrao,
    };
  }

  ProdutoIngredienteModel copyWith({
    int? idIngrediente,
    String? nomeIngrediente,
    bool? obrigatorio,
    bool? removivel,
    bool? permiteExtra,
    double? quantidadePadrao,
  }) {
    return ProdutoIngredienteModel(
      idIngrediente: idIngrediente ?? this.idIngrediente,
      nomeIngrediente: nomeIngrediente ?? this.nomeIngrediente,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      removivel: removivel ?? this.removivel,
      permiteExtra: permiteExtra ?? this.permiteExtra,
      quantidadePadrao: quantidadePadrao ?? this.quantidadePadrao,
    );
  }
}

class ProdutoModel {
  final int? idProduto;
  final CategoriaProdutoResumoModel? categoriaProduto;
  final String nome;
  final String? descricao;
  final double preco;
  final String? imagemPrincipalUrl;
  final bool controlaEstoque;
  final double? quantidadeEstoque;
  final int? tempoPreparoMinutos;
  final bool disponivel;
  final bool destaque;
  final bool ativo;
  final List<ProdutoImagemModel> imagens;
  final List<ProdutoIngredienteModel> ingredientes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProdutoModel({
    this.idProduto,
    this.categoriaProduto,
    required this.nome,
    this.descricao,
    this.preco = 0.0,
    this.imagemPrincipalUrl,
    this.controlaEstoque = false,
    this.quantidadeEstoque,
    this.tempoPreparoMinutos,
    this.disponivel = true,
    this.destaque = false,
    this.ativo = true,
    this.imagens = const [],
    this.ingredientes = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      idProduto: _parseIntOpt(json['idProduto']),
      categoriaProduto: json['categoriaProduto'] is Map<String, dynamic>
          ? CategoriaProdutoResumoModel.fromJson(
              json['categoriaProduto'] as Map<String, dynamic>,
            )
          : null,
      nome: _parseString(json['nome']),
      descricao: _parseStringOpt(json['descricao']),
      preco: _parseDouble(json['preco']),
      imagemPrincipalUrl: _parseStringOpt(json['imagemPrincipalUrl']),
      controlaEstoque: _parseBool(
        json['controlaEstoque'],
        defaultValue: false,
      ),
      quantidadeEstoque: _parseDoubleOpt(json['quantidadeEstoque']),
      tempoPreparoMinutos: _parseIntOpt(json['tempoPreparoMinutos']),
      disponivel: _parseBool(json['disponivel'], defaultValue: true),
      destaque: _parseBool(json['destaque'], defaultValue: false),
      ativo: _parseBool(json['ativo'], defaultValue: true),
      imagens: _parseImagensProduto(json['imagens']),
      ingredientes: _parseIngredientesProduto(json['ingredientes']),
      createdAt: _parseDateTimeOpt(json['createdAt']),
      updatedAt: _parseDateTimeOpt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({
    bool enviarImagens = true,
    bool enviarIngredientes = true,
  }) {
    return {
      'idCategoriaProduto': categoriaProduto?.idCategoriaProduto,
      'nome': nome.trim(),
      'descricao': _nullIfBlank(descricao),
      'preco': preco,
      'imagemPrincipalUrl': _nullIfBlank(imagemPrincipalUrl),
      'controlaEstoque': controlaEstoque,
      'quantidadeEstoque': controlaEstoque ? quantidadeEstoque : null,
      'tempoPreparoMinutos': tempoPreparoMinutos,
      'disponivel': disponivel,
      'destaque': destaque,
      'ativo': ativo,
      if (enviarImagens)
        'imagens': imagens.map((imagem) => imagem.toJson()).toList(),
      if (enviarIngredientes)
        'ingredientes': ingredientes
            .map((ingrediente) => ingrediente.toJson())
            .toList(),
    };
  }

  ProdutoModel copyWith({
    int? idProduto,
    CategoriaProdutoResumoModel? categoriaProduto,
    String? nome,
    String? descricao,
    double? preco,
    String? imagemPrincipalUrl,
    bool? controlaEstoque,
    double? quantidadeEstoque,
    int? tempoPreparoMinutos,
    bool? disponivel,
    bool? destaque,
    bool? ativo,
    List<ProdutoImagemModel>? imagens,
    List<ProdutoIngredienteModel>? ingredientes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProdutoModel(
      idProduto: idProduto ?? this.idProduto,
      categoriaProduto: categoriaProduto ?? this.categoriaProduto,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      imagemPrincipalUrl: imagemPrincipalUrl ?? this.imagemPrincipalUrl,
      controlaEstoque: controlaEstoque ?? this.controlaEstoque,
      quantidadeEstoque: quantidadeEstoque ?? this.quantidadeEstoque,
      tempoPreparoMinutos:
          tempoPreparoMinutos ?? this.tempoPreparoMinutos,
      disponivel: disponivel ?? this.disponivel,
      destaque: destaque ?? this.destaque,
      ativo: ativo ?? this.ativo,
      imagens: imagens ?? this.imagens,
      ingredientes: ingredientes ?? this.ingredientes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

int? _parseIntOpt(dynamic value) {
  if (value == null) return null;

  if (value is int) return value;

  if (value is double) return value.toInt();

  return int.tryParse(value.toString());
}

int _parseInt(
  dynamic value, {
  int defaultValue = 0,
}) {
  return _parseIntOpt(value) ?? defaultValue;
}

double? _parseDoubleOpt(dynamic value) {
  if (value == null) return null;

  if (value is double) return value;

  if (value is int) return value.toDouble();

  return double.tryParse(value.toString().replaceAll(',', '.'));
}

double _parseDouble(
  dynamic value, {
  double defaultValue = 0.0,
}) {
  return _parseDoubleOpt(value) ?? defaultValue;
}

bool _parseBool(
  dynamic value, {
  bool defaultValue = false,
}) {
  if (value == null) return defaultValue;

  if (value is bool) return value;

  if (value is num) return value == 1;

  final text = value.toString().trim().toLowerCase();

  if (text == 'true' || text == '1' || text == 'sim' || text == 'yes') {
    return true;
  }

  if (text == 'false' || text == '0' || text == 'nao' || text == 'não') {
    return false;
  }

  return defaultValue;
}

String _parseString(dynamic value) {
  if (value == null) return '';

  return value.toString().trim();
}

String? _parseStringOpt(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  return text.isEmpty ? null : text;
}

DateTime? _parseDateTimeOpt(dynamic value) {
  if (value == null) return null;

  return DateTime.tryParse(value.toString());
}

String? _nullIfBlank(String? value) {
  if (value == null) return null;

  final text = value.trim();

  return text.isEmpty ? null : text;
}

List<ProdutoImagemModel> _parseImagensProduto(dynamic value) {
  if (value == null || value is! List) {
    return [];
  }

  return value
      .whereType<Map<String, dynamic>>()
      .map(ProdutoImagemModel.fromJson)
      .toList();
}

List<ProdutoIngredienteModel> _parseIngredientesProduto(dynamic value) {
  if (value == null || value is! List) {
    return [];
  }

  return value
      .whereType<Map<String, dynamic>>()
      .map(ProdutoIngredienteModel.fromJson)
      .toList();
}