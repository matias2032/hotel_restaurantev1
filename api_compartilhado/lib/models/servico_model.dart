class CategoriaServicoModel {
  final int? idCategoriaServico;
  final String nome;
  final String? descricao;
  final int ordem;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoriaServicoModel({
    this.idCategoriaServico,
    required this.nome,
    this.descricao,
    this.ordem = 0,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoriaServicoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaServicoModel(
      idCategoriaServico: _parseIntOpt(json['idCategoriaServico']),
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

  CategoriaServicoModel copyWith({
    int? idCategoriaServico,
    String? nome,
    String? descricao,
    int? ordem,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoriaServicoModel(
      idCategoriaServico: idCategoriaServico ?? this.idCategoriaServico,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ordem: ordem ?? this.ordem,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CategoriaServicoResumoModel {
  final int? idCategoriaServico;
  final String nome;
  final bool principal;
  final int ordem;

  const CategoriaServicoResumoModel({
    this.idCategoriaServico,
    required this.nome,
    this.principal = false,
    this.ordem = 0,
  });

  factory CategoriaServicoResumoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaServicoResumoModel(
      idCategoriaServico: _parseIntOpt(json['idCategoriaServico']),
      nome: _parseString(json['nome']),
      principal: _parseBool(json['principal'], defaultValue: false),
      ordem: _parseInt(json['ordem'], defaultValue: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategoriaServico': idCategoriaServico,
      'nome': nome.trim(),
      'principal': principal,
      'ordem': ordem,
    };
  }

  CategoriaServicoResumoModel copyWith({
    int? idCategoriaServico,
    String? nome,
    bool? principal,
    int? ordem,
  }) {
    return CategoriaServicoResumoModel(
      idCategoriaServico: idCategoriaServico ?? this.idCategoriaServico,
      nome: nome ?? this.nome,
      principal: principal ?? this.principal,
      ordem: ordem ?? this.ordem,
    );
  }
}

class ServicoImagemModel {
  final int? idServicoImagem;
  final String imagemUrl;
  final String? legenda;
  final bool principal;
  final int ordem;
  final DateTime? createdAt;

  const ServicoImagemModel({
    this.idServicoImagem,
    required this.imagemUrl,
    this.legenda,
    this.principal = false,
    this.ordem = 0,
    this.createdAt,
  });

  factory ServicoImagemModel.fromJson(Map<String, dynamic> json) {
    return ServicoImagemModel(
      idServicoImagem: _parseIntOpt(json['idServicoImagem']),
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

  ServicoImagemModel copyWith({
    int? idServicoImagem,
    String? imagemUrl,
    String? legenda,
    bool? principal,
    int? ordem,
    DateTime? createdAt,
  }) {
    return ServicoImagemModel(
      idServicoImagem: idServicoImagem ?? this.idServicoImagem,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      legenda: legenda ?? this.legenda,
      principal: principal ?? this.principal,
      ordem: ordem ?? this.ordem,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ServicoModel {
  final int? idServico;
final List<CategoriaServicoResumoModel> categoriasServico;
  final String nome;
  final String? descricao;
  final double preco;
  final String? imagemPrincipalUrl;
  final bool disponivelCalculado;
final String? motivoIndisponibilidade;
  final bool destaque;
  final bool ativo;
  final List<ServicoImagemModel> imagens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServicoModel({
    this.idServico,
this.categoriasServico = const [],
    required this.nome,
    this.descricao,
    this.preco = 0.0,
    this.imagemPrincipalUrl,
    this.disponivelCalculado = true,
this.motivoIndisponibilidade,
    this.destaque = false,
    this.ativo = true,
    this.imagens = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) {
    return ServicoModel(
      idServico: _parseIntOpt(json['idServico']),
      categoriasServico: _parseCategoriasServico(
  json['categoriasServico'],
  fallbackCategoriaUnica: json['categoriaServico'],
),
      nome: _parseString(json['nome']),
      descricao: _parseStringOpt(json['descricao']),
      preco: _parseDouble(json['preco']),
      imagemPrincipalUrl: _parseStringOpt(json['imagemPrincipalUrl']),
      disponivelCalculado: _parseBool(
  json['disponivelCalculado'],
  defaultValue: true,
),
motivoIndisponibilidade: _parseStringOpt(
  json['motivoIndisponibilidade'],
),
      destaque: _parseBool(json['destaque'], defaultValue: false),
      ativo: _parseBool(json['ativo'], defaultValue: true),
      imagens: _parseImagensServico(json['imagens']),
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
  'idCategoriasServico': categoriasServico
      .map((categoria) => categoria.idCategoriaServico)
      .whereType<int>()
      .toList(),
      'nome': nome.trim(),
      'descricao': _nullIfBlank(descricao),
      'preco': preco,
      'imagemPrincipalUrl': _nullIfBlank(imagemPrincipalUrl),
      
      'destaque': destaque,
      'ativo': ativo,
      if (enviarImagens)
        'imagens': imagens.map((imagem) => imagem.toJson()).toList(),
    };
  }
static const Object _naoAlterar = Object();
  ServicoModel copyWith({
    int? idServico,
List<CategoriaServicoResumoModel>? categoriasServico,
    String? nome,
    String? descricao,
    double? preco,
    String? imagemPrincipalUrl,
    bool? disponivelCalculado,
    Object? motivoIndisponibilidade = _naoAlterar,
    bool? destaque,
    bool? ativo,
    List<ServicoImagemModel>? imagens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServicoModel(
      idServico: idServico ?? this.idServico,
categoriasServico: categoriasServico ?? this.categoriasServico,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      imagemPrincipalUrl: imagemPrincipalUrl ?? this.imagemPrincipalUrl,
     disponivelCalculado:
    disponivelCalculado ??
        this.disponivelCalculado,

motivoIndisponibilidade:
    motivoIndisponibilidade == _naoAlterar
        ? this.motivoIndisponibilidade
        : motivoIndisponibilidade as String?,
      destaque: destaque ?? this.destaque,
      ativo: ativo ?? this.ativo,
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

List<CategoriaServicoResumoModel> _parseCategoriasServico(
  dynamic value, {
  dynamic fallbackCategoriaUnica,
}) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map(
          (item) => CategoriaServicoResumoModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  if (fallbackCategoriaUnica is Map) {
    return [
      CategoriaServicoResumoModel.fromJson(
        Map<String, dynamic>.from(fallbackCategoriaUnica),
      ),
    ];
  }

  return [];
}

List<ServicoImagemModel> _parseImagensServico(dynamic value) {
  if (value == null || value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map(
        (item) => ServicoImagemModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList();
}