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

enum _FiltroCliente {
  todos,
  activos,
  inactivos,
  primeiraSenha,
}

class ClienteListScreen extends StatefulWidget {
  const ClienteListScreen({super.key});

  @override
  State<ClienteListScreen> createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  _FiltroCliente _filtro = _FiltroCliente.todos;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ClienteProvider>();

      await provider.carregarClientes();
      await provider.carregarPerfisCliente();
    });
  }

List<ClienteModel> _filtrarClientes(List<ClienteModel> clientes) {
  return clientes.where((cliente) {
    if (!_isEmpresarial(cliente)) {
      return false;
    }

    final activo = cliente.ativo;

      final passaFiltro = switch (_filtro) {
        _FiltroCliente.todos => true,
        _FiltroCliente.activos => activo,
        _FiltroCliente.inactivos => !activo,
        _FiltroCliente.primeiraSenha => cliente.primeiraSenha,
      };

      if (!passaFiltro) return false;

      final termo = _pesquisa.trim().toLowerCase();

      if (termo.isEmpty) return true;

      final nome = _nomeCliente(cliente).toLowerCase();
      final email = (cliente.email ?? '').toLowerCase();
      final telefone = (cliente.telefone ?? '').toLowerCase();
      final nuit = (cliente.nuit ?? '').toLowerCase();
      final perfil = _nomePerfilCliente(cliente).toLowerCase();


      return nome.contains(termo) ||
          email.contains(termo) ||
          telefone.contains(termo) ||
          nuit.contains(termo) ||
          perfil.contains(termo);
    }).toList();
  }

  String _nomeCliente(ClienteModel cliente) {
    if (cliente.nomeCompleto.trim().isNotEmpty) {
      return cliente.nomeCompleto.trim();
    }

    final nome = cliente.nome.trim();
    final apelido = cliente.apelido?.trim() ?? '';

    return '$nome $apelido'.trim();
  }

        bool _isEmpresarial(ClienteModel cliente) {
  return _nomePerfilCliente(cliente).trim().toLowerCase() == 'empresarial';
}

  String _nomePerfilCliente(ClienteModel cliente) {
    return cliente.perfilCliente?.nomePerfilCliente ?? 'Sem perfil';
  }

  Future<void> _recarregar() async {
    await context.read<ClienteProvider>().carregarClientes();
  }

  Future<void> _abrirCadastro() async {
    final result = await Navigator.of(context).pushNamed('/clientes/form');

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _abrirEdicao(ClienteModel cliente) async {
    final result = await Navigator.of(context).pushNamed(
      '/clientes/form',
      arguments: cliente,
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _abrirDetalhes(ClienteModel cliente) async {
    final result = await Navigator.of(context).pushNamed(
      '/clientes/detalhes',
      arguments: cliente,
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _confirmarToggle(ClienteModel cliente) async {
    if (cliente.idCliente == null) return;

    final activo = cliente.ativo;
    final acao = activo ? 'desactivar' : 'activar';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: activo ? 'Desactivar cliente' : 'Activar cliente',
        message: 'Deseja $acao ${_nomeCliente(cliente)}?',
        confirmLabel: activo ? 'Desactivar' : 'Activar',
        danger: activo,
      ),
    );

    if (ok != true || !mounted) return;

    final provider = context.read<ClienteProvider>();

    if (activo) {
      await provider.desactivarCliente(cliente.idCliente!);
      _snack('Cliente desactivado com sucesso.');
    } else {
      await provider.activarCliente(cliente.idCliente!);
      _snack('Cliente activado com sucesso.');
    }

    await _recarregar();
  }

  Future<void> _confirmarResetSenha(ClienteModel cliente) async {
    if (cliente.idCliente == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Resetar senha',
        message:
            'A senha de ${_nomeCliente(cliente)} será redefinida para 12345678. '
            'No próximo login, o cliente deverá criar uma nova senha.',
        confirmLabel: 'Resetar senha',
        danger: true,
      ),
    );

    if (ok != true || !mounted) return;

    await context.read<ClienteProvider>().resetarSenhaPadrao(
          cliente.idCliente!,
        );

    _snack('Senha redefinida para 12345678.');
    await _recarregar();
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
    final clientes = _filtrarClientes(provider.clientes);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              total: clientes.length,
              onNovo: _abrirCadastro,
              onRefresh: _recarregar,
            ),
            _Toolbar(
              filtro: _filtro,
              pesquisa: _pesquisa,
              onFiltroChanged: (value) {
                setState(() => _filtro = value);
              },
              onPesquisaChanged: (value) {
                setState(() => _pesquisa = value);
              },
            ),
            Expanded(
              child: _Body(
                provider: provider,
                clientes: clientes,
                onRefresh: _recarregar,
                onDetalhes: _abrirDetalhes,
                onEditar: _abrirEdicao,
                onToggle: _confirmarToggle,
                onResetSenha: _confirmarResetSenha,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;
  final VoidCallback onNovo;
  final VoidCallback onRefresh;

  const _Header({
    required this.total,
    required this.onNovo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDark,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
'Clientes Empresariais',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total cliente(s) encontrado(s)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Recarregar',
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onNovo,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Novo cliente'),
            style: FilledButton.styleFrom(
              backgroundColor: _kOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final _FiltroCliente filtro;
  final String pesquisa;
  final ValueChanged<_FiltroCliente> onFiltroChanged;
  final ValueChanged<String> onPesquisaChanged;

  const _Toolbar({
    required this.filtro,
    required this.pesquisa,
    required this.onFiltroChanged,
    required this.onPesquisaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kCard,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 760;

          final filtros = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChipButton(
                label: 'Todos',
                selected: filtro == _FiltroCliente.todos,
                onTap: () => onFiltroChanged(_FiltroCliente.todos),
              ),
              _FilterChipButton(
                label: 'Activos',
                selected: filtro == _FiltroCliente.activos,
                color: _kGreen,
                onTap: () => onFiltroChanged(_FiltroCliente.activos),
              ),
              _FilterChipButton(
                label: 'Inactivos',
                selected: filtro == _FiltroCliente.inactivos,
                color: _kRed,
                onTap: () => onFiltroChanged(_FiltroCliente.inactivos),
              ),
              _FilterChipButton(
                label: 'Senha inicial',
                selected: filtro == _FiltroCliente.primeiraSenha,
                color: _kOrange,
                onTap: () => onFiltroChanged(_FiltroCliente.primeiraSenha),
              ),
            ],
          );

          final pesquisaBox = SizedBox(
            width: compacto ? double.infinity : 390,
            child: TextField(
              onChanged: onPesquisaChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Pesquisar empresa por nome, email, telefone, NUIT ou perfil...',
              ),
            ),
          );

          if (compacto) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pesquisaBox,
                const SizedBox(height: 12),
                filtros,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: filtros),
              pesquisaBox,
            ],
          );
        },
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = _kDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : _kBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _kMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ClienteProvider provider;
  final List<ClienteModel> clientes;
  final Future<void> Function() onRefresh;
  final Future<void> Function(ClienteModel) onDetalhes;
  final Future<void> Function(ClienteModel) onEditar;
  final Future<void> Function(ClienteModel) onToggle;
  final Future<void> Function(ClienteModel) onResetSenha;

  const _Body({
    required this.provider,
    required this.clientes,
    required this.onRefresh,
    required this.onDetalhes,
    required this.onEditar,
    required this.onToggle,
    required this.onResetSenha,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.carregando) {
      return const Center(
        child: CircularProgressIndicator(color: _kOrange),
      );
    }

    if (provider.erro != null) {
      return _EstadoVazio(
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível carregar clientes',
        message: provider.erro!,
        actionLabel: 'Tentar novamente',
        onAction: onRefresh,
      );
    }

    if (clientes.isEmpty) {
      return _EstadoVazio(
        icon: Icons.person_search_rounded,
        title: 'Nenhum cliente encontrado',
        message: 'Não existem clientes para os filtros seleccionados.',
        actionLabel: 'Recarregar',
        onAction: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _kOrange,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 920) {
            return GridView.builder(
              padding: const EdgeInsets.all(18),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 520,
                mainAxisExtent: 210,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: clientes.length,
              itemBuilder: (_, index) {
                return _ClienteCard(
                  cliente: clientes[index],
                  onDetalhes: onDetalhes,
                  onEditar: onEditar,
                  onToggle: onToggle,
                  onResetSenha: onResetSenha,
                );
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: clientes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              return _ClienteCard(
                cliente: clientes[index],
                onDetalhes: onDetalhes,
                onEditar: onEditar,
                onToggle: onToggle,
                onResetSenha: onResetSenha,
              );
            },
          );
        },
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final ClienteModel cliente;
  final Future<void> Function(ClienteModel) onDetalhes;
  final Future<void> Function(ClienteModel) onEditar;
  final Future<void> Function(ClienteModel) onToggle;
  final Future<void> Function(ClienteModel) onResetSenha;

  const _ClienteCard({
    required this.cliente,
    required this.onDetalhes,
    required this.onEditar,
    required this.onToggle,
    required this.onResetSenha,
  });

  String get _nome {
    if (cliente.nomeCompleto.trim().isNotEmpty) {
      return cliente.nomeCompleto.trim();
    }

    final nome = cliente.nome.trim();
    final apelido = cliente.apelido?.trim() ?? '';

    return '$nome $apelido'.trim();
  }

  String get _perfil {
    return cliente.perfilCliente?.nomePerfilCliente ?? 'Sem perfil';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCard,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => onDetalhes(cliente),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(
                    nome: _nome,
                    active: cliente.ativo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ClienteIdentity(
                      nome: _nome,
                      perfil: _perfil,
                      telefone: cliente.telefone,
                    ),
                  ),
                  _StatusPill(active: cliente.ativo),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _InfoPill(
                    icon: Icons.lock_outline_rounded,
                    label: cliente.primeiraSenha
                        ? 'Senha inicial'
                        : 'Senha definida',
                    color: cliente.primeiraSenha ? _kOrange : _kGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.badge_outlined,
                      label: cliente.nuit ?? 'Sem NUIT',
                      color: _kMuted,
                    ),
                  ),
                ],
              ),
const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onEditar(cliente),
                    icon: const Icon(Icons.edit_rounded, size: 17),
                    label: const Text('Editar'),
                  ),
const SizedBox(height: 8),
                  IconButton(
                    tooltip: 'Resetar senha',
                    onPressed: () => onResetSenha(cliente),
                    icon: const Icon(Icons.lock_reset_rounded),
                    color: _kOrange,
                  ),
                  IconButton(
                    tooltip: cliente.ativo ? 'Desactivar' : 'Activar',
                    onPressed: () => onToggle(cliente),
                    icon: Icon(
                      cliente.ativo
                          ? Icons.block_rounded
                          : Icons.check_circle_outline_rounded,
                    ),
                    color: cliente.ativo ? _kRed : _kGreen,
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

class _ClienteIdentity extends StatelessWidget {
  final String nome;
  final String perfil;
  final String? telefone;

  const _ClienteIdentity({
    required this.nome,
    required this.perfil,
    required this.telefone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kText,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          telefone ?? 'Sem telefone',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          perfil,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kOrange,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String nome;
  final bool active;

  const _Avatar({
    required this.nome,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 48,
          width: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _kDark,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Text(
            _iniciais(nome),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            height: 14,
            width: 14,
            decoration: BoxDecoration(
              color: active ? _kGreen : _kRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
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

class _StatusPill extends StatelessWidget {
  final bool active;

  const _StatusPill({
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _kGreen : _kRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _kMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  const _EstadoVazio({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
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
                fontWeight: FontWeight.w800,
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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: _kOrange,
                foregroundColor: Colors.white,
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