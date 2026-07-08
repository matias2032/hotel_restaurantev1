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
  // CLIENTES
  // ─────────────────────────────────────────────────────────────

static const String _clientes =
    '/api/clientes';

static String get clientesUrl => '$baseUrl$_clientes';

static String get perfisClienteUrl => '$clientesUrl/perfis';

static String clientePorIdUrl(int idCliente) {
  return '$clientesUrl/$idCliente';
}

// static String clienteAtivoUrl(int idCliente, bool ativo) {
//   return '$clientesUrl/$idCliente/ativo?ativo=$ativo';
// }

// static String clienteAlterarSenhaUrl(int idCliente) {
//   return '$clientesUrl/$idCliente/senha';
// }

// static String clienteDefinirSenhaUrl(int idCliente) {
//   return '$clientesUrl/$idCliente/definir-senha';
// }

// static String clientePrimeiraSenhaUrl(int idCliente) {
//   return '$clientesUrl/$idCliente/primeira-senha';
// }

// static String clienteResetarSenhaUrl(int idCliente) {
//   return '$clientesUrl/$idCliente/resetar-senha';
// }

static String perfilClientePorIdUrl(int idPerfilCliente) {
  return '$perfisClienteUrl/$idPerfilCliente';
}

  // ─────────────────────────────────────────────────────────────
  // CATÁLOGO — INGREDIENTES
  // ─────────────────────────────────────────────────────────────

  static const String _ingredientesCatalogo =
      '/api/catalogo/ingredientes';

  static String get ingredientesUrl {
    return '$baseUrl$_ingredientesCatalogo';
  }

  static String get categoriasIngredienteUrl {
    return '$ingredientesUrl/categorias';
  }

  static String ingredientePorIdUrl(int idIngrediente) {
    return '$ingredientesUrl/$idIngrediente';
  }

  static String categoriaIngredientePorIdUrl(int idCategoriaIngrediente) {
    return '$categoriasIngredienteUrl/$idCategoriaIngrediente';
  }

  static String ingredienteDisponibilidadeUrl(int idIngrediente) {
    return '$ingredientesUrl/$idIngrediente/disponibilidade';
  }

  static String ingredienteEstadoUrl(int idIngrediente) {
    return '$ingredientesUrl/$idIngrediente/estado';
  }

  static String categoriaIngredienteEstadoUrl(int idCategoriaIngrediente) {
    return '$categoriasIngredienteUrl/$idCategoriaIngrediente/estado';
  }

  static String imagensIngredienteUrl(int idIngrediente) {
    return '$ingredientesUrl/$idIngrediente/imagens';
  }

  static String imagemIngredientePrincipalUrl({
    required int idIngrediente,
    required int idIngredienteImagem,
  }) {
    return '$ingredientesUrl/$idIngrediente/imagens/$idIngredienteImagem/principal';
  }

  static String imagemIngredientePorIdUrl({
    required int idIngrediente,
    required int idIngredienteImagem,
  }) {
    return '$ingredientesUrl/$idIngrediente/imagens/$idIngredienteImagem';
  }

  // ─────────────────────────────────────────────────────────────
  // CATÁLOGO — PRODUTOS
  // ─────────────────────────────────────────────────────────────

  static const String _produtosCatalogo =
      '/api/catalogo/produtos';

  static String get produtosUrl {
    return '$baseUrl$_produtosCatalogo';
  }

  static String get categoriasProdutoUrl {
    return '$produtosUrl/categorias';
  }

  static String produtoPorIdUrl(int idProduto) {
    return '$produtosUrl/$idProduto';
  }

  static String categoriaProdutoPorIdUrl(int idCategoriaProduto) {
    return '$categoriasProdutoUrl/$idCategoriaProduto';
  }

  static String produtoDisponibilidadeUrl(int idProduto) {
    return '$produtosUrl/$idProduto/disponibilidade';
  }

  static String produtoDestaqueUrl(int idProduto) {
    return '$produtosUrl/$idProduto/destaque';
  }

  static String produtoEstadoUrl(int idProduto) {
    return '$produtosUrl/$idProduto/estado';
  }

  static String categoriaProdutoEstadoUrl(int idCategoriaProduto) {
    return '$categoriasProdutoUrl/$idCategoriaProduto/estado';
  }

  static String imagensProdutoUrl(int idProduto) {
    return '$produtosUrl/$idProduto/imagens';
  }

  static String imagemProdutoPrincipalUrl({
    required int idProduto,
    required int idProdutoImagem,
  }) {
    return '$produtosUrl/$idProduto/imagens/$idProdutoImagem/principal';
  }

  static String imagemProdutoPorIdUrl({
    required int idProduto,
    required int idProdutoImagem,
  }) {
    return '$produtosUrl/$idProduto/imagens/$idProdutoImagem';
  }

  static String ingredientesProdutoUrl(int idProduto) {
    return '$produtosUrl/$idProduto/ingredientes';
  }

  static String ingredienteProdutoPorIdUrl({
    required int idProduto,
    required int idIngrediente,
  }) {
    return '$produtosUrl/$idProduto/ingredientes/$idIngrediente';
  }

  // ─────────────────────────────────────────────────────────────
  // CATÁLOGO — SERVIÇOS
  // ─────────────────────────────────────────────────────────────

  static const String _servicosCatalogo =
      '/api/catalogo/servicos';

  static String get servicosUrl {
    return '$baseUrl$_servicosCatalogo';
  }

  static String get categoriasServicoUrl {
    return '$servicosUrl/categorias';
  }

  static String servicoPorIdUrl(int idServico) {
    return '$servicosUrl/$idServico';
  }

  static String categoriaServicoPorIdUrl(int idCategoriaServico) {
    return '$categoriasServicoUrl/$idCategoriaServico';
  }

  static String servicoDisponibilidadeUrl(int idServico) {
    return '$servicosUrl/$idServico/disponibilidade';
  }

  static String servicoDestaqueUrl(int idServico) {
    return '$servicosUrl/$idServico/destaque';
  }

  static String servicoEstadoUrl(int idServico) {
    return '$servicosUrl/$idServico/estado';
  }

  static String categoriaServicoEstadoUrl(int idCategoriaServico) {
    return '$categoriasServicoUrl/$idCategoriaServico/estado';
  }

  static String imagensServicoUrl(int idServico) {
    return '$servicosUrl/$idServico/imagens';
  }

  static String imagemServicoPrincipalUrl({
    required int idServico,
    required int idServicoImagem,
  }) {
    return '$servicosUrl/$idServico/imagens/$idServicoImagem/principal';
  }

  static String imagemServicoPorIdUrl({
    required int idServico,
    required int idServicoImagem,
  }) {
    return '$servicosUrl/$idServico/imagens/$idServicoImagem';
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