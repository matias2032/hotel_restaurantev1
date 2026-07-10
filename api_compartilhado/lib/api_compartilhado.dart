library api_compartilhado;

// CONFIG
export 'api_config.dart';

// MODELS
export 'models/usuario_model.dart';
export 'models/auth_model.dart';
export 'models/cliente_model.dart';
export 'models/ingrediente_model.dart';
export 'models/produto_model.dart';
export 'models/servico_model.dart';
export 'models/movimento_estoque_model.dart';





// SERVICES
export 'services/usuario_service.dart';
export 'services/autenticacao_service.dart';
export 'services/sessao_service.dart';
export 'services/cliente_service.dart';
export 'services/ingrediente_service.dart';
export 'services/produto_service.dart';
export 'services/servico_service.dart';
export 'services/movimento_estoque_service.dart';

// PROVIDERS
export 'providers/usuario_provider.dart' hide UsuarioService;
export 'providers/cliente_provider.dart' hide ClienteService;
export 'providers/ingrediente_provider.dart' hide IngredienteService;
export 'providers/produto_provider.dart' hide ProdutoService;
export 'providers/servico_provider.dart' hide ServicoService;
export 'providers/movimento_estoque_provider.dart' hide MovimentoEstoqueService;

// REPOSITORIES
export 'repository/usuario_repository.dart';
export 'repository/cliente_repository.dart';
export 'repository/ingrediente_repository.dart';
export 'repository/produto_repository.dart';
export 'repository/servico_repository.dart';
export 'repository/movimento_estoque_repository.dart';