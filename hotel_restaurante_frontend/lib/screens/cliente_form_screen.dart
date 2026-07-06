import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:flutter/material.dart';
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

class ClienteFormScreen extends StatefulWidget {
  const ClienteFormScreen({super.key});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  // final _apelidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _nuitCtrl = TextEditingController();

  ClienteModel? _clienteEdicao;
  PerfilClienteModel? _perfilSelecionado;

  bool _carregouArgumentos = false;
  bool _salvando = false;

  bool get _modoEdicao => _clienteEdicao != null;

  PerfilClienteModel? get _perfilEmpresarial {
  final perfis = context.read<ClienteProvider>().perfisCliente;

  final encontrados = perfis.where((perfil) {
    return perfil.nomePerfilCliente.trim().toLowerCase() == 'empresarial';
  });

  if (encontrados.isEmpty) {
    return null;
  }

  return encontrados.first;
}

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _carregarPerfisCliente();
      _carregarArgumentos();
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    // _apelidoCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _nuitCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfisCliente() async {
    final provider = context.read<ClienteProvider>();

    await provider.carregarPerfisCliente();
  }

  void _carregarArgumentos() {
    if (_carregouArgumentos) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is ClienteModel) {
      _clienteEdicao = args;

      _nomeCtrl.text = args.nome;
      // _apelidoCtrl.text = args.apelido ?? '';
      _emailCtrl.text = args.email ?? '';
      _telefoneCtrl.text = args.telefone ?? '';
      _nuitCtrl.text = args.nuit ?? '';

_perfilSelecionado = _perfilEmpresarial;
    }

    _carregouArgumentos = true;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

final perfilEmpresarial = _perfilEmpresarial;

if (perfilEmpresarial?.idPerfilCliente == null) {
  _snack(
    'O perfil empresarial não foi encontrado. Verifique a tabela perfil_cliente.',
    erro: true,
  );
  return;
}

