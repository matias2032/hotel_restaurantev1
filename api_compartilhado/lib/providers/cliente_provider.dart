import 'package:flutter/foundation.dart';

import '../models/cliente_model.dart';
import '../repository/cliente_repository.dart';

class ClienteProvider extends ChangeNotifier {
  final ClienteRepository repository;

  ClienteProvider({
    required this.repository,
  });

  List<ClienteModel> _clientes = [];
  List<PerfilClienteModel> _perfisCliente = [];

  ClienteModel? _clienteSelecionado;

  bool _carregando = false;
  String? _erro;

  List<ClienteModel> get clientes => List.unmodifiable(_clientes);

  List<PerfilClienteModel> get perfisCliente {
    return List.unmodifiable(_perfisCliente);
  }

  ClienteModel? get clienteSelecionado => _clienteSelecionado;

  bool get carregando => _carregando;
  String? get erro => _erro;

  bool get temErro => _erro != null;

  // ─────────────────────────────────────────────────────────────
  // PERFIS DE CLIENTE
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarPerfisCliente() async {
    await _executar('Carregar perfis de cliente', () async {
      _perfisCliente = await repository.listarPerfisCliente();

      debugPrint(
        'ℹ️ ClienteProvider — ${_perfisCliente.length} perfil(is) de cliente carregado(s).',
      );

      if (_perfisCliente.isNotEmpty) {
        final nomes = _perfisCliente
            .map((perfil) => perfil.nomePerfilCliente)
            .join(', ');

        debugPrint(
          '📌 ClienteProvider — Perfis disponíveis: $nomes',
        );
      }
    });
  }

  Future<PerfilClienteModel?> criarPerfilCliente(
    PerfilClienteModel perfil,
  ) async {
    PerfilClienteModel? criado;

    await _executar(
      'Criar perfil de cliente ${perfil.nomePerfilCliente}',
      () async {
        criado = await repository.criarPerfilCliente(perfil);

        _perfisCliente = await repository.listarPerfisCliente();

        debugPrint(
          '✅ ClienteProvider — Perfil de cliente criado: '
          '${criado?.nomePerfilCliente ?? perfil.nomePerfilCliente}',
        );

        debugPrint(
          '📊 ClienteProvider — Total de perfis após criação: ${_perfisCliente.length}',
        );
      },
    );

    return criado;
  }

  Future<PerfilClienteModel?> editarPerfilCliente({
    required int idPerfilCliente,
    required PerfilClienteModel perfil,
  }) async {
    PerfilClienteModel? editado;

    await _executar('Editar perfil de cliente #$idPerfilCliente', () async {
      editado = await repository.editarPerfilCliente(
        idPerfilCliente: idPerfilCliente,
        perfil: perfil,
      );

      _perfisCliente = await repository.listarPerfisCliente();

      debugPrint(
        '✅ ClienteProvider — Perfil de cliente #$idPerfilCliente actualizado.',
      );

      debugPrint(
        '📊 ClienteProvider — Total de perfis após edição: ${_perfisCliente.length}',
      );
    });

    return editado;
  }

  // ─────────────────────────────────────────────────────────────
  // CLIENTES
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarClientes({
    bool somenteAtivos = false,
  }) async {
    await _executar('Carregar clientes', () async {
      _clientes = await repository.listarClientes(
        somenteAtivos: somenteAtivos,
      );

      debugPrint(
        'ℹ️ ClienteProvider — ${_clientes.length} cliente(s) carregado(s). '
        'somenteAtivos=$somenteAtivos',
      );

      final empresariais = _clientes.where((cliente) {
        return cliente.perfilCliente?.nomePerfilCliente
                .trim()
                .toLowerCase() ==
            'empresarial';
      }).length;

      debugPrint(
        '🏢 ClienteProvider — Clientes empresariais carregados: $empresariais',
      );
    });
  }

  Future<void> carregarClientesResumo() async {
    await _executar('Carregar resumo de clientes', () async {
      _clientes = await repository.listarClientesResumo();

      debugPrint(
        'ℹ️ ClienteProvider — ${_clientes.length} resumo(s) de cliente carregado(s).',
      );
    });
  }

  Future<ClienteModel?> buscarClientePorId(int idCliente) async {
    ClienteModel? cliente;

    await _executar('Buscar cliente #$idCliente', () async {
      cliente = await repository.buscarClientePorId(idCliente);
      _clienteSelecionado = cliente;

      debugPrint(
        'ℹ️ ClienteProvider — Cliente seleccionado: '
        '${cliente?.nomeCompleto ?? cliente?.nome ?? '#$idCliente'}',
      );

      debugPrint(
        '📌 ClienteProvider — Perfil do cliente seleccionado: '
        '${cliente?.perfilCliente?.nomePerfilCliente ?? 'Sem perfil'}',
      );

      debugPrint(
        '📌 ClienteProvider — Estado do cliente seleccionado: '
        '${cliente?.ativo == true ? 'activo' : 'inactivo'}',
      );
    });

    return cliente;
  }

