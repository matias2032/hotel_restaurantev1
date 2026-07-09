import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/app_sidebar.dart';

const _kDark = Color(0xFF111827);
const _kOrange = Color(0xFFF97316);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kBlue = Color(0xFF2563EB);
const _kText = Color(0xFF374151);
const _kMuted = Color(0xFF6B7280);
const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE5E7EB);

enum _FiltroIngrediente {
  todos,
  activos,
  inactivos,
  disponiveis,
  indisponiveis,
  comCategorias,
  semCategorias,
  comEstoque,
}

class IngredienteListScreen extends StatefulWidget {
  const IngredienteListScreen({super.key});

  @override
  State<IngredienteListScreen> createState() => _IngredienteListScreenState();
}

class _IngredienteListScreenState extends State<IngredienteListScreen> {
  _FiltroIngrediente _filtro = _FiltroIngrediente.todos;
  String _pesquisa = '';
  int? _idCategoriaFiltro;

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

  List<IngredienteModel> _filtrarIngredientes(
    List<IngredienteModel> ingredientes,
  ) {
    return ingredientes.where((ingrediente) {
      final passaCategoria = _idCategoriaFiltro == null ||
          ingrediente.categoriasIngrediente.any(
            (categoria) =>
                categoria.idCategoriaIngrediente == _idCategoriaFiltro,
          );

      if (!passaCategoria) return false;

      final passaFiltro = switch (_filtro) {
        _FiltroIngrediente.todos => true,
        _FiltroIngrediente.activos => ingrediente.ativo,
        _FiltroIngrediente.inactivos => !ingrediente.ativo,
        _FiltroIngrediente.disponiveis => ingrediente.disponivel,
        _FiltroIngrediente.indisponiveis => !ingrediente.disponivel,
        _FiltroIngrediente.comCategorias =>
          ingrediente.categoriasIngrediente.isNotEmpty,
        _FiltroIngrediente.semCategorias =>
          ingrediente.categoriasIngrediente.isEmpty,
        _FiltroIngrediente.comEstoque => ingrediente.controlaEstoque,
      };

      if (!passaFiltro) return false;

      final termo = _pesquisa.trim().toLowerCase();

      if (termo.isEmpty) return true;

      final nome = ingrediente.nome.toLowerCase();
      final descricao = (ingrediente.descricao ?? '').toLowerCase();
      final categorias = ingrediente.categoriasIngrediente
          .map((categoria) => categoria.nome.toLowerCase())
          .join(' ');

      return nome.contains(termo) ||
          descricao.contains(termo) ||
          categorias.contains(termo);
    }).toList()
      ..sort(
        (a, b) => a.nome.toLowerCase().compareTo(
              b.nome.toLowerCase(),
            ),
      );
  }

