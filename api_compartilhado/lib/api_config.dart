import 'package:flutter/foundation.dart';
import 'services/sessao_service.dart';

class ApiConfig {
  // ─────────────────────────────────────────────────────────────
  // CONFIGURAÇÃO DE AMBIENTE
  // ─────────────────────────────────────────────────────────────
  //
  // Desktop/Web local:
  // flutter run --dart-define=API_BASE_URL=http://localhost:8080
  //
  // Android emulator:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
  //
  // Produção futura:
  // flutter run --dart-define=API_BASE_URL=https://teu-dominio.com
  //

  static const String _baseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String? _baseUrlCache;

  static Future<String> get baseUrlAsync async {
    if (_baseUrlCache != null) return _baseUrlCache!;
    _baseUrlCache = _baseUrlFromEnv;
    return _baseUrlCache!;
  }

  static String get baseUrl {
    if (_baseUrlCache != null) return _baseUrlCache!;
    return _baseUrlFromEnv;
  }

  // ─────────────────────────────────────────────────────────────
  // ROTAS DO BACKEND
  // ─────────────────────────────────────────────────────────────

  static const String _usuariosAdministracao =
      '/api/administracao/usuarios';

  static String get usuariosUrl => '$baseUrl$_usuariosAdministracao';

  static String get perfisUrl => '$usuariosUrl/perfis';

  static String usuarioPorIdUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario';
  }

static String usuarioAtivoUrl(int idUsuario, bool ativo) {
  return '$usuariosUrl/$idUsuario/ativo?ativo=$ativo';
}

  static String usuarioAlterarSenhaUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/senha';
  }

  static String usuarioPrimeiraSenhaUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/primeira-senha';
  }

  static String usuarioResetarSenhaUrl(int idUsuario) {
    return '$usuariosUrl/$idUsuario/resetar-senha';
  }

  static String perfilPorIdUrl(int idPerfil) {
    return '$perfisUrl/$idPerfil';
  }

static String perfilAtivoUrl(int idPerfil, bool ativo) {
  return '$perfisUrl/$idPerfil/ativo?ativo=$ativo';
}

static String get authLoginUrl {
  return '$baseUrl/api/auth/login';
}

static String authPrimeiraSenhaUrl(int idUsuario) {
  return usuarioPrimeiraSenhaUrl(idUsuario);
}

  // ─────────────────────────────────────────────────────────────
  // CONFIGURAÇÕES GERAIS
  // ─────────────────────────────────────────────────────────────

  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> get defaultHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      static Map<String, String> get authHeaders {
  final token = SessaoService.instance.authorizationHeader;

  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': token,
  };
}

  static void printConfig() {
    debugPrint('🚀 API CONFIG — ${kIsWeb ? "Web" : "Desktop/Mobile"}');
    debugPrint('🔗 Base URL: $baseUrl');
    debugPrint(
      '🌍 API_BASE_URL env: ${const String.fromEnvironment('API_BASE_URL')}',
    );
  }
}