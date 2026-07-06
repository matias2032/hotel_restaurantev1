import '../models/usuario_model.dart';

class SessaoService {
  SessaoService._();

  static final SessaoService instance = SessaoService._();

  UsuarioModel? _usuario;
  String? _accessToken;
  String _tokenType = 'Bearer';

  UsuarioModel? get usuario => _usuario;

  UsuarioModel? get usuarioAtual => _usuario;

  bool get temSessao => _usuario != null && temToken;

  int? get idUsuario => _usuario?.idUsuario;

  String? get accessToken => _accessToken;

  String get tokenType => _tokenType;

  bool get temToken {
    return _accessToken != null && _accessToken!.trim().isNotEmpty;
  }

  String? get authorizationHeader {
    if (!temToken) return null;
    return '$_tokenType $_accessToken';
  }

  bool get primeiraSenhaPendente {
    return _usuario?.primeiraSenha == true;
  }

  bool get usuarioAtivo {
    return _usuario?.ativo == true;
  }

  void iniciar(
    UsuarioModel usuario, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) {
    _usuario = usuario;
    _accessToken = accessToken;
    _tokenType = tokenType;
  }

  void actualizarUsuario(UsuarioModel usuario) {
    _usuario = usuario;
  }

  void actualizarToken({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    _accessToken = accessToken;
    _tokenType = tokenType;
  }

  void encerrar() {
    _usuario = null;
    _accessToken = null;
    _tokenType = 'Bearer';
  }

  void limparSessao() => encerrar();
}