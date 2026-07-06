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
  List<PerfilClienteModel> get perfisCliente =>
      List.unmodifiable(_perfisCliente);

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
    });

    return cliente;
  }

  Future<ClienteModel?> criarCliente({
    required ClienteModel cliente,
    required int idPerfilCliente,
  }) async {
    ClienteModel? criado;

    await _executar('Criar cliente ${cliente.nome}', () async {
      criado = await repository.criarCliente(
        cliente: cliente,
        idPerfilCliente: idPerfilCliente,
      );

      _clientes = await repository.listarClientes();

      debugPrint(
        '✅ ClienteProvider — Cliente criado: '
        '${criado?.nomeCompleto ?? criado?.nome ?? cliente.nome}',
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
    });

    return editado;
  }

  Future<void> alterarAtivoCliente({
    required int idCliente,
    required bool ativo,
  }) async {
    final acao = ativo
        ? 'Activar cliente #$idCliente'
        : 'Desactivar cliente #$idCliente';

    await _executar(acao, () async {
      final actualizado = await repository.alterarAtivoCliente(
        idCliente: idCliente,
        ativo: ativo,
      );

      _clientes = _clientes
          .map((c) => c.idCliente == idCliente ? actualizado : c)
          .toList();

      if (_clienteSelecionado?.idCliente == idCliente) {
        _clienteSelecionado = actualizado;
      }

      debugPrint(
        'ℹ️ ClienteProvider — Cliente #$idCliente agora está '
        '${ativo ? 'activo' : 'inactivo'}.',
      );
    });
  }

  Future<void> activarCliente(int idCliente) async {
    await alterarAtivoCliente(
      idCliente: idCliente,
      ativo: true,
    );
  }

  Future<void> desactivarCliente(int idCliente) async {
    await alterarAtivoCliente(
      idCliente: idCliente,
      ativo: false,
    );
  }

  Future<void> definirSenha({
    required int idCliente,
    required String novaSenha,
  }) async {
    await _executar('Definir senha do cliente #$idCliente', () async {
      await repository.definirSenha(
        idCliente: idCliente,
        novaSenha: novaSenha,
      );

      final actualizado = await repository.buscarClientePorId(idCliente);

      _clientes = _clientes
          .map((c) => c.idCliente == idCliente ? actualizado : c)
          .toList();

      if (_clienteSelecionado?.idCliente == idCliente) {
        _clienteSelecionado = actualizado;
      }

      debugPrint(
        '✅ ClienteProvider — Senha do cliente #$idCliente definida.',
      );
    });
  }

  Future<void> alterarSenha({
    required int idCliente,
    required String senhaActual,
    required String novaSenha,
  }) async {
    await _executar('Alterar senha do cliente #$idCliente', () async {
      await repository.alterarSenha(
        idCliente: idCliente,
        senhaActual: senhaActual,
        novaSenha: novaSenha,
      );

      debugPrint(
        '✅ ClienteProvider — Senha do cliente #$idCliente alterada.',
      );
    });
  }

  Future<void> trocarPrimeiraSenha({
    required int idCliente,
    required String novaSenha,
  }) async {
    await _executar('Trocar primeira senha do cliente #$idCliente', () async {
      await repository.trocarPrimeiraSenha(
        idCliente: idCliente,
        novaSenha: novaSenha,
      );

      final actualizado = await repository.buscarClientePorId(idCliente);

      _clientes = _clientes
          .map((c) => c.idCliente == idCliente ? actualizado : c)
          .toList();

      if (_clienteSelecionado?.idCliente == idCliente) {
        _clienteSelecionado = actualizado;
      }

      debugPrint(
        '✅ ClienteProvider — Primeira senha do cliente #$idCliente alterada.',
      );
    });
  }

  Future<void> resetarSenhaPadrao(int idCliente) async {
    await _executar('Resetar senha padrão do cliente #$idCliente', () async {
      await repository.resetarSenhaPadrao(idCliente);

      final actualizado = await repository.buscarClientePorId(idCliente);

      _clientes = _clientes
          .map((c) => c.idCliente == idCliente ? actualizado : c)
          .toList();

      if (_clienteSelecionado?.idCliente == idCliente) {
        _clienteSelecionado = actualizado;
      }

      debugPrint(
        '✅ ClienteProvider — Senha do cliente #$idCliente redefinida para padrão.',
      );
    });
  }

  Future<void> eliminarCliente(int idCliente) async {
    await _executar('Eliminar cliente #$idCliente', () async {
      await repository.eliminarCliente(idCliente);

      _clientes = _clientes
          .map(
            (c) => c.idCliente == idCliente
                ? c.copyWith(ativo: false)
                : c,
          )
          .toList();

      if (_clienteSelecionado?.idCliente == idCliente) {
        _clienteSelecionado = _clienteSelecionado!.copyWith(
          ativo: false,
        );
      }

      debugPrint(
        '✅ ClienteProvider — Cliente #$idCliente eliminado/desactivado.',
      );
    });
  }

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
      'perfisCliente=${_perfisCliente.length}',
    );

    notifyListeners();
  }
}