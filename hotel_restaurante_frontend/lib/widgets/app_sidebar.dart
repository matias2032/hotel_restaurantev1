import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:flutter/material.dart';

const _kDark = Color(0xFF111827);
const _kOrange = Color(0xFFF97316);
const _kWhite = Colors.white;
const _kMuted = Color(0xFF6B7280);
const _kBorder = Color(0xFFE5E7EB);

// ─────────────────────────────────────────────────────────────
// MODELOS DA SIDEBAR
// ─────────────────────────────────────────────────────────────

class _SidebarRoute {
  final IconData icon;
  final String title;
  final String route;

  const _SidebarRoute({
    required this.icon,
    required this.title,
    required this.route,
  });
}

class _SidebarSubModule {
  final IconData icon;
  final String title;
  final List<_SidebarRoute> routes;

  const _SidebarSubModule({
    required this.icon,
    required this.title,
    required this.routes,
  });
}

class _SidebarModule {
  final IconData icon;
  final String title;
  final List<_SidebarRoute> routes;
  final List<_SidebarSubModule> subModules;

  const _SidebarModule({
    required this.icon,
    required this.title,
    this.routes = const [],
    this.subModules = const [],
  });
}

// ─────────────────────────────────────────────────────────────
// WIDGET PRINCIPAL
// ─────────────────────────────────────────────────────────────

class AppSidebar extends StatefulWidget {
  final String currentRoute;

