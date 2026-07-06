import 'usuario_model.dart';

enum StatusAutenticacao {
  sucesso,
  primeiraSenha,
  credenciaisInvalidas,
  usuarioInativo,
  erroDesconhecido,
}

class ResultadoAutenticacao {
  final StatusAutenticacao status;
  final String? mensagem;
  final UsuarioModel? usuario;

  final String? accessToken;
  final String tokenType;
  final int? expiresInMinutes;

  const ResultadoAutenticacao({
    required this.status,
    this.mensagem,
    this.usuario,
    this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresInMinutes,
  });

  bool get sucesso => status == StatusAutenticacao.sucesso;

  bool get exigePrimeiraSenha =>
      status == StatusAutenticacao.primeiraSenha;

  bool get temToken => accessToken != null && accessToken!.trim().isNotEmpty;
}