class CategoriaIngredienteModel {
  final int? idCategoriaIngrediente;
  final String nome;
  final String? descricao;
  final int ordem;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoriaIngredienteModel({
    this.idCategoriaIngrediente,
    required this.nome,
    this.descricao,
    this.ordem = 0,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoriaIngredienteModel.fromJson(Map<String, dynamic> json) {
    return CategoriaIngredienteModel(
      idCategoriaIngrediente: _parseIntOpt(json['idCategoriaIngrediente']),
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

  CategoriaIngredienteModel copyWith({
    int? idCategoriaIngrediente,
    String? nome,
    String? descricao,
    int? ordem,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoriaIngredienteModel(
      idCategoriaIngrediente:
          idCategoriaIngrediente ?? this.idCategoriaIngrediente,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ordem: ordem ?? this.ordem,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CategoriaIngredienteResumoModel {
  final int? idCategoriaIngrediente;
  final String nome;
  final bool principal;
  final int ordem;

  const CategoriaIngredienteResumoModel({
    this.idCategoriaIngrediente,
    required this.nome,
    this.principal = false,
    this.ordem = 0,
  });

  factory CategoriaIngredienteResumoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaIngredienteResumoModel(
      idCategoriaIngrediente: _parseIntOpt(json['idCategoriaIngrediente']),
      nome: _parseString(json['nome']),
      principal: _parseBool(json['principal'], defaultValue: false),
      ordem: _parseInt(json['ordem'], defaultValue: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategoriaIngrediente': idCategoriaIngrediente,
      'nome': nome.trim(),
      'principal': principal,
      'ordem': ordem,
    };
  }

  CategoriaIngredienteResumoModel copyWith({
    int? idCategoriaIngrediente,
    String? nome,
    bool? principal,
    int? ordem,
  }) {
    return CategoriaIngredienteResumoModel(
      idCategoriaIngrediente:
          idCategoriaIngrediente ?? this.idCategoriaIngrediente,
      nome: nome ?? this.nome,
      principal: principal ?? this.principal,
      ordem: ordem ?? this.ordem,
    );
  }
}

class IngredienteImagemModel {
  final int? idIngredienteImagem;
  final String imagemUrl;
  final String? legenda;
  final bool principal;
  final int ordem;
  final DateTime? createdAt;

  const IngredienteImagemModel({
    this.idIngredienteImagem,
    required this.imagemUrl,
    this.legenda,
    this.principal = false,
    this.ordem = 0,
    this.createdAt,
  });

  factory IngredienteImagemModel.fromJson(Map<String, dynamic> json) {
    return IngredienteImagemModel(
      idIngredienteImagem: _parseIntOpt(json['idIngredienteImagem']),
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

  IngredienteImagemModel copyWith({
    int? idIngredienteImagem,
    String? imagemUrl,
    String? legenda,
    bool? principal,
    int? ordem,
    DateTime? createdAt,
  }) {
    return IngredienteImagemModel(
      idIngredienteImagem: idIngredienteImagem ?? this.idIngredienteImagem,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      legenda: legenda ?? this.legenda,
      principal: principal ?? this.principal,
      ordem: ordem ?? this.ordem,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class IngredienteModel {
  final int? idIngrediente;
final List<CategoriaIngredienteResumoModel> categoriasIngrediente;
  final String nome;
  final String? descricao;
  final double precoAdicional;
  final bool controlaEstoque;
  final double? quantidadeEstoque;
  final bool disponivel;
  final bool ativo;
  final String? imagemPrincipalUrl;
  final List<IngredienteImagemModel> imagens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IngredienteModel({
    this.idIngrediente,
this.categoriasIngrediente = const [],
    required this.nome,
    this.descricao,
    this.precoAdicional = 0.0,
    this.controlaEstoque = false,
    this.quantidadeEstoque,
    this.disponivel = true,
    this.ativo = true,
    this.imagemPrincipalUrl,
    this.imagens = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory IngredienteModel.fromJson(Map<String, dynamic> json) {
    return IngredienteModel(
      idIngrediente: _parseIntOpt(json['idIngrediente']),
      categoriasIngrediente: _parseCategoriasIngrediente(
  json['categoriasIngrediente'],
  fallbackCategoriaUnica: json['categoriaIngrediente'],
),
      nome: _parseString(json['nome']),
      descricao: _parseStringOpt(json['descricao']),
      precoAdicional: _parseDouble(json['precoAdicional']),
      controlaEstoque: _parseBool(
        json['controlaEstoque'],
        defaultValue: false,
      ),
      quantidadeEstoque: _parseDoubleOpt(json['quantidadeEstoque']),
      disponivel: _parseBool(json['disponivel'], defaultValue: true),
      ativo: _parseBool(json['ativo'], defaultValue: true),
      imagemPrincipalUrl: _parseStringOpt(json['imagemPrincipalUrl']),
      imagens: _parseImagens(json['imagens']),
      createdAt: _parseDateTimeOpt(json['createdAt']),
      updatedAt: _parseDateTimeOpt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({
  bool enviarCategorias = true,
  bool enviarImagens = true,
}) {
  return {
    if (enviarCategorias)
      'idCategoriasIngrediente': categoriasIngrediente
          .map((categoria) => categoria.idCategoriaIngrediente)
          .whereType<int>()
          .toList(),
    'nome': nome.trim(),
    'descricao': _nullIfBlank(descricao),
    'precoAdicional': precoAdicional,
    'controlaEstoque': controlaEstoque,
    'quantidadeEstoque': controlaEstoque ? quantidadeEstoque : null,
    'disponivel': disponivel,
    'ativo': ativo,
    if (enviarImagens)
      'imagens': imagens.map((imagem) => imagem.toJson()).toList(),
  };
}

  IngredienteModel copyWith({
    int? idIngrediente,
List<CategoriaIngredienteResumoModel>? categoriasIngrediente,
    String? nome,
    String? descricao,
    double? precoAdicional,
    bool? controlaEstoque,
    double? quantidadeEstoque,
    bool? disponivel,
    bool? ativo,
    String? imagemPrincipalUrl,
    List<IngredienteImagemModel>? imagens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IngredienteModel(
      idIngrediente: idIngrediente ?? this.idIngrediente,
categoriasIngrediente:
    categoriasIngrediente ?? this.categoriasIngrediente,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      precoAdicional: precoAdicional ?? this.precoAdicional,
      controlaEstoque: controlaEstoque ?? this.controlaEstoque,
      quantidadeEstoque: quantidadeEstoque ?? this.quantidadeEstoque,
      disponivel: disponivel ?? this.disponivel,
      ativo: ativo ?? this.ativo,
      imagemPrincipalUrl: imagemPrincipalUrl ?? this.imagemPrincipalUrl,
      imagens: imagens ?? this.imagens,
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

List<CategoriaIngredienteResumoModel> _parseCategoriasIngrediente(
  dynamic value, {
  dynamic fallbackCategoriaUnica,
}) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map(
          (item) => CategoriaIngredienteResumoModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  if (fallbackCategoriaUnica is Map) {
    return [
      CategoriaIngredienteResumoModel.fromJson(
        Map<String, dynamic>.from(fallbackCategoriaUnica),
      ),
    ];
  }

  return [];
}

List<IngredienteImagemModel> _parseImagens(dynamic value) {
  if (value == null || value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map(
        (item) => IngredienteImagemModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList();
}