  Future<ClienteModel?> criarCliente({
    required ClienteModel cliente,
    required int idPerfilCliente,
  }) async {
    ClienteModel? criado;

    await _executar('Criar cliente ${cliente.nome}', () async {
      debugPrint(
        '📤 ClienteProvider — A criar cliente com perfil #$idPerfilCliente...',
      );

      debugPrint(
        '📤 ClienteProvider — Dados: '
        'nome=${cliente.nome}, '
        'email=${cliente.email ?? '-'}, '
        'telefone=${cliente.telefone ?? '-'}, '
        'nuit=${cliente.nuit ?? '-'}',
      );

      criado = await repository.criarCliente(
        cliente: cliente,
        idPerfilCliente: idPerfilCliente,
      );

      _clientes = await repository.listarClientes();

      debugPrint(
        '✅ ClienteProvider — Cliente criado: '
        '${criado?.nomeCompleto ?? criado?.nome ?? cliente.nome}',
      );

      debugPrint(
        '📊 ClienteProvider — Total de clientes após criação: ${_clientes.length}',
      );
    });

    return criado;
  }

  Future<ClienteModel?> editarCliente({
    required int idCliente,
    required ClienteModel cliente,
    required int idPerfilCliente,
  }) async {
    ClienteModel? editado;

    await _executar('Editar cliente #$idCliente', () async {
      debugPrint(
        '📤 ClienteProvider — A editar cliente #$idCliente com perfil #$idPerfilCliente...',
      );

      debugPrint(
        '📤 ClienteProvider — Dados actualizados: '
        'nome=${cliente.nome}, '
        'email=${cliente.email ?? '-'}, '
        'telefone=${cliente.telefone ?? '-'}, '
        'nuit=${cliente.nuit ?? '-'}',
      );

      editado = await repository.editarCliente(
        idCliente: idCliente,
        cliente: cliente,
        idPerfilCliente: idPerfilCliente,
      );

      _clientes = await repository.listarClientes();

      if (_clienteSelecionado?.idCliente == idCliente) {
        _clienteSelecionado = editado;
      }

      debugPrint(
        '✅ ClienteProvider — Cliente #$idCliente actualizado.',
      );

      debugPrint(
        '📊 ClienteProvider — Total de clientes após edição: ${_clientes.length}',
      );
    });

    return editado;
  }

  // ─────────────────────────────────────────────────────────────
  // MÉTODOS REMOVIDOS DO FLUTTER ADMIN
  // ─────────────────────────────────────────────────────────────
  //
  // Estes fluxos foram removidos desta camada para evitar uso acidental:
  //
  // - activarCliente(...)
  // - desactivarCliente(...)
  // - alterarAtivoCliente(...)
  // - resetarSenhaPadrao(...)
  // - eliminarCliente(...)
  //
  // A gestão de senha do cliente passará a ser feita por fluxo próprio:
  //
  // - esqueci senha
  // - redefinir senha via email/token
  //
  // A desactivação manual de clientes também fica indisponível no painel
  // administrativo Flutter neste momento.

  // ─────────────────────────────────────────────────────────────
  // LIMPEZA DE ESTADO
  // ─────────────────────────────────────────────────────────────

  void limparClienteSelecionado() {
    _clienteSelecionado = null;

    debugPrint('🧹 ClienteProvider — Cliente seleccionado limpo.');

    notifyListeners();
  }

  void limparErro() {
    _erro = null;

    debugPrint('🧹 ClienteProvider — Erro limpo.');

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // HELPER INTERNO
  // ─────────────────────────────────────────────────────────────

  Future<void> _executar(
    String acao,
    Future<void> Function() action,
  ) async {
    _setCarregando(true);

    debugPrint('🔄 ClienteProvider — $acao...');

    try {
      _erro = null;

      await action();

      debugPrint('✅ ClienteProvider — $acao concluído.');
    } catch (e, stackTrace) {
      _erro = e.toString().replaceFirst('Exception: ', '');

      debugPrint('❌ ClienteProvider — $acao falhou: $_erro');
      debugPrint('🧩 ClienteProvider — StackTrace: $stackTrace');
    } finally {
      _setCarregando(false);
    }
  }

  void _setCarregando(bool value) {
    _carregando = value;

    debugPrint(
      '⏳ ClienteProvider — carregando=$value | '
      'clientes=${_clientes.length} | '
      'perfisCliente=${_perfisCliente.length} | '
      'clienteSelecionado=${_clienteSelecionado?.idCliente ?? '-'}',
    );

    notifyListeners();
  }
}