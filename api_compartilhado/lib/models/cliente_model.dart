class PerfilClienteModel {
  final int? idPerfilCliente;
  final String nomePerfilCliente;

  const PerfilClienteModel({
    this.idPerfilCliente,
    required this.nomePerfilCliente,
  });

  factory PerfilClienteModel.fromJson(Map<String, dynamic> json) {
    return PerfilClienteModel(
      idPerfilCliente: _parseIntOpt(json['idPerfilCliente']),
      nomePerfilCliente: (json['nomePerfilCliente'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nomePerfilCliente': nomePerfilCliente,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nomePerfilCliente': nomePerfilCliente,
    };
  }

  PerfilClienteModel copyWith({
    int? idPerfilCliente,
    String? nomePerfilCliente,
  }) {
    return PerfilClienteModel(
      idPerfilCliente: idPerfilCliente ?? this.idPerfilCliente,
      nomePerfilCliente: nomePerfilCliente ?? this.nomePerfilCliente,
    );
  }
}

class ClienteModel {
  final int? idCliente;
  final String nome;
  final String? apelido;
  final String nomeCompleto;
  final String? email;
  final String? telefone;
  final String? nuit;
  final bool ativo;
  final bool primeiraSenha;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PerfilClienteModel? perfilCliente;

  const ClienteModel({
    this.idCliente,
    required this.nome,
    this.apelido,
    String? nomeCompleto,
    this.email,
    this.telefone,
    this.nuit,
    this.ativo = true,
    this.primeiraSenha = true,
    this.createdAt,
    this.updatedAt,
    this.perfilCliente,
  }) : nomeCompleto = nomeCompleto ?? '';

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    final nome = (json['nome'] ?? '').toString();
    final apelido = _parseStringOpt(json['apelido']);
    final nomeCompletoBackend = _parseStringOpt(json['nomeCompleto']);

    return ClienteModel(
      idCliente: _parseIntOpt(json['idCliente']),
      nome: nome,
      apelido: apelido,
      nomeCompleto: nomeCompletoBackend ?? _montarNomeCompleto(nome, apelido),
      email: _parseStringOpt(json['email']),
      telefone: _parseStringOpt(json['telefone']),
      nuit: _parseStringOpt(json['nuit']),
      ativo: _parseBool(json['ativo'], defaultValue: true),
      primeiraSenha: _parseBool(json['primeiraSenha'], defaultValue: true),
      createdAt: _parseDateOpt(json['createdAt']),
      updatedAt: _parseDateOpt(json['updatedAt']),
      perfilCliente: json['perfilCliente'] is Map<String, dynamic>
          ? PerfilClienteModel.fromJson(
              json['perfilCliente'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toCreateJson({
    required int idPerfilCliente,
  }) {
    return {
      'idPerfilCliente': idPerfilCliente,
      'nome': nome,
      'apelido': apelido,
      'email': email,
      'telefone': telefone,
      'nuit': nuit,
    };
  }

  Map<String, dynamic> toUpdateJson({
    required int idPerfilCliente,
  }) {
    return {
      'idPerfilCliente': idPerfilCliente,
      'nome': nome,
      'apelido': apelido,
      'email': email,
      'telefone': telefone,
      'nuit': nuit,
      'ativo': ativo,
    };
  }

  ClienteModel copyWith({
    int? idCliente,
    String? nome,
    String? apelido,
    String? nomeCompleto,
    String? email,
    String? telefone,
    String? nuit,
    bool? ativo,
    bool? primeiraSenha,
    DateTime? createdAt,
    DateTime? updatedAt,
    PerfilClienteModel? perfilCliente,
  }) {
    return ClienteModel(
      idCliente: idCliente ?? this.idCliente,
      nome: nome ?? this.nome,
      apelido: apelido ?? this.apelido,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      nuit: nuit ?? this.nuit,
      ativo: ativo ?? this.ativo,
      primeiraSenha: primeiraSenha ?? this.primeiraSenha,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      perfilCliente: perfilCliente ?? this.perfilCliente,
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

bool _parseBool(
  dynamic value, {
  bool defaultValue = false,
}) {
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