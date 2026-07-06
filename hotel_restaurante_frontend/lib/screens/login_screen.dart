// lib/screens/login_screen.dart

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _credencialCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  final _authService = AutenticacaoService();

  bool _obscureSenha = true;
  bool _carregando = false;
  String? _erro;

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

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _credencialCtrl.dispose();
    _senhaCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final result = await _authService.login(
        credencial: _credencialCtrl.text.trim(),
        senha: _senhaCtrl.text,
      );

      if (!mounted) return;

      switch (result.status) {
        case StatusAutenticacao.sucesso:
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/clientes',
            (_) => false,
          );
          return;

        case StatusAutenticacao.primeiraSenha:
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/primeira-senha',
            (_) => false,
          );
          return;

        case StatusAutenticacao.usuarioInativo:
          setState(() {
            _erro = result.mensagem ?? 'Este usuário está inactivo.';
          });
          return;

        case StatusAutenticacao.credenciaisInvalidas:
          setState(() {
            _erro = result.mensagem ?? 'Credencial ou senha incorrectos.';
          });
          return;

        case StatusAutenticacao.erroDesconhecido:
          setState(() {
            _erro = result.mensagem ?? 'Não foi possível iniciar sessão.';
          });
          return;
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _LoginHeader(),
                      _LoginCard(
                        credencialCtrl: _credencialCtrl,
                        senhaCtrl: _senhaCtrl,
                        obscureSenha: _obscureSenha,
                        carregando: _carregando,
                        erro: _erro,
                        onToggleSenha: () {
                          setState(() => _obscureSenha = !_obscureSenha);
                        },
                        onSubmit: _entrar,
                      ),
                    ],
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

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 34, 30, 48),
      decoration: const BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _kOrange.withOpacity(.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.hotel_class_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Hotel Restaurante Admin',
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
            'Entre para gerir usuários, hotel, restaurante e operações.',
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

class _LoginCard extends StatelessWidget {
  final TextEditingController credencialCtrl;
  final TextEditingController senhaCtrl;

  final bool obscureSenha;
  final bool carregando;
  final String? erro;

  final VoidCallback onToggleSenha;
  final VoidCallback onSubmit;

  const _LoginCard({
    required this.credencialCtrl,
    required this.senhaCtrl,
    required this.obscureSenha,
    required this.carregando,
    required this.erro,
    required this.onToggleSenha,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
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
            title: 'Acesso ao sistema',
            subtitle: 'Use o e-mail, telefone ou apelido cadastrado.',
          ),
          const SizedBox(height: 20),
          _CampoLogin(
            controller: credencialCtrl,
            label: 'Credencial',
            hint: 'E-mail, telefone ou apelido',
            icon: Icons.person_outline_rounded,
            enabled: !carregando,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.isEmpty) {
                return 'Informe a credencial.';
              }

              return null;
            },
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 16),
          _CampoLogin(
            controller: senhaCtrl,
            label: 'Senha',
            hint: 'Digite a sua senha',
            icon: Icons.lock_outline_rounded,
            enabled: !carregando,
            obscureText: obscureSenha,
            suffixIcon: IconButton(
              onPressed: carregando ? null : onToggleSenha,
              icon: Icon(
                obscureSenha
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _kMuted,
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a senha.';
              }

              return null;
            },
            onSubmitted: (_) => onSubmit(),
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
                  : const Icon(Icons.login_rounded, size: 19),
              label: Text(
                carregando ? 'A entrar...' : 'Entrar',
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
          const SizedBox(height: 14),
          const _LoginHint(),
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
            Icons.shield_outlined,
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

class _CampoLogin extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _CampoLogin({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
        prefixIcon: Icon(icon, color: _kMuted, size: 20),
        suffixIcon: suffixIcon,
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

class _LoginHint extends StatelessWidget {
  const _LoginHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _kDark.withOpacity(.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _kMuted,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No primeiro acesso, será obrigatório trocar a senha padrão 12345678.',
              style: TextStyle(
                color: _kMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}