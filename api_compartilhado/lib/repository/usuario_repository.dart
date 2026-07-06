import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class UsuarioRepository {
  final UsuarioService service;

  UsuarioRepository({
    required this.service,
  });

  // ─────────────────────────────────────────────────────────────
  // PERFIS
  // ─────────────────────────────────────────────────────────────

  Future<List<PerfilModel>> listarPerfis({
    bool somenteAtivos = false,
  }) {
    return service.listarPerfis(somenteAtivos: somenteAtivos);
  }

  Future<PerfilModel> buscarPerfilPorId(int idPerfil) {
    return service.buscarPerfilPorId(idPerfil);
  }

  Future<PerfilModel> criarPerfil(PerfilModel perfil) {
    return service.criarPerfil(perfil);
  }

  Future<PerfilModel> editarPerfil({
    required int idPerfil,
    required PerfilModel perfil,
  }) {
    return service.editarPerfil(
      idPerfil: idPerfil,
      perfil: perfil,
    );
  }

Future<PerfilModel> alterarAtivoPerfil({
  required int idPerfil,
  required bool ativo,
}) {
  return service.alterarAtivoPerfil(
    idPerfil: idPerfil,
    ativo: ativo,
  );
}

Future<PerfilModel> activarPerfil(int idPerfil) {
  return service.activarPerfil(idPerfil);
}

Future<PerfilModel> desactivarPerfil(int idPerfil) {
  return service.desactivarPerfil(idPerfil);
}

  // ─────────────────────────────────────────────────────────────
  // USUÁRIOS
  // ─────────────────────────────────────────────────────────────

  Future<List<UsuarioModel>> listarUsuarios({
    bool somenteAtivos = false,
  }) {
    return service.listarUsuarios(somenteAtivos: somenteAtivos);
  }

  Future<List<UsuarioModel>> listarUsuariosResumo() {
    return service.listarUsuariosResumo();
  }

  Future<UsuarioModel> buscarUsuarioPorId(int idUsuario) {
    return service.buscarUsuarioPorId(idUsuario);
  }

  Future<UsuarioModel> criarUsuario({
    required UsuarioModel usuario,
    required int idPerfil,
  }) {
    return service.criarUsuario(
      usuario: usuario,
      idPerfil: idPerfil,
    );
  }

  Future<UsuarioModel> editarUsuario({
    required int idUsuario,
    required UsuarioModel usuario,
    required int idPerfil,
  }) {
    return service.editarUsuario(
      idUsuario: idUsuario,
      usuario: usuario,
      idPerfil: idPerfil,
    );
  }

Future<UsuarioModel> alterarAtivoUsuario({
  required int idUsuario,
  required bool ativo,
}) {
  return service.alterarAtivoUsuario(
    idUsuario: idUsuario,
    ativo: ativo,
  );
}

  Future<void> alterarSenha({
    required int idUsuario,
    required String senhaActual,
    required String novaSenha,
  }) {
    return service.alterarSenha(
      idUsuario: idUsuario,
      senhaActual: senhaActual,
      novaSenha: novaSenha,
    );
  }

  Future<void> trocarPrimeiraSenha({
    required int idUsuario,
    required String novaSenha,
  }) {
    return service.trocarPrimeiraSenha(
      idUsuario: idUsuario,
      novaSenha: novaSenha,
    );
  }

  Future<void> resetarSenhaPadrao(int idUsuario) {
    return service.resetarSenhaPadrao(idUsuario);
  }

  Future<void> eliminarUsuario(int idUsuario) {
    return service.eliminarUsuario(idUsuario);
  }
}