import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '/widgets/app_sidebar.dart';

const _kDark = Color(0xFF111827);
const _kOrange = Color(0xFFF97316);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kBlue = Color(0xFF2563EB);
const _kPurple = Color(0xFF7C3AED);
const _kText = Color(0xFF374151);
const _kMuted = Color(0xFF6B7280);
const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE5E7EB);

enum _FiltroProduto {
  todos,
  activos,
  inactivos,
  disponiveis,
  indisponiveis,
  destaques,
  promocionais,
  comIngredientes,
  semIngredientes,
  controlaEstoque,
  controlaIngredientes,
}

class ProdutoListScreen extends StatefulWidget {
  const ProdutoListScreen({super.key});

  @override
  State<ProdutoListScreen> createState() => _ProdutoListScreenState();
}

class _ProdutoListScreenState extends State<ProdutoListScreen> {
  _FiltroProduto _filtro = _FiltroProduto.todos;
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
    final provider = context.read<ProdutoProvider>();

    await provider.carregarCategorias();
    await provider.carregarProdutos();
  }

  List<ProdutoModel> _filtrarProdutos(
    List<ProdutoModel> produtos,
  ) {
    return produtos.where((produto) {
      final passaCategoria = _idCategoriaFiltro == null ||
          produto.categoriasProduto.any(
            (categoria) => categoria.idCategoriaProduto == _idCategoriaFiltro,
          );

      if (!passaCategoria) return false;

      final realmenteDisponivel = produto.disponivelCalculado;

      final passaFiltro = switch (_filtro) {
        _FiltroProduto.todos => true,
        _FiltroProduto.activos => produto.ativo,
        _FiltroProduto.inactivos => !produto.ativo,
        _FiltroProduto.disponiveis => realmenteDisponivel,
        _FiltroProduto.indisponiveis => !realmenteDisponivel,
        _FiltroProduto.destaques => produto.destaque,
        _FiltroProduto.promocionais => produto.promocional,
        _FiltroProduto.comIngredientes => produto.ingredientes.isNotEmpty,
        _FiltroProduto.semIngredientes => produto.ingredientes.isEmpty,
        _FiltroProduto.controlaEstoque => produto.controlaEstoque,
        _FiltroProduto.controlaIngredientes =>
          produto.controlaEstoquePorIngredientes,
      };

      if (!passaFiltro) return false;

      final termo = _pesquisa.trim().toLowerCase();

      if (termo.isEmpty) return true;

      final nome = produto.nome.toLowerCase();
      final descricao = (produto.descricao ?? '').toLowerCase();
      final categorias = produto.categoriasProduto
          .map((categoria) => categoria.nome.toLowerCase())
          .join(' ');
      final ingredientes = produto.ingredientes
          .map((ingrediente) => ingrediente.nomeIngrediente.toLowerCase())
          .join(' ');

      return nome.contains(termo) ||
          descricao.contains(termo) ||
          categorias.contains(termo) ||
          ingredientes.contains(termo);
    }).toList()
  ..sort(
    (a, b) => a.nome.toLowerCase().compareTo(
          b.nome.toLowerCase(),
        ),
  );
  }

  Future<void> _abrirCadastro() async {
    final result = await Navigator.of(context).pushNamed(
      '/produtos/form',
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }

  Future<void> _abrirEdicao(
    ProdutoModel produto,
  ) async {
    final result = await Navigator.of(context).pushNamed(
      '/produtos/form',
      arguments: produto,
    );

    if (result == true && mounted) {
      await _recarregar();
    }
  }



  Future<void> _alterarDestaque(
    ProdutoModel produto,
  ) async {
    final id = produto.idProduto;

    if (id == null) {
      _snack('Produto inválido.', erro: true);
      return;
    }

    final novoEstado = !produto.destaque;

    final provider = context.read<ProdutoProvider>();

    final sucesso = await provider.alterarDestaqueProduto(
      id,
      novoEstado,
    );

    if (!mounted) return;

    if (sucesso) {
      _snack(
        novoEstado
            ? 'Produto marcado como destaque.'
            : 'Produto removido dos destaques.',
      );
    } else {
      _snack(
        provider.erro ?? 'Não foi possível alterar o destaque.',
        erro: true,
      );
    }
  }

  Future<void> _alterarEstado(
    ProdutoModel produto,
  ) async {
    final id = produto.idProduto;

    if (id == null) {
      _snack('Produto inválido.', erro: true);
      return;
    }

    final novoEstado = !produto.ativo;

    final confirmado = await _confirmar(
      titulo: novoEstado ? 'Activar produto?' : 'Desactivar produto?',
      mensagem: novoEstado
          ? 'O produto voltará a ficar activo.'
          : 'O produto será desactivado, ficará indisponível, sem destaque e sem promoção.',
      textoConfirmar: novoEstado ? 'Activar' : 'Desactivar',
      corConfirmar: novoEstado ? _kGreen : _kRed,
    );

    if (!confirmado || !mounted) return;

    final provider = context.read<ProdutoProvider>();

    final sucesso = await provider.alterarEstadoProduto(
      id,
      novoEstado,
    );

    if (!mounted) return;

    if (sucesso) {
      _snack(
        novoEstado
            ? 'Produto activado com sucesso.'
            : 'Produto desactivado com sucesso.',
      );
    } else {
      _snack(
        provider.erro ?? 'Não foi possível alterar o estado do produto.',
        erro: true,
      );
    }
  }

  Future<void> _desativarProduto(
    ProdutoModel produto,
  ) async {
    final id = produto.idProduto;

    if (id == null) {
      _snack('Produto inválido.', erro: true);
      return;
    }

    final confirmado = await _confirmar(
      titulo: 'Desactivar produto?',
      mensagem:
          'O produto será desactivado, ficará indisponível, sem destaque e sem promoção. Categorias e ingredientes associados não serão eliminados.',
      textoConfirmar: 'Desactivar',
      corConfirmar: _kRed,
    );

    if (!confirmado || !mounted) return;

    final provider = context.read<ProdutoProvider>();

    final sucesso = await provider.desativarProduto(id);

    if (!mounted) return;

    if (sucesso) {
      _snack('Produto desactivado com sucesso.');
    } else {
      _snack(
        provider.erro ?? 'Não foi possível desactivar o produto.',
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
    return Consumer<ProdutoProvider>(
      builder: (context, provider, _) {
        final produtos = _filtrarProdutos(provider.produtos);

        final total = provider.produtos.length;
        final activos = provider.produtos.where((p) => p.ativo).length;
        final disponiveis =
            provider.produtos.where((p) => p.disponivelCalculado).length;
        final promocionais =
            provider.produtos.where((p) => p.promocional).length;

        return Scaffold(
          backgroundColor: _kBg,
          drawer: const AppSidebar(
            currentRoute: '/produtos',
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: _kOrange,
            foregroundColor: Colors.white,
            onPressed: _abrirCadastro,
            icon: const Icon(Icons.add),
            label: const Text('Novo produto'),
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
                    promocionais: promocionais,
                    onRefresh: _recarregar,
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
                  else if (produtos.isEmpty)
                    const _EmptyCard()
                  else
                    ...produtos.map((produto) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                     child: _ProdutoCard(
                        produto: produto,
                        onEditar: () => _abrirEdicao(produto),
                        onAlterarEstado: () => _alterarEstado(produto),
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
  final int promocionais;
  final Future<void> Function() onRefresh;

  const _HeaderCard({
    required this.total,
    required this.activos,
    required this.disponiveis,
    required this.promocionais,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Abrir menu',
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu_rounded),
                color: _kDark,
              );
            },
          ),
          const SizedBox(width: 8),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Produtos',
                  style: TextStyle(
                    color: _kDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gerencie refeições, promoções, estoque próprio, ingredientes e disponibilidade calculada.',
                  style: TextStyle(
                    color: _kMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricChip(
                      label: 'Total',
                      value: total.toString(),
                      icon: Icons.restaurant_menu_rounded,
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
                      label: 'Promoções',
                      value: promocionais.toString(),
                      icon: Icons.local_offer_outlined,
                      color: _kGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Recarregar',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            color: _kDark,
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final String pesquisa;
  final _FiltroProduto filtro;
  final List<CategoriaProdutoModel> categorias;
  final int? idCategoriaFiltro;
  final ValueChanged<String> onPesquisaChanged;
  final ValueChanged<_FiltroProduto> onFiltroChanged;
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
      ..sort((a, b) {
        final ordem = a.ordem.compareTo(b.ordem);

        if (ordem != 0) return ordem;

        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      });

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: onPesquisaChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar por nome, descrição, categoria ou ingrediente',
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
                  value: categoria.idCategoriaProduto,
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
                  selected: filtro == _FiltroProduto.todos,
                  onTap: () => onFiltroChanged(_FiltroProduto.todos),
                ),
                _FilterChip(
                  label: 'Activos',
                  selected: filtro == _FiltroProduto.activos,
                  onTap: () => onFiltroChanged(_FiltroProduto.activos),
                ),
                _FilterChip(
                  label: 'Inactivos',
                  selected: filtro == _FiltroProduto.inactivos,
                  onTap: () => onFiltroChanged(_FiltroProduto.inactivos),
                ),
                _FilterChip(
                  label: 'Disponíveis',
                  selected: filtro == _FiltroProduto.disponiveis,
                  onTap: () => onFiltroChanged(_FiltroProduto.disponiveis),
                ),
                _FilterChip(
                  label: 'Indisponíveis',
                  selected: filtro == _FiltroProduto.indisponiveis,
                  onTap: () => onFiltroChanged(_FiltroProduto.indisponiveis),
                ),
                _FilterChip(
                  label: 'Destaques',
                  selected: filtro == _FiltroProduto.destaques,
                  onTap: () => onFiltroChanged(_FiltroProduto.destaques),
                ),
                _FilterChip(
                  label: 'Promoções',
                  selected: filtro == _FiltroProduto.promocionais,
                  onTap: () => onFiltroChanged(_FiltroProduto.promocionais),
                ),
                _FilterChip(
                  label: 'Com ingredientes',
                  selected: filtro == _FiltroProduto.comIngredientes,
                  onTap: () => onFiltroChanged(_FiltroProduto.comIngredientes),
                ),
                _FilterChip(
                  label: 'Sem ingredientes',
                  selected: filtro == _FiltroProduto.semIngredientes,
                  onTap: () => onFiltroChanged(_FiltroProduto.semIngredientes),
                ),
                _FilterChip(
                  label: 'Estoque próprio',
                  selected: filtro == _FiltroProduto.controlaEstoque,
                  onTap: () => onFiltroChanged(_FiltroProduto.controlaEstoque),
                ),
                _FilterChip(
                  label: 'Por ingredientes',
                  selected: filtro == _FiltroProduto.controlaIngredientes,
                  onTap: () =>
                      onFiltroChanged(_FiltroProduto.controlaIngredientes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final ProdutoModel produto;
  final VoidCallback onEditar;
  final VoidCallback onAlterarEstado;

  const _ProdutoCard({
    required this.produto,
    required this.onEditar,
    required this.onAlterarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final realmenteDisponivel = produto.disponivelCalculado;
    final motivo = produto.motivoIndisponibilidade?.trim();

    
    
return Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: onEditar,
    borderRadius: BorderRadius.circular(18), // Garante que o efeito do clique respeite os cantos arredondados
    child: Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _ImagemProduto(
                url: produto.imagemPrincipalUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        color: _kDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      produto.descricao?.trim().isNotEmpty == true
                          ? produto.descricao!.trim()
                          : 'Sem descrição',
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PrecoProduto(produto: produto),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Tooltip(
                message: produto.ativo
                    ? 'Desactivar produto'
                    : 'Activar produto',
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: produto.ativo
                        ? _kGreen.withOpacity(0.08)
                        : _kRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: produto.ativo
                          ? _kGreen.withOpacity(0.20)
                          : _kRed.withOpacity(0.20),
                    ),
                  ),
                  child: Switch(
                    value: produto.ativo,
                    activeColor: _kGreen,
                    inactiveThumbColor: _kRed,
                    inactiveTrackColor: _kRed.withOpacity(0.20),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (_) => onAlterarEstado(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Tooltip(
                message: 'Editar produto',
                child: Material(
                  color: _kOrange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onEditar,
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.edit_outlined,
                        color: _kOrange,
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusBadge(
                label: produto.ativo ? 'Activo' : 'Inactivo',
                color: produto.ativo ? _kGreen : _kRed,
              ),
             
              _StatusBadge(
                label: realmenteDisponivel
                    ? 'Disponível real'
                    : 'Indisponível real',
                color: realmenteDisponivel ? _kGreen : _kRed,
              ),
              if (produto.destaque)
                const _StatusBadge(
                  label: 'Destaque',
                  color: _kPurple,
                ),
              if (produto.promocional)
                const _StatusBadge(
                  label: 'Promoção',
                  color: _kGreen,
                ),
            ],
          ),
          if (!realmenteDisponivel &&
              motivo != null &&
              motivo.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _kRed.withOpacity(0.18),
                ),
              ),
              child: Text(
                motivo,
                style: const TextStyle(
                  color: _kRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SmallInfoChip(
                  icon: Icons.inventory_2_outlined,
                  label: produto.controlaEstoque
                      ? 'Estoque: ${_fmt(produto.quantidadeEstoque)}'
                      : 'Sem estoque próprio',
                ),
                _SmallInfoChip(
                  icon: Icons.kitchen_outlined,
                  label: produto.controlaEstoquePorIngredientes
                      ? 'Controla por ingredientes'
                      : 'Sem controlo por ingredientes',
                ),
                _SmallInfoChip(
                  icon: Icons.calculate_outlined,
                  label:
                      'Qtd. possível: ${_fmt(produto.quantidadeDisponivelCalculada)}',
                ),
                _SmallInfoChip(
                  icon: Icons.timer_outlined,
                  label: produto.tempoPreparoMinutos != null
                      ? '${produto.tempoPreparoMinutos} min'
                      : 'Sem tempo definido',
                ),
                _SmallInfoChip(
                  icon: Icons.image_outlined,
                  label:
                      '${produto.imagens.length} imagem${produto.imagens.length == 1 ? '' : 's'}',
                ),
                _SmallInfoChip(
                  icon: Icons.restaurant_outlined,
                  label:
                      '${produto.ingredientes.length} ingrediente${produto.ingredientes.length == 1 ? '' : 's'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CategoriasProduto(categorias: produto.categoriasProduto),
          const SizedBox(height: 10),
          _IngredientesProduto(ingredientes: produto.ingredientes),
        ],
      ),
    ),
  ),
);
  }

  static String _fmt(double? value) {
    if (value == null) return '-';

    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }
}

class _PrecoProduto extends StatelessWidget {
  final ProdutoModel produto;

  const _PrecoProduto({
    required this.produto,
  });

  @override
  Widget build(BuildContext context) {
    if (produto.promocional && produto.precoPromocional != null) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            produto.preco.toStringAsFixed(2),
            style: const TextStyle(
              color: _kRed,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.lineThrough,
              decorationColor: _kRed,
              decorationThickness: 2,
            ),
          ),
          Text(
            produto.precoPromocional!.toStringAsFixed(2),
            style: const TextStyle(
              color: _kGreen,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }

    return Text(
      produto.preco.toStringAsFixed(2),
      style: const TextStyle(
        color: _kDark,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CategoriasProduto extends StatelessWidget {
  final List<CategoriaProdutoResumoModel> categorias;

  const _CategoriasProduto({
    required this.categorias,
  });

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Nenhuma categoria associada.',
          style: TextStyle(
            color: _kMuted,
            fontSize: 13,
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categorias.map((categoria) {
          return Chip(
            label: Text(categoria.nome),
            avatar: Icon(
              categoria.principal ? Icons.star : Icons.category_outlined,
              size: 16,
              color: categoria.principal ? _kOrange : _kMuted,
            ),
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
    );
  }
}

class _IngredientesProduto extends StatelessWidget {
  final List<ProdutoIngredienteModel> ingredientes;

  const _IngredientesProduto({
    required this.ingredientes,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredientes.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Nenhum ingrediente associado.',
          style: TextStyle(
            color: _kMuted,
            fontSize: 13,
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ingredientes.map((ingrediente) {
          return Chip(
            label: Text(
              '${ingrediente.nomeIngrediente} (${ingrediente.quantidadePadrao}x)',
            ),
            avatar: Icon(
              ingrediente.obrigatorio
                  ? Icons.lock_outline
                  : Icons.add_circle_outline,
              size: 16,
              color: ingrediente.obrigatorio ? _kRed : _kGreen,
            ),
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
    );
  }
}

class _ImagemProduto extends StatelessWidget {
  final String? url;

  const _ImagemProduto({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final imagem = url?.trim();

    if (imagem == null || imagem.isEmpty) {
      return _placeholder();
    }

    final uri = Uri.tryParse(imagem);
    final imagemRemota =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    final imagemLocal = File(imagem);

    Widget child;

    if (imagemRemota) {
      child = Image.network(
        imagem,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _erro(),
      );
    } else if (imagemLocal.existsSync()) {
      child = Image.file(
        imagemLocal,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _erro(),
      );
    } else {
      child = _erro();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: child,
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _kOrange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.restaurant_menu_rounded,
        color: _kOrange,
      ),
    );
  }

  Widget _erro() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _kOrange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.broken_image_outlined,
        color: _kOrange,
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
            Icons.restaurant_menu_rounded,
            color: _kMuted,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhum produto encontrado.',
            style: TextStyle(
              color: _kDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Cadastre produtos para compor o catálogo.',
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