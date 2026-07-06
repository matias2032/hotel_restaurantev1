import 'package:flutter/foundation.dart';

import '../models/usuario_model.dart';
import '../repository/usuario_repository.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioRepository repository;

  UsuarioProvider({
    required this.repository,
  });

  List<UsuarioModel> _usuarios = [];
  List<PerfilModel> _perfis = [];

  UsuarioModel? _usuarioSelecionado;

  bool _carregando = false;
  String? _erro;

  List<UsuarioModel> get usuarios => List.unmodifiable(_usuarios);
  List<PerfilModel> get perfis => List.unmodifiable(_perfis);

  UsuarioModel? get usuarioSelecionado => _usuarioSelecionado;

  bool get carregando => _carregando;
  String? get erro => _erro;

  bool get temErro => _erro != null;

  // ─────────────────────────────────────────────────────────────
  // PERFIS
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarPerfis({
    bool somenteAtivos = true,
  }) async {
    await _executar('Carregar perfis', () async {
      _perfis = await repository.listarPerfis(
        somenteAtivos: somenteAtivos,
      );

      debugPrint(
        'ℹ️ UsuarioProvider — ${_perfis.length} perfil(is) carregado(s). '
        'somenteAtivos=$somenteAtivos',
      );
    });
  }

  Future<PerfilModel?> criarPerfil(PerfilModel perfil) async {
    PerfilModel? criado;

    await _executar('Criar perfil ${perfil.nomePerfil}', () async {
      criado = await repository.criarPerfil(perfil);

      _perfis = await repository.listarPerfis(
        somenteAtivos: false,
      );

      debugPrint(
        '✅ UsuarioProvider — Perfil criado: '
        '${criado?.nomePerfil ?? perfil.nomePerfil}',
      );
    });

    return criado;
  }

  Future<PerfilModel?> editarPerfil({
    required int idPerfil,
    required PerfilModel perfil,
  }) async {
    PerfilModel? editado;

    await _executar('Editar perfil #$idPerfil', () async {
      editado = await repository.editarPerfil(
        idPerfil: idPerfil,
        perfil: perfil,
      );

      _perfis = await repository.listarPerfis(
        somenteAtivos: false,
      );

      debugPrint(
        '✅ UsuarioProvider — Perfil #$idPerfil actualizado.',
      );
    });

    return editado;
  }

  Future<void> alterarAtivoPerfil({
    required int idPerfil,
    required bool ativo,
  }) async {
    final acao = ativo
        ? 'Activar perfil #$idPerfil'
        : 'Desactivar perfil #$idPerfil';

    await _executar(acao, () async {
      final actualizado = await repository.alterarAtivoPerfil(
        idPerfil: idPerfil,
        ativo: ativo,
      );

      _perfis = _perfis
          .map((p) => p.idPerfil == idPerfil ? actualizado : p)
          .toList();

      _perfis = await repository.listarPerfis(
        somenteAtivos: false,
      );

      debugPrint(
        'ℹ️ UsuarioProvider — Perfil #$idPerfil agora está '
        '${ativo ? 'activo' : 'inactivo'}.',
      );
    });
  }

  Future<void> activarPerfil(int idPerfil) async {
    await alterarAtivoPerfil(
      idPerfil: idPerfil,
      ativo: true,
    );
  }

  Future<void> desactivarPerfil(int idPerfil) async {
    await alterarAtivoPerfil(
      idPerfil: idPerfil,
      ativo: false,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // USUÁRIOS
  // ─────────────────────────────────────────────────────────────

  Future<void> carregarUsuarios({
    bool somenteAtivos = false,
  }) async {
    await _executar('Carregar usuários', () async {
      _usuarios = await repository.listarUsuarios(
        somenteAtivos: somenteAtivos,
      );

      debugPrint(
        'ℹ️ UsuarioProvider — ${_usuarios.length} usuário(s) carregado(s). '
        'somenteAtivos=$somenteAtivos',
      );
    });
  }

  Future<void> carregarUsuariosResumo() async {
    await _executar('Carregar resumo de usuários', () async {
      _usuarios = await repository.listarUsuariosResumo();

      debugPrint(
        'ℹ️ UsuarioProvider — ${_usuarios.length} resumo(s) de usuário carregado(s).',
      );
    });
  }

  Future<UsuarioModel?> buscarUsuarioPorId(int idUsuario) async {
    UsuarioModel? usuario;

    await _executar('Buscar usuário #$idUsuario', () async {
      usuario = await repository.buscarUsuarioPorId(idUsuario);
      _usuarioSelecionado = usuario;

      debugPrint(
        'ℹ️ UsuarioProvider — Usuário seleccionado: '
        '${usuario?.nomeCompleto ?? usuario?.nome ?? '#$idUsuario'}',
      );
    });

    return usuario;
  }

  Future<UsuarioModel?> criarUsuario({
    required UsuarioModel usuario,
    required int idPerfil,
  }) async {
    UsuarioModel? criado;

    await _executar('Criar usuário ${usuario.nome}', () async {
      criado = await repository.criarUsuario(
        usuario: usuario,
        idPerfil: idPerfil,
      );

      _usuarios = await repository.listarUsuarios();

      debugPrint(
        '✅ UsuarioProvider — Usuário criado: '
        '${criado?.nomeCompleto ?? criado?.nome ?? usuario.nome}',
      );
    });

    return criado;
  }

  Future<UsuarioModel?> editarUsuario({
    required int idUsuario,
    required UsuarioModel usuario,
    required int idPerfil,
  }) async {
    UsuarioModel? editado;

    await _executar('Editar usuário #$idUsuario', () async {
      editado = await repository.editarUsuario(
        idUsuario: idUsuario,
        usuario: usuario,
        idPerfil: idPerfil,
      );

      _usuarios = await repository.listarUsuarios();

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = editado;
      }

      debugPrint(
        '✅ UsuarioProvider — Usuário #$idUsuario actualizado.',
      );
    });

    return editado;
  }

  Future<void> activarUsuario(int idUsuario) async {
    await alterarAtivoUsuario(
      idUsuario: idUsuario,
      ativo: true,
    );
  }

  Future<void> desactivarUsuario(int idUsuario) async {
    await alterarAtivoUsuario(
      idUsuario: idUsuario,
      ativo: false,
    );
  }

  Future<void> alterarAtivoUsuario({
    required int idUsuario,
    required bool ativo,
  }) async {
    final acao = ativo
        ? 'Activar usuário #$idUsuario'
        : 'Desactivar usuário #$idUsuario';

    await _executar(acao, () async {
      final actualizado = await repository.alterarAtivoUsuario(
        idUsuario: idUsuario,
        ativo: ativo,
      );

      _usuarios = _usuarios
          .map((u) => u.idUsuario == idUsuario ? actualizado : u)
          .toList();

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = actualizado;
      }

      debugPrint(
        'ℹ️ UsuarioProvider — Usuário #$idUsuario agora está '
        '${ativo ? 'activo' : 'inactivo'}.',
      );
    });
  }

  Future<void> alterarSenha({
    required int idUsuario,
    required String senhaActual,
    required String novaSenha,
  }) async {
    await _executar('Alterar senha do usuário #$idUsuario', () async {
      await repository.alterarSenha(
        idUsuario: idUsuario,
        senhaActual: senhaActual,
        novaSenha: novaSenha,
      );

      debugPrint(
        '✅ UsuarioProvider — Senha do usuário #$idUsuario alterada.',
      );
    });
  }

  Future<void> trocarPrimeiraSenha({
    required int idUsuario,
    required String novaSenha,
  }) async {
    await _executar('Trocar primeira senha do usuário #$idUsuario', () async {
      await repository.trocarPrimeiraSenha(
        idUsuario: idUsuario,
        novaSenha: novaSenha,
      );

      debugPrint(
        '✅ UsuarioProvider — Primeira senha do usuário #$idUsuario alterada.',
      );
    });
  }

  Future<void> resetarSenhaPadrao(int idUsuario) async {
    await _executar('Resetar senha padrão do usuário #$idUsuario', () async {
      await repository.resetarSenhaPadrao(idUsuario);

      final actualizado = await repository.buscarUsuarioPorId(idUsuario);

      _usuarios = _usuarios
          .map((u) => u.idUsuario == idUsuario ? actualizado : u)
          .toList();

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = actualizado;
      }

      debugPrint(
        '✅ UsuarioProvider — Senha do usuário #$idUsuario redefinida para padrão.',
      );
    });
  }

  Future<void> eliminarUsuario(int idUsuario) async {
    await _executar('Eliminar usuário #$idUsuario', () async {
      await repository.eliminarUsuario(idUsuario);

      _usuarios = _usuarios
          .map(
            (u) => u.idUsuario == idUsuario
                ? u.copyWith(ativo: false)
                : u,
          )
          .toList();

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = _usuarioSelecionado!.copyWith(
          ativo: false,
        );
      }

      debugPrint(
        '✅ UsuarioProvider — Usuário #$idUsuario eliminado/desactivado.',
      );
    });
  }

  // ─────────────────────────────────────────────────────────────
  // LIMPEZA DE ESTADO
  // ─────────────────────────────────────────────────────────────

  void limparUsuarioSelecionado() {
    _usuarioSelecionado = null;

    debugPrint('🧹 UsuarioProvider — Usuário seleccionado limpo.');

    notifyListeners();
  }

  void limparErro() {
    _erro = null;

    debugPrint('🧹 UsuarioProvider — Erro limpo.');

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

    debugPrint('🔄 UsuarioProvider — $acao...');

    try {
      _erro = null;

      await action();

      debugPrint('✅ UsuarioProvider — $acao concluído.');
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');

      debugPrint('❌ UsuarioProvider — $acao falhou: $_erro');
    } finally {
      _setCarregando(false);
    }
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}