library api_compartilhado;

// CONFIG
export 'api_config.dart';

// MODELS
export 'models/usuario_model.dart';
export 'models/auth_model.dart';
export 'models/cliente_model.dart';

// SERVICES
export 'services/usuario_service.dart';
export 'services/autenticacao_service.dart';
export 'services/sessao_service.dart';
export 'services/cliente_service.dart';

// PROVIDERS
export 'providers/usuario_provider.dart' hide UsuarioService;
export 'providers/cliente_provider.dart' hide ClienteService;

// REPOSITORIES
export 'repository/usuario_repository.dart';
export 'repository/cliente_repository.dart';