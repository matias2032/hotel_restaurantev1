// lib/screens/usuario_form_screen.dart

import 'package:api_compartilhado/api_compartilhado.dart';
import 'usuario_list_screen.dart';
import 'usuario_detalhes_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

const _kDark = Color(0xFF111827);
const _kOrange = Color(0xFFF97316);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kText = Color(0xFF374151);
const _kMuted = Color(0xFF6B7280);
const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE5E7EB);

class UsuarioFormScreen extends StatefulWidget {
  const UsuarioFormScreen({super.key});

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _apelidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();

  UsuarioModel? _usuarioEdicao;
  PerfilModel? _perfilSelecionado;

  bool _carregouArgumentos = false;
  bool _salvando = false;

  bool get _modoEdicao => _usuarioEdicao != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _carregarPerfis();
      _carregarArgumentos();
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _apelidoCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfis() async {
    final provider = context.read<UsuarioProvider>();
    await provider.carregarPerfis(somenteAtivos: true);
  }

  void _carregarArgumentos() {
    if (_carregouArgumentos) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is UsuarioModel) {
      _usuarioEdicao = args;

      _nomeCtrl.text = args.nome;
      _apelidoCtrl.text = args.apelido ?? '';
      _emailCtrl.text = args.email ?? '';
      _telefoneCtrl.text = args.telefone ?? '';

      final perfis = _perfisPermitidos();

      _perfilSelecionado = perfis
          .where((p) => p.idPerfil == args.perfil?.idPerfil)
          .cast<PerfilModel?>()
          .firstOrNull;
    }

    _carregouArgumentos = true;

