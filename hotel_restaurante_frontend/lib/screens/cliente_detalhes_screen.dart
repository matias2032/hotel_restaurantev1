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

class ClienteDetalhesScreen extends StatefulWidget {
  const ClienteDetalhesScreen({super.key});

  @override
  State<ClienteDetalhesScreen> createState() => _ClienteDetalhesScreenState();
}

class _ClienteDetalhesScreenState extends State<ClienteDetalhesScreen> {
  ClienteModel? _cliente;
  bool _carregouArgumentos = false;
  bool _processando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_carregouArgumentos) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is ClienteModel) {
      _cliente = args;
    }

    _carregouArgumentos = true;
  }

  bool get _activo {
    return _cliente?.ativo ?? false;
  }

  String get _nomePerfilCliente {
    return _cliente?.perfilCliente?.nomePerfilCliente ?? 'Sem perfil';
  }

  String get _nomeCompleto {
    final cliente = _cliente;

    if (cliente == null) return '';

    if (cliente.nomeCompleto.trim().isNotEmpty) {
      return cliente.nomeCompleto.trim();
    }

    final nome = cliente.nome.trim();
    final apelido = cliente.apelido?.trim() ?? '';

    return '$nome $apelido'.trim();
  }

  Future<void> _editarCliente() async {
    final cliente = _cliente;

    if (cliente == null) return;

    final result = await Navigator.of(context).pushNamed(
      '/clientes/form',
      arguments: cliente,
    );

    if (result == true && mounted) {
      await _recarregarCliente();
    }
  }

  Future<void> _recarregarCliente() async {
    final cliente = _cliente;

    if (cliente?.idCliente == null) return;

    final provider = context.read<ClienteProvider>();

    final actualizado = await provider.buscarClientePorId(cliente!.idCliente!);

    if (mounted && actualizado != null) {
      setState(() => _cliente = actualizado);
    }
  }

  Future<void> _confirmarToggle() async {
    final cliente = _cliente;

    if (cliente?.idCliente == null) return;

    final acao = _activo ? 'desactivar' : 'activar';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: _activo ? 'Desactivar cliente' : 'Activar cliente',
        message: 'Deseja $acao $_nomeCompleto?',
        confirmLabel: _activo ? 'Desactivar' : 'Activar',
        danger: _activo,
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _processando = true);

    try {
      final provider = context.read<ClienteProvider>();

      if (_activo) {
        await provider.desactivarCliente(cliente!.idCliente!);
        _snack('Cliente desactivado com sucesso.');
      } else {
        await provider.activarCliente(cliente!.idCliente!);
        _snack('Cliente activado com sucesso.');
      }

      await _recarregarCliente();
    } catch (e) {
      _snack(
        e.toString().replaceFirst('Exception: ', ''),
        erro: true,
      );
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _confirmarResetSenha() async {
    final cliente = _cliente;

    if (cliente?.idCliente == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Resetar senha',
        message:
            'A senha de $_nomeCompleto será redefinida para 12345678. '
            'No próximo login, o cliente deverá criar uma nova senha.',
        confirmLabel: 'Resetar senha',
        danger: true,
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _processando = true);

    try {
      await context.read<ClienteProvider>().resetarSenhaPadrao(
            cliente!.idCliente!,
          );

      _snack('Senha redefinida para 12345678.');
      await _recarregarCliente();
    } catch (e) {
      _snack(
        e.toString().replaceFirst('Exception: ', ''),
        erro: true,
      );
    } finally {
      if (mounted) setState(() => _processando = false);
    }
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
    final cliente = _cliente;

    if (cliente == null) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          title: const Text('Detalhes do cliente'),
        ),
        body: const _EstadoCentral(
          icon: Icons.person_off_rounded,
          title: 'Cliente não informado',
          message: 'Volte para a lista e seleccione um cliente válido.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderDetalhes(
              nome: _nomeCompleto,
              contacto: cliente.email ?? cliente.telefone,
              perfil: _nomePerfilCliente,
              activo: _activo,
              primeiraSenha: cliente.primeiraSenha,
              onBack: () => Navigator.of(context).pop(true),
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _processando,
                child: Stack(
                  children: [
                    RefreshIndicator(
                      color: _kOrange,
                      onRefresh: _recarregarCliente,
                      child: ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          _ResumoRapido(
                            cliente: cliente,
                            activo: _activo,
                            nomePerfilCliente: _nomePerfilCliente,
                          ),
                          const SizedBox(height: 14),
                          _CardSecao(
                            icon: Icons.person_outline_rounded,
                            title: 'Dados do cliente',
                            children: [
                              _InfoLinha(
                                icon: Icons.badge_outlined,
                                label: 'ID',
                                value: '#${cliente.idCliente ?? '-'}',
                              ),
                              _InfoLinha(
                                icon: Icons.person_rounded,
                                label: 'Nome da empresa',
                                value: cliente.nome,
                              ),
                              // _InfoLinha(
                              //   icon: Icons.short_text_rounded,
                              //   label: 'Apelido',
                              //   value: cliente.apelido ?? '-',
                              // ),
                              _InfoLinha(
                                icon: Icons.email_outlined,
                                label: 'E-mail',
                                value: cliente.email ?? '-',
                              ),
                              _InfoLinha(
                                icon: Icons.phone_outlined,
                                label: 'Telefone',
                                value: cliente.telefone ?? '-',
                              ),
                              _InfoLinha(
                                icon: Icons.confirmation_number_outlined,
                                label: 'NUIT',
                                value: cliente.nuit ?? '-',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _CardSecao(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Tipo de Cliente',
                            children: [
                              _InfoLinha(
                                icon: Icons.verified_user_outlined,
                                label: 'Perfil',
                                value: _nomePerfilCliente,
                              ),
                              _InfoLinha(
                                icon: _activo
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.block_rounded,
                                label: 'Estado',
                                value: _activo ? 'Activo' : 'Inactivo',
                                valueColor: _activo ? _kGreen : _kRed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _CardSecao(
                            icon: Icons.security_rounded,
                            title: 'Segurança',
                            children: [
                              _InfoLinha(
                                icon: Icons.lock_outline_rounded,
                                label: 'Senha',
                                value: cliente.primeiraSenha
                                    ? 'Senha inicial pendente'
                                    : 'Senha personalizada',
                                valueColor: cliente.primeiraSenha
                                    ? _kOrange
                                    : _kGreen,
                              ),
                              const SizedBox(height: 10),
                              cliente.primeiraSenha
                                  ? const _AvisoSeguranca(
                                      title: 'Troca obrigatória pendente',
                                      message:
                                          'Este cliente ainda está com a senha inicial. '
                                          'Ao entrar no sistema, deverá definir uma nova senha.',
                                      color: _kOrange,
                                    )
                                  : const _AvisoSeguranca(
                                      title: 'Senha já personalizada',
                                      message:
                                          'Este cliente já alterou a senha inicial.',
                                      color: _kGreen,
                                    ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _CardSecao(
                            icon: Icons.timeline_rounded,
                            title: 'Registo',
                            children: [
                              _InfoLinha(
                                icon: Icons.calendar_today_outlined,
                                label: 'Criado em',
                                value: _formatarDataHora(cliente.createdAt),
                              ),
                              _InfoLinha(
                                icon: Icons.update_rounded,
                                label: 'Actualizado em',
                                value: _formatarDataHora(cliente.updatedAt),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _AcoesDetalhes(
                            activo: _activo,
                            onEditarCliente: _editarCliente,
                            onToggle: _confirmarToggle,
                            onResetSenha: _confirmarResetSenha,
                          ),
                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                    if (_processando)
                      Container(
                        color: Colors.white.withOpacity(0.55),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: _kOrange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) return '-';

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }
}

class _HeaderDetalhes extends StatelessWidget {
  final String nome;
  final String? contacto;
  final String perfil;
  final bool activo;
  final bool primeiraSenha;
  final VoidCallback onBack;

  const _HeaderDetalhes({
    required this.nome,
    required this.contacto,
    required this.perfil,
    required this.activo,
    required this.primeiraSenha,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDark,
      padding: const EdgeInsets.fromLTRB(14, 16, 22, 22),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          _AvatarGrande(
            nome: nome,
            activo: activo,
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
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contacto ?? 'Sem contacto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderPill(
                      label: perfil,
                      color: _kOrange,
                      icon: Icons.workspace_premium_outlined,
                    ),
                    _HeaderPill(
                      label: activo ? 'Activo' : 'Inactivo',
                      color: activo ? _kGreen : _kRed,
                      icon: activo
                          ? Icons.check_circle_outline_rounded
                          : Icons.block_rounded,
                    ),
                    if (primeiraSenha)
                      const _HeaderPill(
                        label: 'Senha inicial',
                        color: _kOrange,
                        icon: Icons.lock_outline_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarGrande extends StatelessWidget {
  final String nome;
  final bool activo;

  const _AvatarGrande({
    required this.nome,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 62,
          width: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _kOrange,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            _iniciais(nome),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            height: 17,
            width: 17,
            decoration: BoxDecoration(
              color: activo ? _kGreen : _kRed,
              shape: BoxShape.circle,
              border: Border.all(color: _kDark, width: 3),
            ),
          ),
        ),
      ],
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

class _HeaderPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _HeaderPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoRapido extends StatelessWidget {
  final ClienteModel cliente;
  final bool activo;
  final String nomePerfilCliente;

  const _ResumoRapido({
    required this.cliente,
    required this.activo,
    required this.nomePerfilCliente,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final compact = constraints.maxWidth < 720;

        final cards = [
          _ResumoBox(
            icon: activo
                ? Icons.check_circle_outline_rounded
                : Icons.block_rounded,
            label: 'Estado',
            value: activo ? 'Activo' : 'Inactivo',
            color: activo ? _kGreen : _kRed,
          ),
          _ResumoBox(
            icon: Icons.workspace_premium_outlined,
            label: 'Perfil',
            value: nomePerfilCliente,
            color: _kDark,
          ),
          _ResumoBox(
            icon: Icons.lock_outline_rounded,
            label: 'Senha',
            value: cliente.primeiraSenha ? 'Inicial' : 'Definida',
            color: cliente.primeiraSenha ? _kOrange : _kGreen,
          ),
        ];

        if (compact) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ResumoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResumoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _kMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

class _CardSecao extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _CardSecao({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: _kOrange, size: 19),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _kDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoLinha extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoLinha({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _kMuted, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(
                color: _kMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? _kText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoSeguranca extends StatelessWidget {
  final String title;
  final String message;
  final Color color;

  const _AvisoSeguranca({
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
          Icon(Icons.info_outline_rounded, color: color, size: 21),
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

class _AcoesDetalhes extends StatelessWidget {
  final bool activo;
  final VoidCallback onEditarCliente;
  final VoidCallback onToggle;
  final VoidCallback onResetSenha;

  const _AcoesDetalhes({
    required this.activo,
    required this.onEditarCliente,
    required this.onToggle,
    required this.onResetSenha,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final compact = constraints.maxWidth < 720;

        final buttons = [
          _ActionButton(
            icon: Icons.edit_rounded,
            label: 'Editar cliente',
            color: _kDark,
            onPressed: onEditarCliente,
          ),
          _ActionButton(
            icon: Icons.lock_reset_rounded,
            label: 'Resetar senha',
            color: _kOrange,
            onPressed: onResetSenha,
          ),
          _ActionButton(
            icon: activo
                ? Icons.block_rounded
                : Icons.check_circle_outline_rounded,
            label: activo ? 'Desactivar' : 'Activar',
            color: activo ? _kRed : _kGreen,
            onPressed: onToggle,
          ),
        ];

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buttons
                .map(
                  (button) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: button,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: buttons
              .map(
                (button) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: button,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
      ),
    );
  }
}

class _EstadoCentral extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EstadoCentral({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _kOrange, size: 46),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kDark,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kMuted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool danger;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? _kRed : _kGreen;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: _kDark,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: _kMuted,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}