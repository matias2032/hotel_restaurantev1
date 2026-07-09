import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/app_sidebar.dart';

const _kDark = Color(0xFF111827);
const _kOrange = Color(0xFFF97316);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kText = Color(0xFF374151);
const _kMuted = Color(0xFF6B7280);
const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE5E7EB);

enum _FiltroCategoriaIngrediente {
  todas,
  activas,
  inactivas,
  comIngredientes,
  semIngredientes,
}

class CategoriaIngredienteListScreen extends StatefulWidget {
  const CategoriaIngredienteListScreen({super.key});

  @override
  State<CategoriaIngredienteListScreen> createState() =>
      _CategoriaIngredienteListScreenState();
}

class _CategoriaIngredienteListScreenState
    extends State<CategoriaIngredienteListScreen> {
  _FiltroCategoriaIngrediente _filtro = _FiltroCategoriaIngrediente.todas;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _recarregar();
    });
  }

  Future<void> _recarregar() async {
    final provider = context.read<IngredienteProvider>();

    await provider.carregarCategorias();
    await provider.carregarIngredientes();
  }

  List<CategoriaIngredienteModel> _filtrarCategorias(
    List<CategoriaIngredienteModel> categorias,
    List<IngredienteModel> ingredientes,
  ) {
    return categorias.where((categoria) {
      final associados = _ingredientesAssociados(
        categoria,
        ingredientes,
      );

      final passaFiltro = switch (_filtro) {
        _FiltroCategoriaIngrediente.todas => true,
        _FiltroCategoriaIngrediente.activas => categoria.ativo,
        _FiltroCategoriaIngrediente.inactivas => !categoria.ativo,
        _FiltroCategoriaIngrediente.comIngredientes => associados.isNotEmpty,
        _FiltroCategoriaIngrediente.semIngredientes => associados.isEmpty,
      };

      if (!passaFiltro) return false;

      final termo = _pesquisa.trim().toLowerCase();

      if (termo.isEmpty) return true;

      final nome = categoria.nome.toLowerCase();
      final descricao = (categoria.descricao ?? '').toLowerCase();

      final nomesAssociados = associados
          .map((ingrediente) => ingrediente.nome.toLowerCase())
          .join(' ');

      return nome.contains(termo) ||
          descricao.contains(termo) ||
          nomesAssociados.contains(termo);
    }).toList()
      ..sort((a, b) {
        final ordem = a.ordem.compareTo(b.ordem);

        if (ordem != 0) return ordem;

        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      });
  }

  List<IngredienteModel> _ingredientesAssociados(
    CategoriaIngredienteModel categoria,
    List<IngredienteModel> ingredientes,
  ) {
    final idCategoria = categoria.idCategoriaIngrediente;

    if (idCategoria == null) return [];

    return ingredientes.where((ingrediente) {
      return ingrediente.categoriasIngrediente.any((categoriaResumo) {
        return categoriaResumo.idCategoriaIngrediente == idCategoria;
      });
    }).toList()
      ..sort(
        (a, b) => a.nome.toLowerCase().compareTo(
              b.nome.toLowerCase(),
            ),
      );
  }

  Future<void> _abrirCadastro() async {
    final result = await Navigator.of(context).pushNamed(
      '/categorias-ingrediente/form',
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _abrirEdicao(
    CategoriaIngredienteModel categoria,
  ) async {
    final result = await Navigator.of(context).pushNamed(
      '/categorias-ingrediente/form',
      arguments: categoria,
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _alterarEstado(
    CategoriaIngredienteModel categoria,
  ) async {
    final id = categoria.idCategoriaIngrediente;

    if (id == null) {
      _snack(
        'Categoria inválida.',
        erro: true,
      );
      return;
    }

    final novoEstado = !categoria.ativo;

    final confirmado = await _confirmar(
      titulo: novoEstado ? 'Activar categoria?' : 'Desactivar categoria?',
      mensagem: novoEstado
          ? 'A categoria voltará a aparecer como activa.'
          : 'A categoria será desactivada, mas os ingredientes associados não serão eliminados.',
      textoConfirmar: novoEstado ? 'Activar' : 'Desactivar',
      corConfirmar: novoEstado ? _kGreen : _kRed,
    );

    if (!confirmado || !mounted) return;

    final provider = context.read<IngredienteProvider>();

    final sucesso = await provider.alterarEstadoCategoria(
      id,
      novoEstado,
    );

    if (!mounted) return;

    if (sucesso) {
      _snack(
        novoEstado
            ? 'Categoria activada com sucesso.'
            : 'Categoria desactivada com sucesso.',
      );
    } else {
      _snack(
        provider.erro ?? 'Não foi possível alterar o estado da categoria.',
        erro: true,
      );
    }
  }

  Future<void> _desativarCategoria(
    CategoriaIngredienteModel categoria,
  ) async {
    final id = categoria.idCategoriaIngrediente;

    if (id == null) {
      _snack(
        'Categoria inválida.',
        erro: true,
      );
      return;
    }

    final confirmado = await _confirmar(
      titulo: 'Desactivar categoria?',
      mensagem:
          'A categoria será desactivada. Os ingredientes associados não serão eliminados; apenas o vínculo deve ser tratado pelo backend.',
      textoConfirmar: 'Desactivar',
      corConfirmar: _kRed,
    );

    if (!confirmado || !mounted) return;

    final provider = context.read<IngredienteProvider>();

    final sucesso = await provider.desativarCategoria(id);

    if (!mounted) return;

    if (sucesso) {
      _snack('Categoria desactivada com sucesso.');
    } else {
      _snack(
        provider.erro ?? 'Não foi possível desactivar a categoria.',
        erro: true,
      );
    }
  }

  Future<bool> _confirmar({
    required String titulo,
    required String mensagem,
    required String textoConfirmar,
    required Color corConfirmar,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _kCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              color: _kDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            mensagem,
            style: const TextStyle(
              color: _kText,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: corConfirmar,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(textoConfirmar),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  void _snack(
    String mensagem, {
    bool erro = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: erro ? _kRed : _kGreen,
        content: Text(mensagem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IngredienteProvider>(
      builder: (context, provider, _) {
        final categorias = _filtrarCategorias(
          provider.categorias,
          provider.ingredientes,
        );

        final total = provider.categorias.length;
        final activas = provider.categorias.where((c) => c.ativo).length;
        final inactivas = provider.categorias.where((c) => !c.ativo).length;

        return Scaffold(
          backgroundColor: _kBg,
   drawer: const AppSidebar(
  currentRoute: '/categorias-ingrediente',
),
          appBar: AppBar(
            title: const Text('Categorias de Ingrediente'),
            actions: [
              IconButton(
                tooltip: 'Recarregar',
                onPressed: provider.carregando ? null : _recarregar,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: _kOrange,
            foregroundColor: Colors.white,
            onPressed: _abrirCadastro,
            icon: const Icon(Icons.add),
            label: const Text('Nova categoria'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _recarregar,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _HeaderCard(
                    total: total,
                    activas: activas,
                    inactivas: inactivas,
                  ),
                  const SizedBox(height: 16),
                  _SearchAndFilters(
                    pesquisa: _pesquisa,
                    filtro: _filtro,
                    onPesquisaChanged: (value) {
                      setState(() => _pesquisa = value);
                    },
                    onFiltroChanged: (value) {
                      setState(() => _filtro = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (provider.carregando)
                    const _LoadingCard()
                  else if (provider.temErro)
                    _ErrorCard(
                      mensagem: provider.erro ?? 'Erro inesperado.',
                      onRetry: _recarregar,
                    )
                  else if (categorias.isEmpty)
                    const _EmptyCard()
                  else
                    ...categorias.map((categoria) {
                      final associados = _ingredientesAssociados(
                        categoria,
                        provider.ingredientes,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CategoriaCard(
                          categoria: categoria,
                          associados: associados,
                          onEditar: () => _abrirEdicao(categoria),
                          onAlterarEstado: () => _alterarEstado(categoria),
                          onDesativar: () => _desativarCategoria(categoria),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int total;
  final int activas;
  final int inactivas;

  const _HeaderCard({
    required this.total,
    required this.activas,
    required this.inactivas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestão de categorias',
            style: TextStyle(
              color: _kDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Organize os ingredientes por grupos e veja rapidamente os associados.',
            style: TextStyle(
              color: _kMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                label: 'Total',
                value: total.toString(),
                icon: Icons.category_outlined,
                color: _kDark,
              ),
              _MetricChip(
                label: 'Activas',
                value: activas.toString(),
                icon: Icons.check_circle_outline,
                color: _kGreen,
              ),
              _MetricChip(
                label: 'Inactivas',
                value: inactivas.toString(),
                icon: Icons.block,
                color: _kRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final String pesquisa;
  final _FiltroCategoriaIngrediente filtro;
  final ValueChanged<String> onPesquisaChanged;
  final ValueChanged<_FiltroCategoriaIngrediente> onFiltroChanged;

  const _SearchAndFilters({
    required this.pesquisa,
    required this.filtro,
    required this.onPesquisaChanged,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: onPesquisaChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar por nome, descrição ou ingrediente associado',
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Todas',
                  selected: filtro == _FiltroCategoriaIngrediente.todas,
                  onTap: () => onFiltroChanged(
                    _FiltroCategoriaIngrediente.todas,
                  ),
                ),
                _FilterChip(
                  label: 'Activas',
                  selected: filtro == _FiltroCategoriaIngrediente.activas,
                  onTap: () => onFiltroChanged(
                    _FiltroCategoriaIngrediente.activas,
                  ),
                ),
                _FilterChip(
                  label: 'Inactivas',
                  selected: filtro == _FiltroCategoriaIngrediente.inactivas,
                  onTap: () => onFiltroChanged(
                    _FiltroCategoriaIngrediente.inactivas,
                  ),
                ),
                _FilterChip(
                  label: 'Com ingredientes',
                  selected:
                      filtro == _FiltroCategoriaIngrediente.comIngredientes,
                  onTap: () => onFiltroChanged(
                    _FiltroCategoriaIngrediente.comIngredientes,
                  ),
                ),
                _FilterChip(
                  label: 'Sem ingredientes',
                  selected:
                      filtro == _FiltroCategoriaIngrediente.semIngredientes,
                  onTap: () => onFiltroChanged(
                    _FiltroCategoriaIngrediente.semIngredientes,
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

class _CategoriaCard extends StatelessWidget {
  final CategoriaIngredienteModel categoria;
  final List<IngredienteModel> associados;
  final VoidCallback onEditar;
  final VoidCallback onAlterarEstado;
  final VoidCallback onDesativar;

  const _CategoriaCard({
    required this.categoria,
    required this.associados,
    required this.onEditar,
    required this.onAlterarEstado,
    required this.onDesativar,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = categoria.ativo;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _kOrange.withOpacity(0.12),
                foregroundColor: _kOrange,
                child: const Icon(Icons.kitchen_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.nome,
                      style: const TextStyle(
                        color: _kDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      categoria.descricao?.trim().isNotEmpty == true
                          ? categoria.descricao!.trim()
                          : 'Sem descrição',
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                label: ativo ? 'Activa' : 'Inactiva',
                color: ativo ? _kGreen : _kRed,
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (value) {
                  switch (value) {
                    case 'editar':
                      onEditar();
                      break;
                    case 'estado':
                      onAlterarEstado();
                      break;
                    case 'desativar':
                      onDesativar();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Editar'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'estado',
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          ativo
                              ? Icons.toggle_off_outlined
                              : Icons.toggle_on_outlined,
                        ),
                        title: Text(
                          ativo ? 'Desactivar' : 'Activar',
                        ),
                      ),
                    ),
                    if (ativo)
                      const PopupMenuItem(
                        value: 'desativar',
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.delete_outline,
                            color: _kRed,
                          ),
                          title: Text(
                            'Desactivar categoria',
                            style: TextStyle(color: _kRed),
                          ),
                        ),
                      ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallInfoChip(
                icon: Icons.sort,
                label: 'Ordem: ${categoria.ordem}',
              ),
              _SmallInfoChip(
                icon: Icons.restaurant_menu,
                label:
                    '${associados.length} ingrediente${associados.length == 1 ? '' : 's'}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            associados.isEmpty
                ? 'Nenhum ingrediente associado.'
                : 'Ingredientes associados:',
            style: const TextStyle(
              color: _kText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (associados.isEmpty)
            const Text(
              'Esta categoria ainda não está vinculada a nenhum ingrediente.',
              style: TextStyle(
                color: _kMuted,
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: associados.map((ingrediente) {
                return Chip(
                  avatar: Icon(
                    ingrediente.ativo
                        ? Icons.check_circle_outline
                        : Icons.block,
                    size: 16,
                    color: ingrediente.ativo ? _kGreen : _kRed,
                  ),
                  label: Text(ingrediente.nome),
                  backgroundColor: const Color(0xFFF9FAFB),
                  side: const BorderSide(color: _kBorder),
                  labelStyle: const TextStyle(
                    color: _kText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: _kText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      selectedColor: _kOrange.withOpacity(0.14),
      backgroundColor: const Color(0xFFF9FAFB),
      side: BorderSide(
        color: selected ? _kOrange : _kBorder,
      ),
      labelStyle: TextStyle(
        color: selected ? _kOrange : _kText,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SmallInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SmallInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _kMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _kMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String mensagem;
  final Future<void> Function() onRetry;

  const _ErrorCard({
    required this.mensagem,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: _kRed,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _kText),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          Icon(
            Icons.category_outlined,
            color: _kMuted,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhuma categoria encontrada.',
            style: TextStyle(
              color: _kDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Crie uma categoria para organizar os ingredientes.',
            style: TextStyle(
              color: _kMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: _kCard,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: _kBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}