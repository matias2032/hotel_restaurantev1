// lib/screens/primeira_troca_senha_screen.dart

import 'package:flutter/material.dart';
import 'package:api_compartilhado/api_compartilhado.dart';

const _kDark = Color(0xFF111827);
const _kOrange = Color(0xFFF97316);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kText = Color(0xFF374151);
const _kMuted = Color(0xFF6B7280);
const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE5E7EB);

class PrimeiraTrocaSenhaScreen extends StatefulWidget {
  const PrimeiraTrocaSenhaScreen({super.key});

  @override
  State<PrimeiraTrocaSenhaScreen> createState() =>
      _PrimeiraTrocaSenhaScreenState();
}

class _PrimeiraTrocaSenhaScreenState extends State<PrimeiraTrocaSenhaScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _novaSenhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();

  final _authService = AutenticacaoService();

  bool _obscureNova = true;
  bool _obscureConfirmar = true;
  bool _carregando = false;

  String? _erro;

  int _forca = 0;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, .07),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOut,
      ),
    );

    _novaSenhaCtrl.addListener(_calcularForca);
    _confirmarSenhaCtrl.addListener(_actualizarTela);

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _novaSenhaCtrl.removeListener(_calcularForca);
    _confirmarSenhaCtrl.removeListener(_actualizarTela);

    _novaSenhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    _animCtrl.dispose();

    super.dispose();
  }

  void _actualizarTela() {
    if (mounted) {
      setState(() {});
    }
  }

  void _calcularForca() {
    final senha = _novaSenhaCtrl.text;

    int valor = 0;

    if (senha.length >= 8) valor++;
    if (RegExp(r'[A-Z]').hasMatch(senha)) valor++;
    if (RegExp(r'[0-9]').hasMatch(senha)) valor++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=]').hasMatch(senha)) valor++;

    setState(() => _forca = valor);
  }

  String get _forcaLabel {
    switch (_forca) {
      case 0:
      case 1:
        return 'Fraca';
      case 2:
        return 'Razoável';
      case 3:
        return 'Boa';
      case 4:
        return 'Excelente';
      default:
        return '';
    }
  }

  Color get _forcaColor {
    switch (_forca) {
      case 0:
      case 1:
        return _kRed;
      case 2:
        return _kOrange;
      case 3:
      case 4:
        return _kGreen;
      default:
        return _kBorder;
    }
  }

  UsuarioModel? get _usuario => SessaoService.instance.usuario;

  String get _nomeUsuario {
    final usuario = _usuario;

    if (usuario == null) return 'Usuário';

    if (usuario.nomeCompleto.trim().isNotEmpty) {
      return usuario.nomeCompleto.trim();
    }

    final nome = usuario.nome.trim();
    final apelido = usuario.apelido?.trim() ?? '';

    return '$nome $apelido'.trim();
  }

  String get _nomePerfil {
    return _usuario?.perfil?.nomePerfil ?? 'Sem perfil';
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final usuario = _usuario;

    if (usuario?.idUsuario == null) {
      setState(() {
        _erro = 'Sessão inválida. Faça login novamente.';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final result = await _authService.trocarPrimeiraSenha(
        idUsuario: usuario!.idUsuario!,
        novaSenha: _novaSenhaCtrl.text,
      );

      if (!mounted) return;

      if (result.status == StatusAutenticacao.sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.mensagem ?? 'Senha alterada com sucesso.'),
            backgroundColor: _kGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 900));

        if (!mounted) return;

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (_) => false,
        );

        return;
      }

      setState(() {
        _erro = result.mensagem ?? 'Não foi possível alterar a senha.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<bool> _bloquearVoltar() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;

    return WillPopScope(
      onWillPop: _bloquearVoltar,
      child: Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const _HeaderPrimeiraSenha(),
                        Transform.translate(
                          offset: const Offset(0, -22),
                          child: _UsuarioChip(
                            nome: _nomeUsuario,
                            perfil: _nomePerfil,
                            email: usuario?.email,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: _SenhaCard(
                            novaSenhaCtrl: _novaSenhaCtrl,
                            confirmarSenhaCtrl: _confirmarSenhaCtrl,
                            obscureNova: _obscureNova,
                            obscureConfirmar: _obscureConfirmar,
                            carregando: _carregando,
                            erro: _erro,
                            forca: _forca,
                            forcaLabel: _forcaLabel,
                            forcaColor: _forcaColor,
                            onToggleNova: () {
                              setState(() => _obscureNova = !_obscureNova);
                            },
                            onToggleConfirmar: () {
                              setState(
                                () => _obscureConfirmar = !_obscureConfirmar,
                              );
                            },
                            onSubmit: _confirmar,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderPrimeiraSenha extends StatelessWidget {
  const _HeaderPrimeiraSenha();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 32, 30, 52),
      decoration: const BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _kOrange.withOpacity(.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _kOrange.withOpacity(.28)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _kOrange,
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  'ACÇÃO OBRIGATÓRIA',
                  style: TextStyle(
                    color: _kOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 66,
            width: 66,
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Definir nova senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Por segurança, a senha inicial precisa ser alterada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.65),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsuarioChip extends StatelessWidget {
  final String nome;
  final String perfil;
  final String? email;

  const _UsuarioChip({
    required this.nome,
    required this.perfil,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _iniciais(nome),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _kDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email ?? perfil,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _kMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _kOrange.withOpacity(.09),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              perfil,
              style: const TextStyle(
                color: _kOrange,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));

    if (partes.isEmpty || partes.first.isEmpty) {
      return 'US';
    }

    if (partes.length == 1) {
      return partes.first.substring(0, partes.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }
}

class _SenhaCard extends StatelessWidget {
  final TextEditingController novaSenhaCtrl;
  final TextEditingController confirmarSenhaCtrl;

  final bool obscureNova;
  final bool obscureConfirmar;
  final bool carregando;
  final String? erro;

  final int forca;
  final String forcaLabel;
  final Color forcaColor;

  final VoidCallback onToggleNova;
  final VoidCallback onToggleConfirmar;
  final VoidCallback onSubmit;

  const _SenhaCard({
    required this.novaSenhaCtrl,
    required this.confirmarSenhaCtrl,
    required this.obscureNova,
    required this.obscureConfirmar,
    required this.carregando,
    required this.erro,
    required this.forca,
    required this.forcaLabel,
    required this.forcaColor,
    required this.onToggleNova,
    required this.onToggleConfirmar,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final senha = novaSenhaCtrl.text;
    final confirmar = confirmarSenhaCtrl.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 30),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Crie uma senha pessoal',
            subtitle:
                'Esta senha substituirá a senha padrão 12345678 no próximo acesso.',
          ),
          const SizedBox(height: 20),
          _CampoSenha(
            controller: novaSenhaCtrl,
            label: 'Nova senha',
            hint: 'Mínimo 8 caracteres',
            obscureText: obscureNova,
            enabled: !carregando,
            onToggle: onToggleNova,
            validator: (value) {
              final text = value ?? '';

              if (text.isEmpty) {
                return 'Digite a nova senha.';
              }

              if (text.length < 8) {
                return 'A senha deve ter pelo menos 8 caracteres.';
              }

              if (text == '12345678') {
                return 'Não utilize a senha padrão.';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          _ForcaSenhaBar(
            forca: forca,
            label: senha.isEmpty ? '' : forcaLabel,
            color: forcaColor,
          ),
          const SizedBox(height: 16),
          _CampoSenha(
            controller: confirmarSenhaCtrl,
            label: 'Confirmar senha',
            hint: 'Repita a nova senha',
            obscureText: obscureConfirmar,
            enabled: !carregando,
            onToggle: onToggleConfirmar,
            onSubmitted: (_) => onSubmit(),
            validator: (value) {
              final text = value ?? '';

              if (text.isEmpty) {
                return 'Confirme a nova senha.';
              }

              if (text != novaSenhaCtrl.text) {
                return 'As senhas não coincidem.';
              }

              return null;
            },
          ),
          const SizedBox(height: 18),
          _RequisitosSenha(
            senha: senha,
            confirmar: confirmar,
          ),
          if (erro != null && erro!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _ErroBox(message: erro!),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: carregando ? null : onSubmit,
              icon: carregando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 19),
              label: Text(
                carregando ? 'A guardar...' : 'Confirmar nova senha',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _kOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: _kOrange.withOpacity(.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.security_rounded,
            color: _kOrange,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _kDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _kMuted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CampoSenha extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final bool enabled;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _CampoSenha({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.enabled,
    required this.onToggle,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(
        color: _kText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: _kMuted,
          size: 20,
        ),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggle : null,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _kMuted,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kOrange, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _kRed, width: 1.4),
        ),
      ),
    );
  }
}

class _ForcaSenhaBar extends StatelessWidget {
  final int forca;
  final String label;
  final Color color;

  const _ForcaSenhaBar({
    required this.forca,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: List.generate(4, (index) {
            final activo = index < forca;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
                height: 4,
                decoration: BoxDecoration(
                  color: activo ? color : _kBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

class _RequisitosSenha extends StatelessWidget {
  final String senha;
  final String confirmar;

  const _RequisitosSenha({
    required this.senha,
    required this.confirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kDark.withOpacity(.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: _kDark,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Requisitos da senha',
                style: TextStyle(
                  color: _kDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ReqItem(
            label: 'Mínimo 8 caracteres',
            ok: senha.length >= 8,
          ),
          _ReqItem(
            label: 'Diferente da senha padrão',
            ok: senha.isNotEmpty && senha != '12345678',
          ),
          _ReqItem(
            label: 'Confirmação igual à nova senha',
            ok: senha.isNotEmpty && senha == confirmar,
          ),
        ],
      ),
    );
  }
}

class _ReqItem extends StatelessWidget {
  final String label;
  final bool ok;

  const _ReqItem({
    required this.label,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            ok
                ? Icons.check_circle_outline_rounded
                : Icons.radio_button_unchecked_rounded,
            color: ok ? _kGreen : _kMuted,
            size: 17,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: ok ? _kGreen : _kMuted,
              fontSize: 12,
              fontWeight: ok ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErroBox extends StatelessWidget {
  final String message;

  const _ErroBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _kRed.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kRed.withOpacity(.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: _kRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _kRed,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}