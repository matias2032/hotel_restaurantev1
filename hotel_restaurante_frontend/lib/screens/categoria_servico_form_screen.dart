import 'package:api_compartilhado/api_compartilhado.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _kDark = Color(0xFF111827);
const _kOrange = Color(0xFFF97316);
const _kGreen = Color(0xFF16A34A);
const _kRed = Color(0xFFDC2626);
const _kMuted = Color(0xFF6B7280);
const _kBg = Color(0xFFF7F8FA);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE5E7EB);

class CategoriaServicoFormScreen extends StatefulWidget {
  const CategoriaServicoFormScreen({super.key});

  @override
  State<CategoriaServicoFormScreen> createState() =>
      _CategoriaServicoFormScreenState();
}

class _CategoriaServicoFormScreenState
    extends State<CategoriaServicoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _ordemCtrl = TextEditingController(text: '0');

  CategoriaServicoModel? _categoriaEdicao;

  bool _carregouArgumentos = false;
  bool _salvando = false;
  bool _ativo = true;

  bool get _modoEdicao => _categoriaEdicao != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarArgumentos();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _ordemCtrl.dispose();
    super.dispose();
  }

  void _carregarArgumentos() {
    if (_carregouArgumentos) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is CategoriaServicoModel) {
      _categoriaEdicao = args;

      _nomeCtrl.text = args.nome;
      _descricaoCtrl.text = args.descricao ?? '';
      _ordemCtrl.text = args.ordem.toString();
      _ativo = args.ativo;
    }

    _carregouArgumentos = true;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final provider = context.read<ServicoProvider>();

      final categoria = CategoriaServicoModel(
        idCategoriaServico: _categoriaEdicao?.idCategoriaServico,
        nome: _nomeCtrl.text.trim(),
        descricao: _nullIfBlank(_descricaoCtrl.text),
        ordem: int.tryParse(_ordemCtrl.text.trim()) ?? 0,
        ativo: _ativo,
      );

      bool sucesso;

      if (_modoEdicao) {
        final id = _categoriaEdicao?.idCategoriaServico;

        if (id == null) {
          _snack(
            'Categoria inválida para edição.',
            erro: true,
          );
          return;
        }

        sucesso = await provider.editarCategoria(
          id,
          categoria,
        );
      } else {
        sucesso = await provider.criarCategoria(
          categoria,
        );
      }

      if (!mounted) return;

      if (sucesso) {
        _snack(
          _modoEdicao
              ? 'Categoria actualizada com sucesso.'
              : 'Categoria cadastrada com sucesso.',
        );

        Navigator.of(context).pop(true);
      } else {
        _snack(
          provider.erro ?? 'Não foi possível salvar a categoria.',
          erro: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  String? _validarNome(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Informe o nome da categoria.';
    }

    if (text.length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres.';
    }

    return null;
  }

  String? _validarOrdem(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Informe a ordem.';
    }

    final ordem = int.tryParse(text);

    if (ordem == null) {
      return 'Informe um número válido.';
    }

    if (ordem < 0) {
      return 'A ordem não pode ser negativa.';
    }

    return null;
  }

  String? _nullIfBlank(String value) {
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
    final titulo = _modoEdicao
        ? 'Editar categoria de serviço'
        : 'Nova categoria de serviço';

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              decoration: _cardDecoration(),
              padding: const EdgeInsets.all(18),
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
                  const SizedBox(height: 6),
                  Text(
                    _modoEdicao
                        ? 'Actualize os dados da categoria seleccionada.'
                        : 'Cadastre uma categoria para agrupar serviços semelhantes.',
                    style: const TextStyle(
                      color: _kMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: _cardDecoration(),
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      validator: _validarNome,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome da categoria',
                        prefixIcon: Icon(Icons.design_services_rounded),
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
                      controller: _ordemCtrl,
                      validator: _validarOrdem,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Ordem',
                        prefixIcon: Icon(Icons.sort),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _ativo,
                      activeColor: _kGreen,
                      title: const Text(
                        'Categoria activa',
                        style: TextStyle(
                          color: _kDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        _ativo
                            ? 'A categoria ficará disponível para associação.'
                            : 'A categoria ficará inactiva.',
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