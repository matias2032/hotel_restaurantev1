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
    await _executar(() async {
      _perfis = await repository.listarPerfis(
        somenteAtivos: somenteAtivos,
      );
    });
  }

  Future<PerfilModel?> criarPerfil(PerfilModel perfil) async {
    PerfilModel? criado;

    await _executar(() async {
      criado = await repository.criarPerfil(perfil);
      _perfis = await repository.listarPerfis(somenteAtivos: true);
    });

    return criado;
  }

  Future<PerfilModel?> editarPerfil({
    required int idPerfil,
    required PerfilModel perfil,
  }) async {
    PerfilModel? editado;

    await _executar(() async {
      editado = await repository.editarPerfil(
        idPerfil: idPerfil,
        perfil: perfil,
      );

      _perfis = await repository.listarPerfis(somenteAtivos: true);
    });

    return editado;
  }

Future<void> alterarAtivoPerfil({
  required int idPerfil,
  required bool ativo,
}) async {
  await _executar(() async {
    await repository.alterarAtivoPerfil(
      idPerfil: idPerfil,
      ativo: ativo,
    );

_perfis = await repository.listarPerfis(somenteAtivos: false);
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
    await _executar(() async {
      _usuarios = await repository.listarUsuarios(
        somenteAtivos: somenteAtivos,
      );
    });
  }

  Future<void> carregarUsuariosResumo() async {
    await _executar(() async {
      _usuarios = await repository.listarUsuariosResumo();
    });
  }

  Future<UsuarioModel?> buscarUsuarioPorId(int idUsuario) async {
    UsuarioModel? usuario;

    await _executar(() async {
      usuario = await repository.buscarUsuarioPorId(idUsuario);
      _usuarioSelecionado = usuario;
    });

    return usuario;
  }

  Future<UsuarioModel?> criarUsuario({
    required UsuarioModel usuario,
    required int idPerfil,
  }) async {
    UsuarioModel? criado;

    await _executar(() async {
      criado = await repository.criarUsuario(
        usuario: usuario,
        idPerfil: idPerfil,
      );

      _usuarios = await repository.listarUsuarios();
    });

    return criado;
  }

  Future<UsuarioModel?> editarUsuario({
    required int idUsuario,
    required UsuarioModel usuario,
    required int idPerfil,
  }) async {
    UsuarioModel? editado;

    await _executar(() async {
      editado = await repository.editarUsuario(
        idUsuario: idUsuario,
        usuario: usuario,
        idPerfil: idPerfil,
      );

      _usuarios = await repository.listarUsuarios();

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = editado;
      }
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
  await _executar(() async {
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
  });
}
  Future<void> alterarSenha({
    required int idUsuario,
    required String senhaActual,
    required String novaSenha,
  }) async {
    await _executar(() async {
      await repository.alterarSenha(
        idUsuario: idUsuario,
        senhaActual: senhaActual,
        novaSenha: novaSenha,
      );
    });
  }

  Future<void> trocarPrimeiraSenha({
    required int idUsuario,
    required String novaSenha,
  }) async {
    await _executar(() async {
      await repository.trocarPrimeiraSenha(
        idUsuario: idUsuario,
        novaSenha: novaSenha,
      );
    });
  }

  Future<void> resetarSenhaPadrao(int idUsuario) async {
    await _executar(() async {
      await repository.resetarSenhaPadrao(idUsuario);

      final actualizado = await repository.buscarUsuarioPorId(idUsuario);

      _usuarios = _usuarios
          .map((u) => u.idUsuario == idUsuario ? actualizado : u)
          .toList();

      if (_usuarioSelecionado?.idUsuario == idUsuario) {
        _usuarioSelecionado = actualizado;
      }
    });
  }

Future<void> eliminarUsuario(int idUsuario) async {
  await _executar(() async {
    await repository.eliminarUsuario(idUsuario);

    _usuarios = _usuarios
        .map(
          (u) => u.idUsuario == idUsuario
              ? u.copyWith(ativo: false)
              : u,
        )
        .toList();

    if (_usuarioSelecionado?.idUsuario == idUsuario) {
      _usuarioSelecionado =
          _usuarioSelecionado!.copyWith(ativo: false);
    }
  });
}

  void limparUsuarioSelecionado() {
    _usuarioSelecionado = null;
    notifyListeners();
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // HELPER INTERNO
  // ─────────────────────────────────────────────────────────────

  Future<void> _executar(Future<void> Function() action) async {
    _setCarregando(true);

    try {
      _erro = null;
      await action();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      debugPrint('❌ UsuarioProvider erro: $_erro');
    } finally {
      _setCarregando(false);
    }
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }
}