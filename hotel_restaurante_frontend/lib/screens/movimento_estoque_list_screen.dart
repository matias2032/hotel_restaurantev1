import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_sidebar.dart';

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

class MovimentoEstoqueListScreen extends StatefulWidget {
  const MovimentoEstoqueListScreen({super.key});

  @override
  State<MovimentoEstoqueListScreen> createState() =>
      _MovimentoEstoqueListScreenState();
}

class _MovimentoEstoqueListScreenState
    extends State<MovimentoEstoqueListScreen> {
  TipoItemEstoqueModel? _tipoItemFiltro;
  TipoMovimentoEstoqueModel? _tipoMovimentoFiltro;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _recarregar();
    });
  }

  Future<void> _recarregar() async {
    await context.read<MovimentoEstoqueProvider>().carregarMovimentos(
          tipoItem: _tipoItemFiltro,
          tipoMovimento: _tipoMovimentoFiltro,
        );
  }

  List<MovimentoEstoqueModel> _filtrarLocalmente(
    List<MovimentoEstoqueModel> movimentos,
  ) {
    final termo = _pesquisa.trim().toLowerCase();

    if (termo.isEmpty) {
      return movimentos;
    }

    return movimentos.where((movimento) {
      final item = movimento.nomeItem.toLowerCase();
      final motivo = movimento.motivo.toLowerCase();
      final observacoes = (movimento.observacoes ?? '').toLowerCase();
      final operador = movimento.operador.toLowerCase();
      final tipoItem = movimento.tipoItem.label.toLowerCase();
      final tipoMovimento = movimento.tipoMovimento.label.toLowerCase();

      return item.contains(termo) ||
          motivo.contains(termo) ||
          observacoes.contains(termo) ||
          operador.contains(termo) ||
          tipoItem.contains(termo) ||
          tipoMovimento.contains(termo);
    }).toList();
  }

  int _contarTipo(
    List<MovimentoEstoqueModel> movimentos,
    TipoMovimentoEstoqueModel tipo,
  ) {
    return movimentos.where((item) => item.tipoMovimento == tipo).length;
  }

  void _limparFiltros() {
    setState(() {
      _tipoItemFiltro = null;
      _tipoMovimentoFiltro = null;
      _pesquisa = '';
    });

    _recarregar();
  }

  Color _corTipoMovimento(TipoMovimentoEstoqueModel tipo) {
    return switch (tipo) {
      TipoMovimentoEstoqueModel.entrada => _kGreen,
      TipoMovimentoEstoqueModel.saida => _kRed,
      TipoMovimentoEstoqueModel.perda => _kRed,
      TipoMovimentoEstoqueModel.vencimento => _kRed,
      TipoMovimentoEstoqueModel.ajuste => _kBlue,
      TipoMovimentoEstoqueModel.correcao => _kPurple,
      TipoMovimentoEstoqueModel.inventario => _kOrange,
    };
  }

  IconData _iconeTipoMovimento(TipoMovimentoEstoqueModel tipo) {
    return switch (tipo) {
      TipoMovimentoEstoqueModel.entrada => Icons.add_circle_outline,
      TipoMovimentoEstoqueModel.saida => Icons.remove_circle_outline,
      TipoMovimentoEstoqueModel.perda => Icons.warning_amber_rounded,
      TipoMovimentoEstoqueModel.vencimento => Icons.event_busy_outlined,
      TipoMovimentoEstoqueModel.ajuste => Icons.tune_rounded,
      TipoMovimentoEstoqueModel.correcao => Icons.edit_note_rounded,
      TipoMovimentoEstoqueModel.inventario => Icons.fact_check_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovimentoEstoqueProvider>(
      builder: (context, provider, _) {
        final movimentos = _filtrarLocalmente(provider.movimentos);

        final total = provider.movimentos.length;
        final entradas = _contarTipo(
          provider.movimentos,
          TipoMovimentoEstoqueModel.entrada,
        );
        final saidas = provider.movimentos.where((item) {
          return item.tipoMovimento == TipoMovimentoEstoqueModel.saida ||
              item.tipoMovimento == TipoMovimentoEstoqueModel.perda ||
              item.tipoMovimento == TipoMovimentoEstoqueModel.vencimento;
        }).length;
        final ajustes = provider.movimentos.where((item) {
          return item.tipoMovimento == TipoMovimentoEstoqueModel.ajuste ||
              item.tipoMovimento == TipoMovimentoEstoqueModel.correcao ||
              item.tipoMovimento == TipoMovimentoEstoqueModel.inventario;
        }).length;

        return Scaffold(
          backgroundColor: _kBg,
          drawer: const AppSidebar(
            currentRoute: '/movimentos-estoque',
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _recarregar,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _HeaderCard(
                    total: total,
                    entradas: entradas,
                    saidas: saidas,
                    ajustes: ajustes,
                    onRefresh: _recarregar,
                  ),
                  const SizedBox(height: 16),
                  _FiltrosCard(
                    pesquisa: _pesquisa,
                    tipoItemFiltro: _tipoItemFiltro,
                    tipoMovimentoFiltro: _tipoMovimentoFiltro,
                    onPesquisaChanged: (value) {
                      setState(() => _pesquisa = value);
                    },
                    onTipoItemChanged: (value) async {
                      setState(() => _tipoItemFiltro = value);
                      await _recarregar();
                    },
                    onTipoMovimentoChanged: (value) async {
                      setState(() => _tipoMovimentoFiltro = value);
                      await _recarregar();
                    },
                    onLimpar: _limparFiltros,
                  ),
                  const SizedBox(height: 16),
                  if (provider.carregando)
                    const _LoadingCard()
                  else if (provider.temErro)
                    _ErrorCard(
                      mensagem: provider.erro ?? 'Erro inesperado.',
                      onRetry: _recarregar,
                    )
                  else if (movimentos.isEmpty)
                    const _EmptyCard()
                  else
                    ...movimentos.map((movimento) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MovimentoCard(
                          movimento: movimento,
                          cor: _corTipoMovimento(movimento.tipoMovimento),
                          icone: _iconeTipoMovimento(
                            movimento.tipoMovimento,
                          ),
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
  final int entradas;
  final int saidas;
  final int ajustes;
  final Future<void> Function() onRefresh;

  const _HeaderCard({
    required this.total,
    required this.entradas,
    required this.saidas,
    required this.ajustes,
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
              Icons.inventory_2_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Movimentos de Estoque',
                  style: TextStyle(
                    color: _kDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Histórico administrativo de entradas, saídas, perdas, ajustes, correções e inventários.',
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
                      icon: Icons.receipt_long_rounded,
                      color: _kDark,
                    ),
                    _MetricChip(
                      label: 'Entradas',
                      value: entradas.toString(),
                      icon: Icons.add_circle_outline,
                      color: _kGreen,
                    ),
                    _MetricChip(
                      label: 'Saídas/Perdas',
                      value: saidas.toString(),
                      icon: Icons.remove_circle_outline,
                      color: _kRed,
                    ),
                    _MetricChip(
                      label: 'Ajustes',
                      value: ajustes.toString(),
                      icon: Icons.tune_rounded,
                      color: _kBlue,
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

class _FiltrosCard extends StatelessWidget {
  final String pesquisa;
  final TipoItemEstoqueModel? tipoItemFiltro;
  final TipoMovimentoEstoqueModel? tipoMovimentoFiltro;
  final ValueChanged<String> onPesquisaChanged;
  final ValueChanged<TipoItemEstoqueModel?> onTipoItemChanged;
  final ValueChanged<TipoMovimentoEstoqueModel?> onTipoMovimentoChanged;
  final VoidCallback onLimpar;

  const _FiltrosCard({
    required this.pesquisa,
    required this.tipoItemFiltro,
    required this.tipoMovimentoFiltro,
    required this.onPesquisaChanged,
    required this.onTipoItemChanged,
    required this.onTipoMovimentoChanged,
    required this.onLimpar,
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
              hintText: 'Pesquisar por item, motivo, operador ou observações',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TipoItemEstoqueModel?>(
                  value: tipoItemFiltro,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de item',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<TipoItemEstoqueModel?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    ...TipoItemEstoqueModel.values.map((tipo) {
                      return DropdownMenuItem<TipoItemEstoqueModel?>(
                        value: tipo,
                        child: Text(tipo.label),
                      );
                    }),
                  ],
                  onChanged: onTipoItemChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TipoMovimentoEstoqueModel?>(
                  value: tipoMovimentoFiltro,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de movimento',
                    prefixIcon: Icon(Icons.swap_vert_rounded),
                  ),
                  items: [
                    const DropdownMenuItem<TipoMovimentoEstoqueModel?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    ...TipoMovimentoEstoqueModel.values.map((tipo) {
                      return DropdownMenuItem<TipoMovimentoEstoqueModel?>(
                        value: tipo,
                        child: Text(tipo.label),
                      );
                    }),
                  ],
                  onChanged: onTipoMovimentoChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onLimpar,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpar filtros'),
              style: TextButton.styleFrom(
                foregroundColor: _kOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovimentoCard extends StatelessWidget {
  final MovimentoEstoqueModel movimento;
  final Color cor;
  final IconData icone;

  const _MovimentoCard({
    required this.movimento,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: cor.withOpacity(0.12),
                foregroundColor: cor,
                child: Icon(icone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movimento.nomeItem,
                      style: const TextStyle(
                        color: _kDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${movimento.tipoItem.label} • ${movimento.tipoMovimento.label}',
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                label: movimento.tipoMovimento.label,
                color: cor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Anterior',
                  value: _fmtQuantidade(movimento.quantidadeAnterior),
                  icon: Icons.history_rounded,
                ),
              ),
              Expanded(
                child: _InfoTile(
                  label: 'Movimentada',
                  value: _fmtQuantidade(movimento.quantidadeMovimentada),
                  icon: Icons.swap_vert_rounded,
                ),
              ),
              Expanded(
                child: _InfoTile(
                  label: 'Posterior',
                  value: _fmtQuantidade(movimento.quantidadePosterior),
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SmallInfoChip(
                  icon: Icons.person_outline,
                  label: movimento.operador,
                ),
                _SmallInfoChip(
                  icon: Icons.schedule_rounded,
                  label: _fmtDateTime(movimento.movimentadoEm),
                ),
                _SmallInfoChip(
                  icon: Icons.source_outlined,
                  label: movimento.origem?.label ?? 'Manual',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _TextoHistorico(
            titulo: 'Motivo',
            texto: movimento.motivo,
          ),
          if (movimento.observacoes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _TextoHistorico(
              titulo: 'Observações',
              texto: movimento.observacoes!.trim(),
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtQuantidade(double? value) {
    if (value == null) return '-';

    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(3);
  }

  static String _fmtDateTime(DateTime? value) {
    if (value == null) return '-';

    final dia = value.day.toString().padLeft(2, '0');
    final mes = value.month.toString().padLeft(2, '0');
    final ano = value.year.toString();
    final hora = value.hour.toString().padLeft(2, '0');
    final minuto = value.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: _kMuted,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: _kMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: _kDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextoHistorico extends StatelessWidget {
  final String titulo;
  final String texto;

  const _TextoHistorico({
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: _kText,
            fontSize: 13,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: '$titulo: ',
              style: const TextStyle(
                color: _kDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(text: texto),
          ],
        ),
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
            Icons.inventory_2_outlined,
            color: _kMuted,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhum movimento encontrado.',
            style: TextStyle(
              color: _kDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Quando forem feitos ajustes administrativos de estoque, eles aparecerão aqui.',
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