  Future<void> _abrirCadastro() async {
    final result = await Navigator.of(context).pushNamed(
      '/ingredientes/form',
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _abrirEdicao(
    IngredienteModel ingrediente,
  ) async {
    final result = await Navigator.of(context).pushNamed(
      '/ingredientes/form',
      arguments: ingrediente,
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _alterarDisponibilidade(
    IngredienteModel ingrediente,
  ) async {
    final id = ingrediente.idIngrediente;

    if (id == null) {
      _snack(
        'Ingrediente inválido.',
        erro: true,
      );
      return;
    }

    final novoEstado = !ingrediente.disponivel;

    final confirmado = await _confirmar(
      titulo: novoEstado
          ? 'Tornar ingrediente disponível?'
          : 'Tornar ingrediente indisponível?',
      mensagem: novoEstado
          ? 'O ingrediente voltará a ficar disponível para uso.'
          : 'O ingrediente ficará indisponível, mas não será eliminado.',
      textoConfirmar: novoEstado ? 'Disponibilizar' : 'Indisponibilizar',
      corConfirmar: novoEstado ? _kGreen : _kRed,
    );

    if (!confirmado || !mounted) return;

    final provider = context.read<IngredienteProvider>();

    final sucesso = await provider.alterarDisponibilidadeIngrediente(
      id,
      novoEstado,
    );

    if (!mounted) return;

    if (sucesso) {
      _snack(
        novoEstado
            ? 'Ingrediente disponível com sucesso.'
            : 'Ingrediente indisponível com sucesso.',
      );
    } else {
      _snack(
        provider.erro ??
            'Não foi possível alterar a disponibilidade do ingrediente.',
        erro: true,
      );
    }
  }

  Future<void> _alterarEstado(
    IngredienteModel ingrediente,
  ) async {
    final id = ingrediente.idIngrediente;

    if (id == null) {
      _snack(
        'Ingrediente inválido.',
        erro: true,
      );
      return;
    }

    final novoEstado = !ingrediente.ativo;

    final confirmado = await _confirmar(
      titulo: novoEstado ? 'Activar ingrediente?' : 'Desactivar ingrediente?',
      mensagem: novoEstado
          ? 'O ingrediente voltará a ficar activo.'
          : 'O ingrediente será desactivado, mas as categorias associadas não serão eliminadas.',
      textoConfirmar: novoEstado ? 'Activar' : 'Desactivar',
      corConfirmar: novoEstado ? _kGreen : _kRed,
    );

    if (!confirmado || !mounted) return;

    final provider = context.read<IngredienteProvider>();

    final sucesso = await provider.alterarEstadoIngrediente(
      id,
      novoEstado,
    );

    if (!mounted) return;

    if (sucesso) {
      _snack(
        novoEstado
            ? 'Ingrediente activado com sucesso.'
            : 'Ingrediente desactivado com sucesso.',
      );
    } else {
      _snack(
        provider.erro ?? 'Não foi possível alterar o estado do ingrediente.',
        erro: true,
      );
    }
  }

  Future<void> _desativarIngrediente(
    IngredienteModel ingrediente,
  ) async {
    final id = ingrediente.idIngrediente;

    if (id == null) {
      _snack(
        'Ingrediente inválido.',
        erro: true,
      );
      return;
    }

    final confirmado = await _confirmar(
      titulo: 'Desactivar ingrediente?',
      mensagem:
          'O ingrediente será desactivado e ficará indisponível. As categorias associadas não serão eliminadas.',
      textoConfirmar: 'Desactivar',
      corConfirmar: _kRed,
    );

    if (!confirmado || !mounted) return;

    final provider = context.read<IngredienteProvider>();

    final sucesso = await provider.desativarIngrediente(id);

    if (!mounted) return;

    if (sucesso) {
      _snack('Ingrediente desactivado com sucesso.');
    } else {
      _snack(
        provider.erro ?? 'Não foi possível desactivar o ingrediente.',
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
        final ingredientes = _filtrarIngredientes(provider.ingredientes);

        final total = provider.ingredientes.length;
        final activos = provider.ingredientes.where((i) => i.ativo).length;
        final disponiveis =
            provider.ingredientes.where((i) => i.disponivel).length;
        final comEstoque =
            provider.ingredientes.where((i) => i.controlaEstoque).length;

        return Scaffold(
          backgroundColor: _kBg,
            drawer: const AppSidebar(
    currentRoute: '/ingredientes',
  ),
          appBar: AppBar(
            title: const Text('Ingredientes'),
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
            label: const Text('Novo ingrediente'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _recarregar,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _HeaderCard(
                    total: total,
                    activos: activos,
                    disponiveis: disponiveis,
                    comEstoque: comEstoque,
                  ),
                  const SizedBox(height: 16),
                  _SearchAndFilters(
                    pesquisa: _pesquisa,
                    filtro: _filtro,
                    categorias: provider.categorias,
                    idCategoriaFiltro: _idCategoriaFiltro,
                    onPesquisaChanged: (value) {
                      setState(() => _pesquisa = value);
                    },
                    onFiltroChanged: (value) {
                      setState(() => _filtro = value);
                    },
                    onCategoriaChanged: (value) {
                      setState(() => _idCategoriaFiltro = value);
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
                  else if (ingredientes.isEmpty)
                    const _EmptyCard()
                  else
                    ...ingredientes.map((ingrediente) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IngredienteCard(
                          ingrediente: ingrediente,
                          onEditar: () => _abrirEdicao(ingrediente),
                          onAlterarEstado: () => _alterarEstado(ingrediente),
                          onAlterarDisponibilidade: () =>
                              _alterarDisponibilidade(ingrediente),
                          onDesativar: () => _desativarIngrediente(ingrediente),
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
  final int activos;
  final int disponiveis;
  final int comEstoque;

  const _HeaderCard({
    required this.total,
    required this.activos,
    required this.disponiveis,
    required this.comEstoque,
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
            'Gestão de ingredientes',
            style: TextStyle(
              color: _kDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cadastre ingredientes, controle disponibilidade, estoque, imagens e categorias associadas.',
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
                icon: Icons.restaurant_menu,
                color: _kDark,
              ),
              _MetricChip(
                label: 'Activos',
                value: activos.toString(),
                icon: Icons.check_circle_outline,
                color: _kGreen,
              ),
              _MetricChip(
                label: 'Disponíveis',
                value: disponiveis.toString(),
                icon: Icons.verified_outlined,
                color: _kBlue,
              ),
              _MetricChip(
                label: 'Com estoque',
                value: comEstoque.toString(),
                icon: Icons.inventory_2_outlined,
                color: _kOrange,
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
  final _FiltroIngrediente filtro;
  final List<CategoriaIngredienteModel> categorias;
  final int? idCategoriaFiltro;
  final ValueChanged<String> onPesquisaChanged;
  final ValueChanged<_FiltroIngrediente> onFiltroChanged;
  final ValueChanged<int?> onCategoriaChanged;

  const _SearchAndFilters({
    required this.pesquisa,
    required this.filtro,
    required this.categorias,
    required this.idCategoriaFiltro,
    required this.onPesquisaChanged,
    required this.onFiltroChanged,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categoriasOrdenadas = [...categorias]
      ..sort(
        (a, b) {
          final ordem = a.ordem.compareTo(b.ordem);

          if (ordem != 0) return ordem;

          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        },
      );

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: onPesquisaChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar por nome, descrição ou categoria',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int?>(
            value: idCategoriaFiltro,
            decoration: const InputDecoration(
              labelText: 'Filtrar por categoria',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Todas as categorias'),
              ),
              ...categoriasOrdenadas.map((categoria) {
                return DropdownMenuItem<int?>(
                  value: categoria.idCategoriaIngrediente,
                  child: Text(categoria.nome),
                );
              }),
            ],
            onChanged: onCategoriaChanged,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: filtro == _FiltroIngrediente.todos,
                  onTap: () => onFiltroChanged(_FiltroIngrediente.todos),
                ),
                _FilterChip(
                  label: 'Activos',
                  selected: filtro == _FiltroIngrediente.activos,
                  onTap: () => onFiltroChanged(_FiltroIngrediente.activos),
                ),
                _FilterChip(
                  label: 'Inactivos',
                  selected: filtro == _FiltroIngrediente.inactivos,
                  onTap: () => onFiltroChanged(_FiltroIngrediente.inactivos),
                ),
                _FilterChip(
                  label: 'Disponíveis',
                  selected: filtro == _FiltroIngrediente.disponiveis,
                  onTap: () => onFiltroChanged(_FiltroIngrediente.disponiveis),
                ),
                _FilterChip(
                  label: 'Indisponíveis',
                  selected: filtro == _FiltroIngrediente.indisponiveis,
                  onTap: () =>
                      onFiltroChanged(_FiltroIngrediente.indisponiveis),
                ),
                _FilterChip(
                  label: 'Com categorias',
                  selected: filtro == _FiltroIngrediente.comCategorias,
                  onTap: () =>
                      onFiltroChanged(_FiltroIngrediente.comCategorias),
                ),
                _FilterChip(
                  label: 'Sem categorias',
                  selected: filtro == _FiltroIngrediente.semCategorias,
                  onTap: () =>
                      onFiltroChanged(_FiltroIngrediente.semCategorias),
                ),
                _FilterChip(
                  label: 'Com estoque',
                  selected: filtro == _FiltroIngrediente.comEstoque,
                  onTap: () => onFiltroChanged(_FiltroIngrediente.comEstoque),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredienteCard extends StatelessWidget {
  final IngredienteModel ingrediente;
  final VoidCallback onEditar;
  final VoidCallback onAlterarEstado;
  final VoidCallback onAlterarDisponibilidade;
  final VoidCallback onDesativar;

  const _IngredienteCard({
    required this.ingrediente,
    required this.onEditar,
    required this.onAlterarEstado,
    required this.onAlterarDisponibilidade,
    required this.onDesativar,
  });

  @override
  Widget build(BuildContext context) {
    final categorias = ingrediente.categoriasIngrediente;
    final ativo = ingrediente.ativo;
    final disponivel = ingrediente.disponivel;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _ImagemIngrediente(
                url: ingrediente.imagemPrincipalUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingrediente.nome,
                      style: const TextStyle(
                        color: _kDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ingrediente.descricao?.trim().isNotEmpty == true
                          ? ingrediente.descricao!.trim()
                          : 'Sem descrição',
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusBadge(
                          label: ativo ? 'Activo' : 'Inactivo',
                          color: ativo ? _kGreen : _kRed,
                        ),
                        _StatusBadge(
                          label: disponivel ? 'Disponível' : 'Indisponível',
                          color: disponivel ? _kBlue : _kRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (value) {
                  switch (value) {
                    case 'editar':
                      onEditar();
                      break;
                    case 'disponibilidade':
                      onAlterarDisponibilidade();
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
                      value: 'disponibilidade',
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          disponivel
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        title: Text(
                          disponivel
                              ? 'Tornar indisponível'
                              : 'Tornar disponível',
                        ),
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
                            'Desactivar ingrediente',
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
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallInfoChip(
                icon: Icons.payments_outlined,
                label:
                    'Preço adicional: ${ingrediente.precoAdicional.toStringAsFixed(2)}',
              ),
              _SmallInfoChip(
                icon: Icons.inventory_2_outlined,
                label: ingrediente.controlaEstoque
                    ? 'Estoque: ${ingrediente.quantidadeEstoque?.toStringAsFixed(2) ?? '0.00'}'
                    : 'Sem controle de estoque',
              ),
              _SmallInfoChip(
                icon: Icons.image_outlined,
                label:
                    '${ingrediente.imagens.length} imagem${ingrediente.imagens.length == 1 ? '' : 's'}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              categorias.isEmpty
                  ? 'Nenhuma categoria associada.'
                  : 'Categorias associadas:',
              style: const TextStyle(
                color: _kText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (categorias.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Este ingrediente ainda não está vinculado a nenhuma categoria.',
                style: TextStyle(
                  color: _kMuted,
                  fontSize: 13,
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categorias.map((categoria) {
                  return Chip(
                    label: Text(categoria.nome),
                    avatar: Icon(
                      categoria.principal
                          ? Icons.star
                          : Icons.category_outlined,
                      size: 16,
                      color: categoria.principal ? _kOrange : _kMuted,
                    ),
                    backgroundColor: const Color(0xFFF9FAFB),
                    side: const BorderSide(color: _kBorder),
                    labelStyle: const TextStyle(
                      color: _kText,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImagemIngrediente extends StatelessWidget {
  final String? url;

  const _ImagemIngrediente({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final imagem = url?.trim();

    if (imagem == null || imagem.isEmpty) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: _kOrange.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.restaurant_menu,
          color: _kOrange,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imagem,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 58,
            height: 58,
            color: _kOrange.withOpacity(0.10),
            child: const Icon(
              Icons.broken_image_outlined,
              color: _kOrange,
            ),
          );
        },
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
            Icons.restaurant_menu,
            color: _kMuted,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhum ingrediente encontrado.',
            style: TextStyle(
              color: _kDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Cadastre ingredientes para compor produtos, pratos e adicionais.',
            textAlign: TextAlign.center,
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