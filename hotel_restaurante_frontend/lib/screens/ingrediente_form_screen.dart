import 'dart:io';

import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class IngredienteFormScreen extends StatefulWidget {
  const IngredienteFormScreen({super.key});

  @override
  State<IngredienteFormScreen> createState() => _IngredienteFormScreenState();
}

class _IngredienteFormScreenState extends State<IngredienteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _precoAdicionalCtrl = TextEditingController(text: '0.00');
  final _quantidadeEstoqueCtrl = TextEditingController();
  final _motivoMovimentoOutroCtrl = TextEditingController();
  final _observacoesMovimentoEstoqueCtrl = TextEditingController();

  IngredienteModel? _ingredienteEdicao;
  TipoMovimentoEstoqueModel? _tipoMovimentoEstoqueSelecionado;

  bool _carregouArgumentos = false;
  bool _salvando = false;
  bool _dragging = false;

  bool _ativo = true;
  bool _controlaEstoque = false;

  List<CategoriaIngredienteResumoModel> _categoriasSelecionadas = [];
  List<IngredienteImagemModel> _imagens = [];

  bool get _modoEdicao => _ingredienteEdicao != null;

  double get _quantidadeEstoqueAnterior {
    return _ingredienteEdicao?.quantidadeEstoque ?? 0.0;
  }

  double get _quantidadeEstoqueActualForm {
    return _parseDoubleNullable(_quantidadeEstoqueCtrl.text) ?? 0.0;
  }

  bool get _quantidadeEstoqueFoiAlterada {
    if (!_modoEdicao) return false;
    if (!_controlaEstoque) return false;

    return _quantidadeEstoqueAnterior != _quantidadeEstoqueActualForm;
  }

  bool get _estoqueAumentou {
    return _quantidadeEstoqueActualForm > _quantidadeEstoqueAnterior;
  }

  bool get _estoqueReduziu {
    return _quantidadeEstoqueActualForm < _quantidadeEstoqueAnterior;
  }

  String get _motivoMovimentoEstoque {
    if (_tipoMovimentoEstoqueSelecionado == TipoMovimentoEstoqueModel.outros) {
      return _motivoMovimentoOutroCtrl.text.trim();
    }

    return _tipoMovimentoEstoqueSelecionado?.label ?? '';
  }

  List<TipoMovimentoEstoqueModel> get _tiposMovimentoPermitidos {
    if (_estoqueAumentou) {
      return const [
        TipoMovimentoEstoqueModel.entrada,
        TipoMovimentoEstoqueModel.ajuste,
        TipoMovimentoEstoqueModel.correcao,
        TipoMovimentoEstoqueModel.inventario,
        TipoMovimentoEstoqueModel.outros,
      ];
    }

    if (_estoqueReduziu) {
      return const [
        TipoMovimentoEstoqueModel.saida,
        TipoMovimentoEstoqueModel.perda,
        TipoMovimentoEstoqueModel.vencimento,
        TipoMovimentoEstoqueModel.ajuste,
        TipoMovimentoEstoqueModel.correcao,
        TipoMovimentoEstoqueModel.inventario,
        TipoMovimentoEstoqueModel.outros,
      ];
    }

    return const [
      TipoMovimentoEstoqueModel.entrada,
      TipoMovimentoEstoqueModel.saida,
      TipoMovimentoEstoqueModel.perda,
      TipoMovimentoEstoqueModel.vencimento,
      TipoMovimentoEstoqueModel.ajuste,
      TipoMovimentoEstoqueModel.correcao,
      TipoMovimentoEstoqueModel.inventario,
      TipoMovimentoEstoqueModel.outros,
    ];
  }

  static const List<String> _extensoesImagem = [
    'jpg',
    'jpeg',
    'jfif',
    'jpe',
    'png',
    'webp',
    'gif',
    'bmp',
    'dib',
    'heic',
    'heif',
    'tif',
    'tiff',
    'svg',
    'avif',
    'ico',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<IngredienteProvider>().carregarCategorias(
            somenteAtivas: true,
          );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarArgumentos();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoAdicionalCtrl.dispose();
    _quantidadeEstoqueCtrl.dispose();
    _motivoMovimentoOutroCtrl.dispose();
    _observacoesMovimentoEstoqueCtrl.dispose();
    super.dispose();
  }

  void _carregarArgumentos() {
    if (_carregouArgumentos) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is IngredienteModel) {
      _ingredienteEdicao = args;

      _nomeCtrl.text = args.nome;
      _descricaoCtrl.text = args.descricao ?? '';
      _precoAdicionalCtrl.text = args.precoAdicional.toStringAsFixed(2);
      _quantidadeEstoqueCtrl.text = args.quantidadeEstoque != null
          ? args.quantidadeEstoque.toString()
          : '';

      _ativo = args.ativo;
      _controlaEstoque = args.controlaEstoque;

      _categoriasSelecionadas = [...args.categoriasIngrediente];
      _imagens = [...args.imagens];
    }

    _carregouArgumentos = true;
  }

  int? _idUsuarioLogado() {
    return SessaoService.instance.idUsuario;
  }

  bool _validarMovimentoEstoque() {
    if (!_quantidadeEstoqueFoiAlterada) return true;

    if (_tipoMovimentoEstoqueSelecionado == null) {
      _snack(
        'Selecione o motivo do movimento de estoque.',
        erro: true,
      );
      return false;
    }

    if (_tipoMovimentoEstoqueSelecionado == TipoMovimentoEstoqueModel.outros &&
        _motivoMovimentoOutroCtrl.text.trim().isEmpty) {
      _snack(
        'Informe o motivo quando selecionar Outros.',
        erro: true,
      );
      return false;
    }

    final idUsuario = _idUsuarioLogado();

    if (idUsuario == null) {
      _snack(
        'Não foi possível identificar o usuário responsável pelo movimento.',
        erro: true,
      );
      return false;
    }

    return true;
  }

  void _resetarMovimentoEstoque() {
    _tipoMovimentoEstoqueSelecionado = null;
    _motivoMovimentoOutroCtrl.clear();
    _observacoesMovimentoEstoqueCtrl.clear();
  }

  Future<void> _escolherImagens() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _extensoesImagem,
    );

    if (result == null || result.files.isEmpty) return;

    final paths = result.files
        .map((file) => file.path)
        .whereType<String>()
        .where((path) => path.trim().isNotEmpty)
        .toList();

    _adicionarImagensPorPaths(paths);
  }

  void _adicionarImagensPorDrop(
    List<XFile> files,
  ) {
    final paths = files
        .map((file) => file.path)
        .where((path) => path.trim().isNotEmpty)
        .toList();

    _adicionarImagensPorPaths(paths);
  }

  void _adicionarImagensPorPaths(
    List<String> paths,
  ) {
    final novas = <IngredienteImagemModel>[];

    for (final path in paths) {
      if (!_isImagemSuportada(path)) continue;

      final jaExiste = _imagens.any(
        (imagem) => imagem.imagemUrl.trim() == path.trim(),
      );

      if (jaExiste) continue;

      novas.add(
        IngredienteImagemModel(
          imagemUrl: path.trim(),
          principal: _imagens.isEmpty && novas.isEmpty,
          ordem: _imagens.length + novas.length,
        ),
      );
    }

    if (novas.isEmpty) {
      _snack(
        'Nenhuma imagem válida foi adicionada.',
        erro: true,
      );
      return;
    }

    setState(() {
      _imagens = [
        ..._imagens,
        ...novas,
      ];

      _garantirImagemPrincipal();
    });
  }

  bool _isImagemSuportada(
    String path,
  ) {
    final lower = path.trim().toLowerCase();

    return _extensoesImagem.any(
      (ext) => lower.endsWith('.$ext'),
    );
  }

  void _removerImagem(
    IngredienteImagemModel imagem,
  ) {
    setState(() {
      _imagens = _imagens.where((item) => item != imagem).toList();
      _garantirImagemPrincipal();
      _reordenarImagens();
    });
  }

  void _definirImagemPrincipal(
    IngredienteImagemModel imagem,
  ) {
    setState(() {
      _imagens = _imagens.map((item) {
        return item.copyWith(
          principal: item == imagem,
        );
      }).toList();
    });
  }

  void _garantirImagemPrincipal() {
    if (_imagens.isEmpty) return;

    final temPrincipal = _imagens.any((imagem) => imagem.principal);

    if (temPrincipal) return;

    _imagens = [
      _imagens.first.copyWith(principal: true),
      ..._imagens.skip(1),
    ];
  }

  void _reordenarImagens() {
    _imagens = _imagens.asMap().entries.map((entry) {
      return entry.value.copyWith(
        ordem: entry.key,
      );
    }).toList();
  }

  void _toggleCategoria(
    CategoriaIngredienteModel categoria,
  ) {
    final id = categoria.idCategoriaIngrediente;

    if (id == null) return;

    final jaSelecionada = _categoriasSelecionadas.any(
      (item) => item.idCategoriaIngrediente == id,
    );

    setState(() {
      if (jaSelecionada) {
        _categoriasSelecionadas = _categoriasSelecionadas
            .where((item) => item.idCategoriaIngrediente != id)
            .toList();

        if (_categoriasSelecionadas.isNotEmpty &&
            !_categoriasSelecionadas.any((item) => item.principal)) {
          _categoriasSelecionadas = [
            _categoriasSelecionadas.first.copyWith(principal: true),
            ..._categoriasSelecionadas.skip(1),
          ];
        }
      } else {
        _categoriasSelecionadas = [
          ..._categoriasSelecionadas,
          CategoriaIngredienteResumoModel(
            idCategoriaIngrediente: categoria.idCategoriaIngrediente,
            nome: categoria.nome,
            principal: _categoriasSelecionadas.isEmpty,
            ordem: categoria.ordem,
          ),
        ];
      }
    });
  }

  void _definirCategoriaPrincipal(
    CategoriaIngredienteResumoModel categoria,
  ) {
    setState(() {
      _categoriasSelecionadas = _categoriasSelecionadas.map((item) {
        return item.copyWith(
          principal: item.idCategoriaIngrediente == categoria.idCategoriaIngrediente,
        );
      }).toList();
    });
  }

  Future<void> _salvar() async {
    if (_salvando) return;

    final formState = _formKey.currentState;

    if (formState == null) {
      _snack(
        'Não foi possível validar o formulário. Verifique se a tela carregou corretamente.',
        erro: true,
      );
      return;
    }

    if (!formState.validate()) return;

    if (_categoriasSelecionadas.isEmpty) {
      _snack(
        'Selecione pelo menos uma categoria para o ingrediente.',
        erro: true,
      );
      return;
    }

    final precoAdicional = _parseDouble(_precoAdicionalCtrl.text);

    if (precoAdicional < 0) {
      _snack(
        'O preço adicional não pode ser negativo.',
        erro: true,
      );
      return;
    }

    final quantidadeEstoque = _controlaEstoque
        ? _parseDoubleNullable(_quantidadeEstoqueCtrl.text)
        : null;

    if (_controlaEstoque && quantidadeEstoque == null) {
      _snack(
        'Informe a quantidade em estoque.',
        erro: true,
      );
      return;
    }

    if (_controlaEstoque && quantidadeEstoque! < 0) {
      _snack(
        'A quantidade em estoque não pode ser negativa.',
        erro: true,
      );
      return;
    }

    if (!_validarMovimentoEstoque()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      final provider = context.read<IngredienteProvider>();

      _garantirImagemPrincipal();
      _reordenarImagens();

      final ingrediente = IngredienteModel(
        idIngrediente: _ingredienteEdicao?.idIngrediente,
        nome: _nomeCtrl.text.trim(),
        descricao: _nullIfBlank(_descricaoCtrl.text),
        precoAdicional: precoAdicional,
        controlaEstoque: _controlaEstoque,
        quantidadeEstoque: quantidadeEstoque,
        ativo: _ativo,
        categoriasIngrediente: _categoriasSelecionadas,
        imagens: _imagens,
        tipoMovimentoEstoque: _quantidadeEstoqueFoiAlterada
            ? _tipoMovimentoEstoqueSelecionado
            : null,
        motivoMovimentoEstoque:
            _quantidadeEstoqueFoiAlterada ? _motivoMovimentoEstoque : null,
        observacoesMovimentoEstoque: _quantidadeEstoqueFoiAlterada
            ? _nullIfBlank(_observacoesMovimentoEstoqueCtrl.text)
            : null,
        idUsuarioMovimentoEstoque:
            _quantidadeEstoqueFoiAlterada ? _idUsuarioLogado() : null,
      );

      final bool sucesso;

      if (_modoEdicao) {
        final id = _ingredienteEdicao?.idIngrediente;

        if (id == null) {
          _snack(
            'Ingrediente inválido para edição.',
            erro: true,
          );
          return;
        }

        sucesso = await provider.editarIngrediente(
          id,
          ingrediente,
          enviarCategorias: true,
          enviarImagens: true,
        );
      } else {
        sucesso = await provider.criarIngrediente(ingrediente);
      }

      if (!mounted) return;

      if (sucesso) {
        _snack(
          _modoEdicao
              ? 'Ingrediente actualizado com sucesso.'
              : 'Ingrediente cadastrado com sucesso.',
        );

        Navigator.of(context).pop(true);
        return;
      }

      _snack(
        provider.erro ?? 'Não foi possível salvar o ingrediente.',
        erro: true,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ IngredienteFormScreen — erro ao salvar ingrediente: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _snack(
        e.toString().replaceFirst('Exception: ', ''),
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  String? _validarNome(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Informe o nome do ingrediente.';
    }

    if (text.length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres.';
    }

    return null;
  }

  String? _validarPrecoAdicional(String? value) {
    final numero = _parseDoubleNullable(value ?? '');

    if (numero == null) {
      return 'Informe um preço adicional válido.';
    }

    if (numero < 0) {
      return 'O preço adicional não pode ser negativo.';
    }

    return null;
  }

  String? _validarQuantidadeEstoque(String? value) {
    if (!_controlaEstoque) return null;

    final numero = _parseDoubleNullable(value ?? '');

    if (numero == null) {
      return 'Informe a quantidade em estoque.';
    }

    if (numero < 0) {
      return 'A quantidade em estoque não pode ser negativa.';
    }

    return null;
  }

  double _parseDouble(
    String value,
  ) {
    return _parseDoubleNullable(value) ?? 0.0;
  }

  double? _parseDoubleNullable(
    String value,
  ) {
    final text = value.trim().replaceAll(',', '.');

    if (text.isEmpty) return null;

    return double.tryParse(text);
  }

  String? _nullIfBlank(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) return null;

    return text;
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
    final titulo = _modoEdicao ? 'Editar ingrediente' : 'Novo ingrediente';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: SafeArea(
        child: Consumer<IngredienteProvider>(
          builder: (context, ingredienteProvider, _) {
            final categoriasIngrediente = [...ingredienteProvider.categorias]
              ..sort((a, b) {
                final ordem = a.ordem.compareTo(b.ordem);

                if (ordem != 0) return ordem;

                return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
              });

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _HeaderFormCard(
                    titulo: titulo,
                    modoEdicao: _modoEdicao,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: _cardDecoration(),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomeCtrl,
                          validator: _validarNome,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nome do ingrediente',
                            prefixIcon: Icon(Icons.kitchen_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descricaoCtrl,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _precoAdicionalCtrl,
                          validator: _validarPrecoAdicional,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Preço adicional',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _controlaEstoque,
                          activeColor: _kBlue,
                          title: const Text(
                            'Controla estoque',
                            style: TextStyle(
                              color: _kDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: const Text(
                            'Use para ingredientes com quantidade controlada em estoque.',
                            style: TextStyle(
                              color: _kMuted,
                              fontSize: 13,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _controlaEstoque = value;

                              if (!value) {
                                _quantidadeEstoqueCtrl.clear();
                                _resetarMovimentoEstoque();
                              }
                            });
                          },
                        ),
                        if (_controlaEstoque) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _quantidadeEstoqueCtrl,
                            validator: _validarQuantidadeEstoque,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantidade em estoque',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                            onChanged: (_) {
                              setState(() {
                                if (!_tiposMovimentoPermitidos.contains(
                                  _tipoMovimentoEstoqueSelecionado,
                                )) {
                                  _tipoMovimentoEstoqueSelecionado = null;
                                  _motivoMovimentoOutroCtrl.clear();
                                }
                              });
                            },
                          ),
                        ],
                        if (_quantidadeEstoqueFoiAlterada) ...[
                          const SizedBox(height: 14),
                          _MovimentoEstoqueEdicaoCard(
                            aumentou: _estoqueAumentou,
                            quantidadeAnterior: _quantidadeEstoqueAnterior,
                            quantidadeActual: _quantidadeEstoqueActualForm,
                            tipoSelecionado: _tipoMovimentoEstoqueSelecionado,
                            tiposPermitidos: _tiposMovimentoPermitidos,
                            motivoOutroCtrl: _motivoMovimentoOutroCtrl,
                            observacoesCtrl: _observacoesMovimentoEstoqueCtrl,
                            onTipoChanged: (value) {
                              setState(() {
                                _tipoMovimentoEstoqueSelecionado = value;

                                if (value != TipoMovimentoEstoqueModel.outros) {
                                  _motivoMovimentoOutroCtrl.clear();
                                }
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 14),
                          SwitchListTile(
  contentPadding: EdgeInsets.zero,
  value: _ativo,
  activeColor: _kGreen,
  title: const Text(
    'Activo',
    style: TextStyle(
      color: _kDark,
      fontWeight: FontWeight.w700,
    ),
  ),
  subtitle: Text(
    _ativo
        ? 'O ingrediente está activo. A disponibilidade depende do estoque configurado.'
        : 'O ingrediente está inactivo e não poderá ser utilizado.',
    style: const TextStyle(
      color: _kMuted,
      fontSize: 13,
    ),
  ),
  onChanged: (value) {
    setState(() => _ativo = value);
  },
),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CategoriasIngredienteSection(
                    categorias: categoriasIngrediente,
                    selecionadas: _categoriasSelecionadas,
                    onToggle: _toggleCategoria,
                    onDefinirPrincipal: _definirCategoriaPrincipal,
                  ),
                  const SizedBox(height: 16),
                  _ImagensSection(
                    imagens: _imagens,
                    dragging: _dragging,
                    onChoose: _escolherImagens,
                    onDrop: _adicionarImagensPorDrop,
                    onDraggingChanged: (value) {
                      setState(() => _dragging = value);
                    },
                    onRemover: _removerImagem,
                    onDefinirPrincipal: _definirImagemPrincipal,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _salvando
                              ? null
                              : () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: _kDark,
                            side: const BorderSide(color: _kBorder),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _salvando ? null : _salvar,
                          icon: _salvando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _salvando
                                ? 'Salvando...'
                                : _modoEdicao
                                    ? 'Actualizar'
                                    : 'Salvar',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _kOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MovimentoEstoqueEdicaoCard extends StatelessWidget {
  final bool aumentou;
  final double quantidadeAnterior;
  final double quantidadeActual;
  final TipoMovimentoEstoqueModel? tipoSelecionado;
  final List<TipoMovimentoEstoqueModel> tiposPermitidos;
  final TextEditingController motivoOutroCtrl;
  final TextEditingController observacoesCtrl;
  final ValueChanged<TipoMovimentoEstoqueModel?> onTipoChanged;

  const _MovimentoEstoqueEdicaoCard({
    required this.aumentou,
    required this.quantidadeAnterior,
    required this.quantidadeActual,
    required this.tipoSelecionado,
    required this.tiposPermitidos,
    required this.motivoOutroCtrl,
    required this.observacoesCtrl,
    required this.onTipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: aumentou ? _kGreen.withOpacity(0.08) : _kRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: aumentou
              ? _kGreen.withOpacity(0.22)
              : _kRed.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aumentou
                ? 'Movimento de aumento de estoque'
                : 'Movimento de redução de estoque',
            style: TextStyle(
              color: aumentou ? _kGreen : _kRed,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Anterior: ${quantidadeAnterior.toStringAsFixed(3)} • Nova: ${quantidadeActual.toStringAsFixed(3)}',
            style: const TextStyle(
              color: _kMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<TipoMovimentoEstoqueModel>(
            value: tipoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Motivo do movimento',
              prefixIcon: Icon(Icons.swap_vert_rounded),
            ),
            items: tiposPermitidos.map((tipo) {
              return DropdownMenuItem<TipoMovimentoEstoqueModel>(
                value: tipo,
                child: Text(tipo.label),
              );
            }).toList(),
            onChanged: onTipoChanged,
          ),
          if (tipoSelecionado == TipoMovimentoEstoqueModel.outros) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: motivoOutroCtrl,
              decoration: const InputDecoration(
                labelText: 'Descreva o motivo',
                prefixIcon: Icon(Icons.edit_note_outlined),
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextFormField(
            controller: observacoesCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Observações do movimento',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderFormCard extends StatelessWidget {
  final String titulo;
  final bool modoEdicao;

  const _HeaderFormCard({
    required this.titulo,
    required this.modoEdicao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
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
              Icons.kitchen_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: _kDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  modoEdicao
                      ? 'Actualize dados, categorias, estoque e imagens.'
                      : 'Cadastre um ingrediente com categorias, estoque e imagens.',
                  style: const TextStyle(
                    color: _kMuted,
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

class _CategoriasIngredienteSection extends StatelessWidget {
  final List<CategoriaIngredienteModel> categorias;
  final List<CategoriaIngredienteResumoModel> selecionadas;
  final ValueChanged<CategoriaIngredienteModel> onToggle;
  final ValueChanged<CategoriaIngredienteResumoModel> onDefinirPrincipal;

  const _CategoriasIngredienteSection({
    required this.categorias,
    required this.selecionadas,
    required this.onToggle,
    required this.onDefinirPrincipal,
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
            'Categorias do ingrediente',
            style: TextStyle(
              color: _kDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Associe o ingrediente a uma ou mais categorias.',
            style: TextStyle(
              color: _kMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          if (categorias.isEmpty)
            const Text(
              'Nenhuma categoria activa disponível.',
              style: TextStyle(
                color: _kMuted,
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categorias.map((categoria) {
                final selecionada = selecionadas.any(
                  (item) =>
                      item.idCategoriaIngrediente ==
                      categoria.idCategoriaIngrediente,
                );

                return FilterChip(
                  selected: selecionada,
                  label: Text(categoria.nome),
                  avatar: Icon(
                    selecionada ? Icons.check_circle : Icons.category_outlined,
                    size: 16,
                  ),
                  selectedColor: _kOrange.withOpacity(0.14),
                  backgroundColor: const Color(0xFFF9FAFB),
                  side: BorderSide(
                    color: selecionada ? _kOrange : _kBorder,
                  ),
                  labelStyle: TextStyle(
                    color: selecionada ? _kOrange : _kText,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => onToggle(categoria),
                );
              }).toList(),
            ),
          if (selecionadas.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text(
              'Seleccionadas:',
              style: TextStyle(
                color: _kText,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selecionadas.map((categoria) {
                return ActionChip(
                  avatar: Icon(
                    categoria.principal ? Icons.star : Icons.star_border,
                    size: 17,
                    color: categoria.principal ? _kOrange : _kMuted,
                  ),
                  label: Text(
                    categoria.principal
                        ? '${categoria.nome} — principal'
                        : categoria.nome,
                  ),
                  backgroundColor: categoria.principal
                      ? _kOrange.withOpacity(0.12)
                      : const Color(0xFFF9FAFB),
                  side: BorderSide(
                    color: categoria.principal ? _kOrange : _kBorder,
                  ),
                  labelStyle: TextStyle(
                    color: categoria.principal ? _kOrange : _kText,
                    fontWeight: FontWeight.w700,
                  ),
                  onPressed: () => onDefinirPrincipal(categoria),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImagensSection extends StatelessWidget {
  final List<IngredienteImagemModel> imagens;
  final bool dragging;
  final VoidCallback onChoose;
  final ValueChanged<List<XFile>> onDrop;
  final ValueChanged<bool> onDraggingChanged;
  final ValueChanged<IngredienteImagemModel> onRemover;
  final ValueChanged<IngredienteImagemModel> onDefinirPrincipal;

  const _ImagensSection({
    required this.imagens,
    required this.dragging,
    required this.onChoose,
    required this.onDrop,
    required this.onDraggingChanged,
    required this.onRemover,
    required this.onDefinirPrincipal,
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
            'Imagens do ingrediente',
            style: TextStyle(
              color: _kDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha ficheiros ou arraste imagens para esta área.',
            style: TextStyle(
              color: _kMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          DropTarget(
            onDragEntered: (_) => onDraggingChanged(true),
            onDragExited: (_) => onDraggingChanged(false),
            onDragDone: (details) {
              onDraggingChanged(false);
              onDrop(details.files);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dragging
                    ? _kOrange.withOpacity(0.10)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: dragging ? _kOrange : _kBorder,
                  width: dragging ? 1.4 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    dragging
                        ? Icons.file_download_outlined
                        : Icons.cloud_upload_outlined,
                    color: dragging ? _kOrange : _kMuted,
                    size: 38,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dragging
                        ? 'Solte as imagens aqui'
                        : 'Arraste imagens para cá ou escolha dos ficheiros',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _kDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onChoose,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Escolher ficheiros'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kOrange,
                      side: const BorderSide(color: _kOrange),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (imagens.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: imagens.map((imagem) {
                return _ImagemPreviewCard(
                  imagem: imagem,
                  onRemover: () => onRemover(imagem),
                  onDefinirPrincipal: () => onDefinirPrincipal(imagem),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImagemPreviewCard extends StatelessWidget {
  final IngredienteImagemModel imagem;
  final VoidCallback onRemover;
  final VoidCallback onDefinirPrincipal;

  const _ImagemPreviewCard({
    required this.imagem,
    required this.onRemover,
    required this.onDefinirPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: imagem.principal ? _kOrange : _kBorder,
          width: imagem.principal ? 1.4 : 1,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _ImagemPreview(
              pathOrUrl: imagem.imagemUrl,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nomeArquivo(imagem.imagemUrl),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _kText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onDefinirPrincipal,
                  icon: Icon(
                    imagem.principal ? Icons.star : Icons.star_border,
                    size: 17,
                  ),
                  label: Text(
                    imagem.principal ? 'Principal' : 'Definir',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: imagem.principal ? _kOrange : _kMuted,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remover',
                onPressed: onRemover,
                icon: const Icon(
                  Icons.close,
                  color: _kRed,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _nomeArquivo(
    String path,
  ) {
    final text = path.trim();

    if (text.isEmpty) return 'Imagem';

    final normalized = text.replaceAll('\\', '/');

    return normalized.split('/').last;
  }
}

class _ImagemPreview extends StatelessWidget {
  final String pathOrUrl;

  const _ImagemPreview({
    required this.pathOrUrl,
  });

  @override
  Widget build(BuildContext context) {
    final source = pathOrUrl.trim();

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        width: 150,
        height: 105,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    try {
      final file = source.startsWith('file://')
          ? File.fromUri(Uri.parse(source))
          : File(source);

      if (file.existsSync()) {
        return Image.file(
          file,
          width: 150,
          height: 105,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
    } catch (_) {
      return _placeholder();
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 150,
      height: 105,
      color: _kOrange.withOpacity(0.10),
      child: const Icon(
        Icons.image_outlined,
        color: _kOrange,
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

