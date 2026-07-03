// lib/screens/usuario_list_screen.dart

import 'package:api_compartilhado/api_compartilhado.dart';
import 'usuario_form_screen.dart';
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

enum _FiltroUsuario {
  todos,
  activos,
  inactivos,
  primeiraSenha,
}

class UsuarioListScreen extends StatefulWidget {
  const UsuarioListScreen({super.key});

  @override
  State<UsuarioListScreen> createState() => _UsuarioListScreenState();
}

class _UsuarioListScreenState extends State<UsuarioListScreen> {
  _FiltroUsuario _filtro = _FiltroUsuario.todos;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<UsuarioProvider>();
      await provider.carregarUsuarios();
      await provider.carregarPerfis();
    });
  }

  List<UsuarioModel> _filtrarUsuarios(List<UsuarioModel> usuarios) {
    return usuarios.where((usuario) {
      if (_isAdministrador(usuario)) {
        return false;
      }

      final activo = _isActivo(usuario);

      final passaFiltro = switch (_filtro) {
        _FiltroUsuario.todos => true,
        _FiltroUsuario.activos => activo,
        _FiltroUsuario.inactivos => !activo,
        _FiltroUsuario.primeiraSenha => usuario.primeiraSenha,
      };

      if (!passaFiltro) {
        return false;
      }

      final termo = _pesquisa.trim().toLowerCase();

      if (termo.isEmpty) {
        return true;
      }

      final nome = usuario.nomeCompleto.toLowerCase();
      final email = (usuario.email ?? '').toLowerCase();
      final telefone = (usuario.telefone ?? '').toLowerCase();
      final perfil = _nomePerfil(usuario).toLowerCase();

      return nome.contains(termo) ||
          email.contains(termo) ||
          telefone.contains(termo) ||
          perfil.contains(termo);
    }).toList();
  }

  bool _isAdministrador(UsuarioModel usuario) {
    return _nomePerfil(usuario).trim().toLowerCase() == 'administrador';
  }

  bool _isActivo(UsuarioModel usuario) {
    return usuario.status;
  }

  String _nomePerfil(UsuarioModel usuario) {
    return usuario.perfil?.nomePerfil ?? 'Sem perfil';
  }

  Future<void> _recarregar() async {
    await context.read<UsuarioProvider>().carregarUsuarios();
  }

  Future<void> _abrirCadastro() async {
    final result = await Navigator.of(context).pushNamed('/usuarios/form');

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _abrirEdicao(UsuarioModel usuario) async {
    if (_isAdministrador(usuario)) {
      _snack('Usuários administradores não podem ser visualizados nesta tela.',
          erro: true);
      return;
    }

    final result = await Navigator.of(context).pushNamed(
      '/usuarios/form',
      arguments: usuario,
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _abrirDetalhes(UsuarioModel usuario) async {
    if (_isAdministrador(usuario)) {
      _snack('Usuários administradores não podem ser visualizados nesta tela.',
          erro: true);
      return;
    }

    final result = await Navigator.of(context).pushNamed(
      '/usuarios/detalhes',
      arguments: usuario,
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _confirmarToggle(UsuarioModel usuario) async {
    final activo = _isActivo(usuario);
    final acao = activo ? 'desactivar' : 'activar';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: activo ? 'Desactivar usuário' : 'Activar usuário',
        message: 'Deseja $acao ${usuario.nomeCompleto}?',
        confirmLabel: activo ? 'Desactivar' : 'Activar',
        danger: activo,
      ),
    );

    if (ok != true || !mounted) {
      return;
    }

    final provider = context.read<UsuarioProvider>();

    if (activo) {
      await provider.desactivarUsuario(usuario.idUsuario!);
      _snack('Usuário desactivado com sucesso.');
    } else {
      await provider.activarUsuario(usuario.idUsuario!);
      _snack('Usuário activado com sucesso.');
    }

    await _recarregar();
  }

  Future<void> _confirmarResetSenha(UsuarioModel usuario) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Resetar senha',
        message:
            'A senha de ${usuario.nomeCompleto} será redefinida para 12345678. '
            'No próximo login, o usuário deverá criar uma nova senha.',
        confirmLabel: 'Resetar senha',
        danger: true,
      ),
    );

    if (ok != true || !mounted) {
      return;
    }

    await context.read<UsuarioProvider>().resetarSenhaPadrao(
          usuario.idUsuario!,
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
    final provider = context.watch<UsuarioProvider>();
    final usuarios = _filtrarUsuarios(provider.usuarios);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              total: usuarios.length,
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
                usuarios: usuarios,
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

// ─────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────

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
              Icons.manage_accounts_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Administração de Usuários',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total usuário(s) visível(is) nesta unidade',
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
            label: const Text('Novo usuário'),
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

// ─────────────────────────────────────────────────────────────
// TOOLBAR
// ─────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final _FiltroUsuario filtro;
  final String pesquisa;
  final ValueChanged<_FiltroUsuario> onFiltroChanged;
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
                selected: filtro == _FiltroUsuario.todos,
                onTap: () => onFiltroChanged(_FiltroUsuario.todos),
              ),
              _FilterChipButton(
                label: 'Activos',
                selected: filtro == _FiltroUsuario.activos,
                color: _kGreen,
                onTap: () => onFiltroChanged(_FiltroUsuario.activos),
              ),
              _FilterChipButton(
                label: 'Inactivos',
                selected: filtro == _FiltroUsuario.inactivos,
                color: _kRed,
                onTap: () => onFiltroChanged(_FiltroUsuario.inactivos),
              ),
              _FilterChipButton(
                label: 'Senha inicial',
                selected: filtro == _FiltroUsuario.primeiraSenha,
                color: _kOrange,
                onTap: () => onFiltroChanged(_FiltroUsuario.primeiraSenha),
              ),
            ],
          );

          final pesquisaBox = SizedBox(
            width: compacto ? double.infinity : 360,
            child: TextField(
              onChanged: onPesquisaChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Pesquisar por nome, email, telefone ou perfil...',
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
            color: selected ? color : const Color(0xFFE5E7EB),
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

// ─────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final UsuarioProvider provider;
  final List<UsuarioModel> usuarios;
  final Future<void> Function() onRefresh;
  final Future<void> Function(UsuarioModel) onDetalhes;
  final Future<void> Function(UsuarioModel) onEditar;
  final Future<void> Function(UsuarioModel) onToggle;
  final Future<void> Function(UsuarioModel) onResetSenha;

  const _Body({
    required this.provider,
    required this.usuarios,
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
        title: 'Não foi possível carregar usuários',
        message: provider.erro!,
        actionLabel: 'Tentar novamente',
        onAction: onRefresh,
      );
    }

    if (usuarios.isEmpty) {
      return _EstadoVazio(
        icon: Icons.person_search_rounded,
        title: 'Nenhum usuário encontrado',
        message:
            'Não existem usuários para os filtros seleccionados. Administradores ficam ocultos nesta tela.',
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
                mainAxisExtent: 178,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: usuarios.length,
              itemBuilder: (_, index) {
                return _UsuarioCard(
                  usuario: usuarios[index],
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
            itemCount: usuarios.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              return _UsuarioCard(
                usuario: usuarios[index],
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

// ─────────────────────────────────────────────────────────────
// CARD USUÁRIO
// ─────────────────────────────────────────────────────────────

class _UsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;
  final Future<void> Function(UsuarioModel) onDetalhes;
  final Future<void> Function(UsuarioModel) onEditar;
  final Future<void> Function(UsuarioModel) onToggle;
  final Future<void> Function(UsuarioModel) onResetSenha;

  const _UsuarioCard({
    required this.usuario,
    required this.onDetalhes,
    required this.onEditar,
    required this.onToggle,
    required this.onResetSenha,
  });

  bool get _activo => usuario.status;

  String get _perfil => usuario.perfil?.nomePerfil ?? 'Sem perfil';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCard,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => onDetalhes(usuario),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(
                    nome: usuario.nomeCompleto.isNotEmpty
                        ? usuario.nomeCompleto
                        : usuario.nome,
                    active: _activo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UsuarioIdentity(
                      usuario: usuario,
                      perfil: _perfil,
                    ),
                  ),
                  _StatusPill(active: _activo),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _InfoPill(
                    icon: Icons.lock_outline_rounded,
                    label: usuario.primeiraSenha
                        ? 'Senha inicial'
                        : 'Senha definida',
                    color: usuario.primeiraSenha ? _kOrange : _kGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.email_outlined,
                      label: usuario.email ?? 'Sem email',
                      color: _kMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => onEditar(usuario),
                    icon: const Icon(Icons.edit_rounded, size: 17),
                    label: const Text('Editar perfil'),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Resetar senha',
                    onPressed: () => onResetSenha(usuario),
                    icon: const Icon(Icons.lock_reset_rounded),
                    color: _kOrange,
                  ),
                  IconButton(
                    tooltip: _activo ? 'Desactivar' : 'Activar',
                    onPressed: () => onToggle(usuario),
                    icon: Icon(
                      _activo
                          ? Icons.block_rounded
                          : Icons.check_circle_outline_rounded,
                    ),
                    color: _activo ? _kRed : _kGreen,
                  ),
                  IconButton(
                    tooltip: 'Detalhes',
                    onPressed: () => onDetalhes(usuario),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: _kDark,
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

class _UsuarioIdentity extends StatelessWidget {
  final UsuarioModel usuario;
  final String perfil;

  const _UsuarioIdentity({
    required this.usuario,
    required this.perfil,
  });

  @override
  Widget build(BuildContext context) {
    final nome = usuario.nomeCompleto.isNotEmpty
        ? usuario.nomeCompleto
        : usuario.nome;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kDark,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          perfil,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
    final initials = _iniciais(nome);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: _kDark,
            borderRadius: BorderRadius.circular(17),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
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

// ─────────────────────────────────────────────────────────────
// EMPTY / ERROR
// ─────────────────────────────────────────────────────────────

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
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => onAction(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: _kDark,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DIALOG
// ─────────────────────────────────────────────────────────────

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
          fontWeight: FontWeight.w800,
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