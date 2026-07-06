import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

class ClienteRepository {
  final ClienteService service;

  ClienteRepository({
    required this.service,
  });

  // ─────────────────────────────────────────────────────────────
  // PERFIS DE CLIENTE
  // ─────────────────────────────────────────────────────────────

  Future<List<PerfilClienteModel>> listarPerfisCliente() {
    return service.listarPerfisCliente();
  }

  Future<PerfilClienteModel> buscarPerfilClientePorId(int idPerfilCliente) {
    return service.buscarPerfilClientePorId(idPerfilCliente);
  }

  Future<PerfilClienteModel> criarPerfilCliente(
    PerfilClienteModel perfil,
  ) {
    return service.criarPerfilCliente(perfil);
  }

  Future<PerfilClienteModel> editarPerfilCliente({
    required int idPerfilCliente,
    required PerfilClienteModel perfil,
  }) {
    return service.editarPerfilCliente(
      idPerfilCliente: idPerfilCliente,
      perfil: perfil,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CLIENTES
  // ─────────────────────────────────────────────────────────────

  Future<List<ClienteModel>> listarClientes({
    bool somenteAtivos = false,
  }) {
    return service.listarClientes(
      somenteAtivos: somenteAtivos,
    );
  }

  Future<List<ClienteModel>> listarClientesResumo() {
    return service.listarClientesResumo();
  }

  Future<ClienteModel> buscarClientePorId(int idCliente) {
    return service.buscarClientePorId(idCliente);
  }

  Future<ClienteModel> criarCliente({
    required ClienteModel cliente,
    required int idPerfilCliente,
  }) {
    return service.criarCliente(
      cliente: cliente,
      idPerfilCliente: idPerfilCliente,
    );
  }

  Future<ClienteModel> editarCliente({
    required int idCliente,
    required ClienteModel cliente,
    required int idPerfilCliente,
  }) {
    return service.editarCliente(
      idCliente: idCliente,
      cliente: cliente,
      idPerfilCliente: idPerfilCliente,
    );
  }

  Future<ClienteModel> alterarAtivoCliente({
    required int idCliente,
    required bool ativo,
  }) {
    return service.alterarAtivoCliente(
      idCliente: idCliente,
      ativo: ativo,
    );
  }

  Future<ClienteModel> activarCliente(int idCliente) {
    return alterarAtivoCliente(
      idCliente: idCliente,
      ativo: true,
    );
  }

  Future<ClienteModel> desactivarCliente(int idCliente) {
    return alterarAtivoCliente(
      idCliente: idCliente,
      ativo: false,
    );
  }

  Future<void> definirSenha({
    required int idCliente,
    required String novaSenha,
  }) {
    return service.definirSenha(
      idCliente: idCliente,
      novaSenha: novaSenha,
    );
  }

  Future<void> alterarSenha({
    required int idCliente,
    required String senhaActual,
    required String novaSenha,
  }) {
    return service.alterarSenha(
      idCliente: idCliente,
      senhaActual: senhaActual,
      novaSenha: novaSenha,
    );
  }

  Future<void> trocarPrimeiraSenha({
    required int idCliente,
    required String novaSenha,
  }) {
    return service.trocarPrimeiraSenha(
      idCliente: idCliente,
      novaSenha: novaSenha,
    );
  }

  Future<void> resetarSenhaPadrao(int idCliente) {
    return service.resetarSenhaPadrao(idCliente);
  }

  Future<void> eliminarCliente(int idCliente) {
    return service.eliminarCliente(idCliente);
  }
}