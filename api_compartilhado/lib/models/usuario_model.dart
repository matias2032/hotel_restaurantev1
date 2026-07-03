class PerfilModel {
  final int? idPerfil;
  final String nomePerfil;
  final String? descricao;
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PerfilModel({
    this.idPerfil,
    required this.nomePerfil,
    this.descricao,
    this.status = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    return PerfilModel(
      idPerfil: _parseIntOpt(json['idPerfil']),
      nomePerfil: (json['nomePerfil'] ?? '').toString(),
      descricao: _parseStringOpt(json['descricao']),
      status: _parseBool(json['status'], defaultValue: true),
      createdAt: _parseDateOpt(json['createdAt']),
      updatedAt: _parseDateOpt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nomePerfil': nomePerfil,
      'descricao': descricao,
      'status': status,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nomePerfil': nomePerfil,
      'descricao': descricao,
      'status': status,
    };
  }

  PerfilModel copyWith({
    int? idPerfil,
    String? nomePerfil,
    String? descricao,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PerfilModel(
      idPerfil: idPerfil ?? this.idPerfil,
      nomePerfil: nomePerfil ?? this.nomePerfil,
      descricao: descricao ?? this.descricao,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UsuarioModel {
  final int? idUsuario;
  final int? idEstabelecimento;
  final String nome;
  final String? apelido;
  final String nomeCompleto;
  final String? email;
  final String? telefone;
  final bool primeiraSenha;
  final bool status;
  final DateTime? ultimoLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PerfilModel? perfil;

  const UsuarioModel({
    this.idUsuario,
    this.idEstabelecimento,
    required this.nome,
    this.apelido,
    String? nomeCompleto,
    this.email,
    this.telefone,
    this.primeiraSenha = true,
    this.status = true,
    this.ultimoLoginAt,
    this.createdAt,
    this.updatedAt,
    this.perfil,
  }) : nomeCompleto = nomeCompleto ?? '';

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final nome = (json['nome'] ?? '').toString();
    final apelido = _parseStringOpt(json['apelido']);
    final nomeCompletoBackend = _parseStringOpt(json['nomeCompleto']);

    return UsuarioModel(
      idUsuario: _parseIntOpt(json['idUsuario']),
      idEstabelecimento: _parseIntOpt(json['idEstabelecimento']),
      nome: nome,
      apelido: apelido,
      nomeCompleto: nomeCompletoBackend ?? _montarNomeCompleto(nome, apelido),
      email: _parseStringOpt(json['email']),
      telefone: _parseStringOpt(json['telefone']),
      primeiraSenha: _parseBool(json['primeiraSenha'], defaultValue: true),
      status: _parseBool(json['status'], defaultValue: true),
      ultimoLoginAt: _parseDateOpt(json['ultimoLoginAt']),
      createdAt: _parseDateOpt(json['createdAt']),
      updatedAt: _parseDateOpt(json['updatedAt']),
      perfil: json['perfil'] is Map<String, dynamic>
          ? PerfilModel.fromJson(json['perfil'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toCreateJson({
    required int idPerfil,
  }) {
    return {
      'idPerfil': idPerfil,
      'idEstabelecimento': idEstabelecimento,
      'nome': nome,
      'apelido': apelido,
      'email': email,
      'telefone': telefone,
    };
  }

  Map<String, dynamic> toUpdateJson({
    required int idPerfil,
  }) {
    return {
      'idPerfil': idPerfil,
      'idEstabelecimento': idEstabelecimento,
      'nome': nome,
      'apelido': apelido,
      'email': email,
      'telefone': telefone,
      'status': status,
    };
  }

  UsuarioModel copyWith({
    int? idUsuario,
    int? idEstabelecimento,
    String? nome,
    String? apelido,
    String? nomeCompleto,
    String? email,
    String? telefone,
    bool? primeiraSenha,
    bool? status,
    DateTime? ultimoLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    PerfilModel? perfil,
  }) {
    return UsuarioModel(
      idUsuario: idUsuario ?? this.idUsuario,
      idEstabelecimento: idEstabelecimento ?? this.idEstabelecimento,
      nome: nome ?? this.nome,
      apelido: apelido ?? this.apelido,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      primeiraSenha: primeiraSenha ?? this.primeiraSenha,
      status: status ?? this.status,
      ultimoLoginAt: ultimoLoginAt ?? this.ultimoLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      perfil: perfil ?? this.perfil,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

int? _parseIntOpt(dynamic value) {
  if (value == null) return null;
  return int.tryParse(value.toString());
}

String? _parseStringOpt(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _parseDateOpt(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;

  if (value is bool) return value;

  final text = value.toString().trim().toLowerCase();

  return text == 'true' || text == '1' || text == 'sim';
}

String _montarNomeCompleto(String nome, String? apelido) {
  final n = nome.trim();
  final a = apelido?.trim() ?? '';
  return '$n $a'.trim();
}