  const AppSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar>
    with SingleTickerProviderStateMixin {
  bool _showUserMenu = false;

  late final AnimationController _animController;
  late final Animation<double> _rotationAnim;

  final Set<String> _modulosExpandidos = {};
  final Set<String> _subModulosExpandidos = {};

  // ─────────────────────────────────────────────────────────────
  // DEFINIÇÃO DOS MÓDULOS
  // ─────────────────────────────────────────────────────────────

  List<_SidebarModule> get _modules {
    return const [
      _SidebarModule(
        icon: Icons.admin_panel_settings_rounded,
        title: 'Administração',
        routes: [
          _SidebarRoute(
            icon: Icons.manage_accounts_rounded,
            title: 'Utilizadores',
            route: '/usuarios',
          ),
        ],
      ),

      _SidebarModule(
        icon: Icons.groups_rounded,
        title: 'Clientes',
        routes: [
          _SidebarRoute(
            icon: Icons.apartment_rounded,
            title: 'Clientes',
            route: '/clientes',
          ),
        ],
      ),

      _SidebarModule(
  icon: Icons.restaurant_menu_rounded,
  title: 'Catálogo',
  subModules: [
    _SidebarSubModule(
      icon: Icons.kitchen_rounded,
      title: 'Ingredientes',
      routes: [
        _SidebarRoute(
          icon: Icons.restaurant_rounded,
          title: 'Ver ingredientes',
          route: '/ingredientes',
        ),
        _SidebarRoute(
          icon: Icons.category_rounded,
          title: 'Ver categorias de ingredientes',
          route: '/categorias-ingrediente',
        ),
      ],
    ),

    _SidebarSubModule(
      icon: Icons.room_service_rounded,
      title: 'Serviços',
      routes: [
        _SidebarRoute(
          icon: Icons.design_services_rounded,
          title: 'Ver serviços',
          route: '/servicos',
        ),
        _SidebarRoute(
          icon: Icons.category_rounded,
          title: 'Ver categorias de serviços',
          route: '/categorias-servico',
        ),
      ],
    ),
  ],
),
    ];
  }

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _rotationAnim = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expandirRotaActiva();
    });
  }

  @override
  void didUpdateWidget(covariant AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentRoute != widget.currentRoute) {
      _expandirRotaActiva();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _expandirRotaActiva() {
    for (final modulo in _modules) {
      final moduloTemRotaActiva = modulo.routes.any(
        (item) => item.route == widget.currentRoute,
      );

      if (moduloTemRotaActiva) {
        setState(() {
          _modulosExpandidos.add(modulo.title);
        });
        return;
      }

      for (final subModulo in modulo.subModules) {
        final subModuloTemRotaActiva = subModulo.routes.any(
          (item) => item.route == widget.currentRoute,
        );

        if (subModuloTemRotaActiva) {
          setState(() {
            _modulosExpandidos.add(modulo.title);
            _subModulosExpandidos.add(_subModuloKey(modulo, subModulo));
          });
          return;
        }
      }
    }
  }

  bool _moduloTemRotaActiva(_SidebarModule modulo) {
    final rotaDirecta = modulo.routes.any(
      (item) => item.route == widget.currentRoute,
    );

    final rotaSubModulo = modulo.subModules.any(
      (subModulo) => subModulo.routes.any(
        (item) => item.route == widget.currentRoute,
      ),
    );

    return rotaDirecta || rotaSubModulo;
  }

  bool _subModuloTemRotaActiva(_SidebarSubModule subModulo) {
    return subModulo.routes.any(
      (item) => item.route == widget.currentRoute,
    );
  }

  String _subModuloKey(
    _SidebarModule modulo,
    _SidebarSubModule subModulo,
  ) {
    return '${modulo.title}/${subModulo.title}';
  }

  void _irParaRota(
    String route,
  ) {
    Navigator.pop(context);

    if (widget.currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
String _usuarioNome(dynamic usuario) {
  return usuario?.nome?.toString().trim() ?? 'Hotel Restaurante';
}

String _usuarioApelido(dynamic usuario) {
  return usuario?.apelido?.toString().trim() ?? '';
}

String _usuarioEmail(dynamic usuario) {
  return usuario?.email?.toString().trim() ?? '';
}

String _usuarioPerfil(dynamic usuario) {
  return usuario?.perfil?.nomePerfil?.toString().trim() ?? 'Sistema';
}

String _usuarioInicial(dynamic usuario) {
  final nome = _usuarioNome(usuario);

  if (nome.trim().isEmpty) {
    return 'H';
  }

  return nome.trim()[0].toUpperCase();
}
  @override
  Widget build(BuildContext context) {
    final usuario = SessaoService.instance.usuario;

    return Drawer(
      backgroundColor: _kWhite,
      child: Column(
        children: [
          _buildHeader(usuario),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildItemSimples(
                  icon: Icons.dashboard_rounded,
                  title: 'Painel de Controle',
                  route: '/',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Divider(height: 1),
                ),
                ..._modules.map(_buildModule),
              ],
            ),
          ),
          if (usuario != null) _buildUserSection(usuario),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────

Widget _buildHeader(dynamic usuario) {
  final nome = _usuarioNome(usuario);
  final apelido = _usuarioApelido(usuario);
  final perfil = _usuarioPerfil(usuario);
  final inicial = _usuarioInicial(usuario);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _kDark,
          Color(0xFF1F2937),
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: _kWhite,
          child: Text(
            inicial,
            style: const TextStyle(
              fontSize: 28,
              color: _kDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$nome $apelido'.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: _kWhite.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            perfil,
            style: const TextStyle(
              color: _kWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
  // ─────────────────────────────────────────────────────────────
  // ITEM SIMPLES
  // ─────────────────────────────────────────────────────────────

  Widget _buildItemSimples({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final selected = widget.currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 1,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 22,
          color: selected ? _kOrange : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selected ? _kDark : Colors.black87,
            fontWeight: selected ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: _kOrange.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => _irParaRota(route),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MÓDULO
  // ─────────────────────────────────────────────────────────────

  Widget _buildModule(_SidebarModule modulo) {
    final expanded = _modulosExpandidos.contains(modulo.title);
    final active = _moduloTemRotaActiva(modulo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 1,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                if (expanded) {
                  _modulosExpandidos.remove(modulo.title);
                } else {
                  _modulosExpandidos.add(modulo.title);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: active ? _kOrange.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    modulo.icon,
                    size: 22,
                    color: active ? _kOrange : Colors.grey[700],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      modulo.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? _kDark : Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              ...modulo.routes.map(_buildRouteItem),
              ...modulo.subModules.map(
                (subModulo) => _buildSubModule(
                  modulo,
                  subModulo,
                ),
              ),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SUBMÓDULO
  // ─────────────────────────────────────────────────────────────

  Widget _buildSubModule(
    _SidebarModule modulo,
    _SidebarSubModule subModulo,
  ) {
    final key = _subModuloKey(modulo, subModulo);
    final expanded = _subModulosExpandidos.contains(key);
    final active = _subModuloTemRotaActiva(subModulo);

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 8,
        top: 1,
        bottom: 1,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                if (expanded) {
                  _subModulosExpandidos.remove(key);
                } else {
                  _subModulosExpandidos.add(key);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: active ? _kOrange.withOpacity(0.07) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    subModulo.icon,
                    size: 20,
                    color: active ? _kOrange : Colors.grey[650],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subModulo.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? _kDark : Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: subModulo.routes.map(_buildNestedRouteItem).toList(),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ROTAS
  // ─────────────────────────────────────────────────────────────

  Widget _buildRouteItem(_SidebarRoute item) {
    final selected = widget.currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 8,
        top: 1,
        bottom: 1,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.icon,
          size: 20,
          color: selected ? _kOrange : Colors.grey[600],
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 13,
            color: selected ? _kDark : Colors.black87,
            fontWeight: selected ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: _kOrange.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => _irParaRota(item.route),
      ),
    );
  }

  Widget _buildNestedRouteItem(_SidebarRoute item) {
    final selected = widget.currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.only(
        left: 28,
        right: 0,
        top: 1,
        bottom: 1,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.icon,
          size: 19,
          color: selected ? _kOrange : Colors.grey[600],
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 12.8,
            color: selected ? _kDark : Colors.black87,
            fontWeight: selected ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: _kOrange.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => _irParaRota(item.route),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // USER SECTION
  // ─────────────────────────────────────────────────────────────

  Widget _buildUserSection(dynamic usuario) {
final nome = _usuarioNome(usuario);
final apelido = _usuarioApelido(usuario);
final email = _usuarioEmail(usuario);
final inicial = _usuarioInicial(usuario);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: const Border(
          top: BorderSide(color: _kBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.bottomCenter,
            child: _showUserMenu
                ? Container(
                    color: _kWhite,
                    child: Column(
                      children: [
                        _buildUserMenuItem(
                          icon: Icons.person_rounded,
                          title: 'Alterar dados',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/usuarios/detalhes');
                          },
                        ),
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildUserMenuItem(
                          icon: Icons.lock_rounded,
                          title: 'Alterar senha',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/primeira-senha');
                          },
                        ),
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildUserMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Sair',
                          color: Colors.red,
                          onTap: () => _confirmarLogout(context),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showUserMenu = !_showUserMenu;

                  if (_showUserMenu) {
                    _animController.forward();
                  } else {
                    _animController.reverse();
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _kDark,
                      child: Text(
                        inicial,
                        style: const TextStyle(
                          color: _kWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$nome $apelido'.trim(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: _rotationAnim,
                      child: Icon(
                        Icons.expand_less_rounded,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: title == 'Sair' ? Colors.red : Colors.black87,
          fontSize: 13,
        ),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
      onTap: onTap,
    );
  }

  Future<void> _confirmarLogout(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 12),
              Text('Confirmar saída'),
            ],
          ),
          content: const Text(
            'Tem certeza que deseja sair da sua conta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmado == true && context.mounted) {
      SessaoService.instance.encerrar();

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}