    if (mounted) {
      setState(() {});
    }
  }

  List<PerfilModel> _perfisPermitidos() {
    final provider = context.read<UsuarioProvider>();

    return provider.perfis.where((perfil) {
      return perfil.nomePerfil.trim().toLowerCase() != 'administrador';
    }).toList();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_perfilSelecionado == null || _perfilSelecionado!.idPerfil == null) {
      _snack('Seleccione um perfil válido.', erro: true);
      return;
    }

    final perfilNome = _perfilSelecionado!.nomePerfil.trim().toLowerCase();

    if (perfilNome == 'administrador') {
      _snack('Não é permitido cadastrar ou atribuir o perfil Administrador.',
          erro: true);
      return;
    }

    setState(() => _salvando = true);

    try {
      final provider = context.read<UsuarioProvider>();

      if (_modoEdicao) {
        final usuarioAtual = _usuarioEdicao!;

        final usuario = usuarioAtual.copyWith(
          perfil: _perfilSelecionado,
        );

        await provider.editarUsuario(
          idUsuario: usuarioAtual.idUsuario!,
          usuario: usuario,
          idPerfil: _perfilSelecionado!.idPerfil!,
        );

        if (mounted) {
          _snack('Perfil do usuário actualizado com sucesso.');
          Navigator.of(context).pop(true);
        }

        return;
      }

    final usuario = UsuarioModel(
  nome: _nomeCtrl.text.trim(),
  apelido: _textoOpcional(_apelidoCtrl.text),
  email: _textoOpcional(_emailCtrl.text),
  telefone: _textoOpcional(_telefoneCtrl.text),
  primeiraSenha: true,
  status: true,
  perfil: _perfilSelecionado,
);

      await provider.criarUsuario(
        usuario: usuario,
        idPerfil: _perfilSelecionado!.idPerfil!,
      );

      if (mounted) {
        _snack('Usuário criado. Senha inicial: 12345678');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _snack(
          e.toString().replaceFirst('Exception: ', ''),
          erro: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  String? _textoOpcional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _snack(String message, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: erro ? _kRed : _kDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsuarioProvider>();
    final perfis = provider.perfis.where((perfil) {
      return perfil.nomePerfil.trim().toLowerCase() != 'administrador';
    }).toList();

    if (_modoEdicao &&
        _perfilSelecionado == null &&
        _usuarioEdicao?.perfil?.idPerfil != null &&
        perfis.isNotEmpty) {
      final idPerfilActual = _usuarioEdicao!.perfil!.idPerfil;

      final encontrados = perfis.where((p) => p.idPerfil == idPerfilActual);

      if (encontrados.isNotEmpty) {
        _perfilSelecionado = encontrados.first;
      }
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              modoEdicao: _modoEdicao,
              onBack: () => Navigator.of(context).pop(false),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _FormCard(
                      formKey: _formKey,
                      modoEdicao: _modoEdicao,
                      salvando: _salvando,
                      usuarioEdicao: _usuarioEdicao,
                      nomeCtrl: _nomeCtrl,
                      apelidoCtrl: _apelidoCtrl,
                      emailCtrl: _emailCtrl,
                      telefoneCtrl: _telefoneCtrl,
                      perfis: perfis,
                      perfilSelecionado: _perfilSelecionado,
                      onPerfilChanged: (perfil) {
                        setState(() => _perfilSelecionado = perfil);
                      },
                      onCancelar: () => Navigator.of(context).pop(false),
                      onSalvar: _salvar,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool modoEdicao;
  final VoidCallback onBack;

  const _Header({
    required this.modoEdicao,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDark,
      padding: const EdgeInsets.fromLTRB(14, 16, 22, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              modoEdicao
                  ? Icons.admin_panel_settings_rounded
                  : Icons.person_add_alt_1_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modoEdicao ? 'Editar Perfil do Usuário' : 'Novo Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  modoEdicao
                      ? 'Nesta fase, somente o perfil de acesso pode ser alterado.'
                      : 'O usuário será criado com a senha padrão 12345678.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FORM CARD
// ─────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool modoEdicao;
  final bool salvando;

  final UsuarioModel? usuarioEdicao;

  final TextEditingController nomeCtrl;
  final TextEditingController apelidoCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController telefoneCtrl;

  final List<PerfilModel> perfis;
  final PerfilModel? perfilSelecionado;
  final ValueChanged<PerfilModel?> onPerfilChanged;

  final VoidCallback onCancelar;
  final VoidCallback onSalvar;

  const _FormCard({
    required this.formKey,
    required this.modoEdicao,
    required this.salvando,
    required this.usuarioEdicao,
    required this.nomeCtrl,
    required this.apelidoCtrl,
    required this.emailCtrl,
    required this.telefoneCtrl,
    required this.perfis,
    required this.perfilSelecionado,
    required this.onPerfilChanged,
    required this.onCancelar,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCard,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (modoEdicao && usuarioEdicao != null) ...[
                _UsuarioResumoHeader(usuario: usuarioEdicao!),
                const SizedBox(height: 22),
              ],
              if (!modoEdicao) ...[
                const _SectionTitle(
                  icon: Icons.badge_outlined,
                  title: 'Dados pessoais',
                  subtitle:
                      'Preencha os dados básicos do colaborador interno.',
                ),
                const SizedBox(height: 18),
                _ResponsiveFields(
                  children: [
                    _CampoTexto(
                      controller: nomeCtrl,
                      label: 'Nome',
                      hint: 'Ex: João',
                      icon: Icons.person_outline_rounded,
                      enabled: !salvando,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O nome é obrigatório';
                        }

                        if (value.trim().length > 120) {
                          return 'Máximo de 120 caracteres';
                        }

                        return null;
                      },
                    ),
                    _CampoTexto(
                      controller: apelidoCtrl,
                      label: 'Apelido',
                      hint: 'Ex: Manuel',
                      icon: Icons.short_text_rounded,
                      enabled: !salvando,
                      validator: (value) {
                        if (value != null && value.trim().length > 120) {
                          return 'Máximo de 120 caracteres';
                        }

                        return null;
                      },
                    ),
                    _CampoTexto(
                      controller: emailCtrl,
                      label: 'E-mail',
                      hint: 'usuario@empresa.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !salvando,
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.isEmpty) {
                          return null;
                        }

                        final emailRegex = RegExp(
                          r'^[\w\.-]+@[\w\.-]+\.\w+$',
                        );

                        if (!emailRegex.hasMatch(text)) {
                          return 'E-mail inválido';
                        }

                        if (text.length > 160) {
                          return 'Máximo de 160 caracteres';
                        }

                        return null;
                      },
                    ),
                    _CampoTexto(
                      controller: telefoneCtrl,
                      label: 'Telefone',
                      hint: '+258 8x xxx xxxx',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: !salvando,
                      validator: (value) {
                        if (value != null && value.trim().length > 30) {
                          return 'Máximo de 30 caracteres';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              const _SectionTitle(
                icon: Icons.shield_outlined,
                title: 'Perfil de acesso',
                subtitle:
                    'O perfil Administrador fica protegido e não pode ser escolhido neste formulário.',
              ),
              const SizedBox(height: 14),
              _DropdownPerfil(
                perfis: perfis,
                perfilSelecionado: perfilSelecionado,
                enabled: !salvando,
                onChanged: onPerfilChanged,
              ),
              const SizedBox(height: 18),
              modoEdicao
                  ? const _InfoBox(
                      icon: Icons.info_outline_rounded,
                      title: 'Edição limitada',
                      message:
                          'Por segurança, nesta tela só é possível alterar o perfil do usuário. '
                          'Dados pessoais e senha seguem fluxos próprios.',
                      color: _kDark,
                    )
                  : const _InfoBox(
                      icon: Icons.lock_outline_rounded,
                      title: 'Senha inicial automática',
                      message:
                          'A senha 12345678 será atribuída automaticamente. '
                          'No primeiro login, o usuário deverá criar uma nova senha.',
                      color: _kOrange,
                    ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: salvando ? null : onCancelar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kMuted,
                        side: const BorderSide(color: _kBorder),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: salvando ? null : onSalvar,
                      icon: salvando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              modoEdicao
                                  ? Icons.save_as_rounded
                                  : Icons.person_add_alt_1_rounded,
                              size: 19,
                            ),
                      label: Text(
                        salvando
                            ? 'A guardar...'
                            : modoEdicao
                                ? 'Actualizar Perfil'
                                : 'Criar Usuário',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _kOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPONENTES
// ─────────────────────────────────────────────────────────────

class _UsuarioResumoHeader extends StatelessWidget {
  final UsuarioModel usuario;

  const _UsuarioResumoHeader({
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    final nome = usuario.nomeCompleto.isNotEmpty
        ? usuario.nomeCompleto
        : usuario.nome;

final activo = usuario.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 54,
                width: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kDark,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _iniciais(nome),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    color: activo ? _kGreen : _kRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.email ?? 'Sem email',
                  style: const TextStyle(
                    color: _kMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(activo: activo),
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

class _StatusChip extends StatelessWidget {
  final bool activo;

  const _StatusChip({
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? _kGreen : _kRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: _kOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _kOrange, size: 20),
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
                  fontSize: 15,
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

class _ResponsiveFields extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFields({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final twoColumns = constraints.maxWidth >= 680;

        if (!twoColumns) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children
              .map(
                (child) => SizedBox(
                  width: (constraints.maxWidth - 14) / 2,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _CampoTexto({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: _kText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _kMuted, size: 20),
      ),
    );
  }
}

class _DropdownPerfil extends StatelessWidget {
  final List<PerfilModel> perfis;
  final PerfilModel? perfilSelecionado;
  final bool enabled;
  final ValueChanged<PerfilModel?> onChanged;

  const _DropdownPerfil({
    required this.perfis,
    required this.perfilSelecionado,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (perfis.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kRed.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kRed.withOpacity(0.25)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _kRed),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nenhum perfil disponível. Verifique se existem perfis activos diferentes de Administrador.',
                style: TextStyle(
                  color: _kRed,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<PerfilModel>(
      value: perfilSelecionado,
      isExpanded: true,
      items: perfis.map((perfil) {
        return DropdownMenuItem<PerfilModel>(
          value: perfil,
          child: Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: _kMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  perfil.nomePerfil,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null) {
          return 'Seleccione um perfil';
        }

        if (value.nomePerfil.trim().toLowerCase() == 'administrador') {
          return 'O perfil Administrador não pode ser seleccionado';
        }

        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Perfil',
        hintText: 'Seleccione o perfil do usuário',
        prefixIcon: Icon(Icons.shield_outlined),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: _kMuted,
                    fontSize: 12,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}