_perfilSelecionado = perfilEmpresarial;

    setState(() => _salvando = true);

    try {
      final provider = context.read<ClienteProvider>();

      if (_modoEdicao) {
        final clienteAtual = _clienteEdicao!;

final cliente = clienteAtual.copyWith(
  nome: _nomeCtrl.text.trim(),
  // apelido: _textoOpcional(_apelidoCtrl.text),
  email: _textoOpcional(_emailCtrl.text),
  telefone: _textoOpcional(_telefoneCtrl.text),
  nuit: _textoOpcional(_nuitCtrl.text),
  perfilCliente: perfilEmpresarial,
);

await provider.editarCliente(
  idCliente: clienteAtual.idCliente!,
  cliente: cliente,
  idPerfilCliente: perfilEmpresarial!.idPerfilCliente!,
);

        if (mounted) {
          _snack('Cliente actualizado com sucesso.');
          Navigator.of(context).pop(true);
        }

        return;
      }

final cliente = ClienteModel(
  nome: _nomeCtrl.text.trim(),
  // apelido: _textoOpcional(_apelidoCtrl.text),
  email: _textoOpcional(_emailCtrl.text),
  telefone: _textoOpcional(_telefoneCtrl.text),
  nuit: _textoOpcional(_nuitCtrl.text),
  primeiraSenha: true,
  ativo: true,
  perfilCliente: perfilEmpresarial,
);

await provider.criarCliente(
  cliente: cliente,
  idPerfilCliente: perfilEmpresarial!.idPerfilCliente!,
);
      if (mounted) {
        _snack('Cliente criado. Senha inicial: 12345678');
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
    final provider = context.watch<ClienteProvider>();
    final perfisCliente = provider.perfisCliente;

if (_perfilSelecionado == null && perfisCliente.isNotEmpty) {
  final encontrados = perfisCliente.where((perfil) {
    return perfil.nomePerfilCliente.trim().toLowerCase() == 'empresarial';
  });

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
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _FormCard(
                      formKey: _formKey,
                      modoEdicao: _modoEdicao,
                      salvando: _salvando,
                      clienteEdicao: _clienteEdicao,
                      nomeCtrl: _nomeCtrl,
                      // apelidoCtrl: _apelidoCtrl,
                      emailCtrl: _emailCtrl,
                      telefoneCtrl: _telefoneCtrl,
                      nuitCtrl: _nuitCtrl,
                      perfisCliente: perfisCliente,
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
                  ? Icons.manage_accounts_rounded
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
                  modoEdicao ? 'Editar Cliente' : 'Novo Cliente',
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
                      ? 'Actualize os dados cadastrais, contacto e perfil do cliente.'
                      : 'O cliente será criado com a senha padrão 12345678.',
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

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool modoEdicao;
  final bool salvando;

  final ClienteModel? clienteEdicao;

  final TextEditingController nomeCtrl;
  // final TextEditingController apelidoCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController telefoneCtrl;
  final TextEditingController nuitCtrl;

  final List<PerfilClienteModel> perfisCliente;
  final PerfilClienteModel? perfilSelecionado;
  final ValueChanged<PerfilClienteModel?> onPerfilChanged;

  final VoidCallback onCancelar;
  final VoidCallback onSalvar;

  const _FormCard({
    required this.formKey,
    required this.modoEdicao,
    required this.salvando,
    required this.clienteEdicao,
    required this.nomeCtrl,
    // required this.apelidoCtrl,
    required this.emailCtrl,
    required this.telefoneCtrl,
    required this.nuitCtrl,
    required this.perfisCliente,
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
              if (modoEdicao && clienteEdicao != null) ...[
                _ClienteResumoHeader(cliente: clienteEdicao!),
                const SizedBox(height: 22),
              ],
              const _SectionTitle(
                icon: Icons.badge_outlined,
                title: 'Dados do cliente',
                subtitle:
                    'Preencha os dados básicos do cliente. E-mail, telefone e NUIT são opcionais.',
              ),
              const SizedBox(height: 18),
              _ResponsiveFields(
                children: [
                  _CampoTexto(
                    controller: nomeCtrl,
                    label: 'Nome',
                    hint: 'Ex: Ana',
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
                  // _CampoTexto(
                  //   controller: apelidoCtrl,
                  //   label: 'Apelido',
                  //   hint: 'Ex: Manuel',
                  //   icon: Icons.short_text_rounded,
                  //   enabled: !salvando,
                  //   validator: (value) {
                  //     if (value != null && value.trim().length > 120) {
                  //       return 'Máximo de 120 caracteres';
                  //     }

                  //     return null;
                  //   },
                  // ),
                  _CampoTexto(
                    controller: emailCtrl,
                    label: 'E-mail',
                    hint: 'cliente@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !salvando,
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) return null;

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
                  _CampoTexto(
                    controller: nuitCtrl,
                    label: 'NUIT',
                    hint: 'Ex: 400000000',
                    icon: Icons.confirmation_number_outlined,
                    keyboardType: TextInputType.number,
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
const _SectionTitle(
  icon: Icons.business_center_outlined,
  title: 'Tipo de cliente',
  subtitle:
      'Este formulário cadastra somente clientes empresariais.',
),
const SizedBox(height: 14),
_InfoBox(
  icon: Icons.business_rounded,
  title: 'Cliente empresarial',
  message:
      'O perfil empresarial será aplicado automaticamente no cadastro e na edição.',
  color: _kOrange,
),
const SizedBox(height: 18),
              modoEdicao
                  ? const _InfoBox(
                      icon: Icons.info_outline_rounded,
                      title: 'Actualização cadastral',
                      message:
                          'A alteração feita aqui actualiza os dados comerciais do cliente. '
                          'O estado activo/inactivo e a senha continuam disponíveis na tela de detalhes.',
                      color: _kDark,
                    )
                  : const _InfoBox(
                      icon: Icons.lock_outline_rounded,
                      title: 'Senha inicial automática',
                      message:
                          'A senha 12345678 será atribuída automaticamente. '
                          'No primeiro login, o cliente deverá criar uma nova senha.',
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
                                ? 'Actualizar Cliente'
                                : 'Criar Cliente',
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

class _ClienteResumoHeader extends StatelessWidget {
  final ClienteModel cliente;

  const _ClienteResumoHeader({
    required this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    final nome = cliente.nomeCompleto.trim().isNotEmpty
        ? cliente.nomeCompleto.trim()
        : cliente.nome.trim();

    final activo = cliente.ativo;

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
                  cliente.email ?? cliente.telefone ?? 'Sem contacto',
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

    if (partes.isEmpty || partes.first.isEmpty) return 'CL';

    if (partes.length == 1) {
      return partes.first
          .substring(0, partes.first.length >= 2 ? 2 : 1)
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