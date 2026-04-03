import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/public_repository.dart';
import '../../models/public_models.dart';
import '../public_ui.dart';
import 'catalog_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<CatalogItem>> _future;

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');

  @override
  void initState() {
    super.initState();
    _future = _load();

    _brandController.addListener(_onFilterChanged);
    _modelController.addListener(_onFilterChanged);
    _yearController.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    _brandController
      ..removeListener(_onFilterChanged)
      ..dispose();
    _modelController
      ..removeListener(_onFilterChanged)
      ..dispose();
    _yearController
      ..removeListener(_onFilterChanged)
      ..dispose();
    super.dispose();
  }

  Future<List<CatalogItem>> _load() async {
    final result = await context.read<PublicRepository>().fetchCatalog(
      limit: 60,
    );
    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudo cargar el catalogo.');
    }
    return result.data!.items;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _onFilterChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PublicUi.bg,
      appBar: AppBar(
        title: const Text('Catalogo de vehiculos'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: PublicUi.cardDecoration(),
              child: Column(
                children: [
                  _FilterField(
                    controller: _brandController,
                    label: 'Filtrar por marca',
                  ),
                  const SizedBox(height: 8),
                  _FilterField(
                    controller: _modelController,
                    label: 'Filtrar por modelo',
                  ),
                  const SizedBox(height: 8),
                  _FilterField(
                    controller: _yearController,
                    label: 'Filtrar por anio',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CatalogItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: PublicUi.cream),
                  );
                }

                if (snapshot.hasError) {
                  return PublicErrorView(
                    message: _errorText(snapshot.error),
                    onRetry: _reload,
                  );
                }

                final original = snapshot.data ?? <CatalogItem>[];
                final filtered = _applyFilter(original);

                if (original.isEmpty) {
                  return const PublicEmptyView(
                    message: 'No hay vehiculos disponibles en este momento.',
                  );
                }

                if (filtered.isEmpty) {
                  return const PublicEmptyView(
                    message: 'No hay resultados con esos filtros.',
                  );
                }

                return RefreshIndicator(
                  color: PublicUi.brown,
                  backgroundColor: PublicUi.surface,
                  onRefresh: () async {
                    _reload();
                    await _future;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CatalogDetailScreen(item: item),
                            ),
                          );
                        },
                        child: Ink(
                          decoration: PublicUi.cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((item.imageUrl ?? '').isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                  child: Image.network(
                                    item.imageUrl!,
                                    width: double.infinity,
                                    height: 170,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.brand} ${item.model}',
                                      style: const TextStyle(
                                        color: PublicUi.text,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Anio ${item.year}  |  ${_money.format(item.price)}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.78,
                                        ),
                                      ),
                                    ),
                                    if (item.shortDescription.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        item.shortDescription,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: PublicUi.muted,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<CatalogItem> _applyFilter(List<CatalogItem> input) {
    final brand = _brandController.text.trim().toLowerCase();
    final model = _modelController.text.trim().toLowerCase();
    final yearText = _yearController.text.trim();
    final year = int.tryParse(yearText);

    return input.where((item) {
      final byBrand = brand.isEmpty || item.brand.toLowerCase().contains(brand);
      final byModel = model.isEmpty || item.model.toLowerCase().contains(model);
      final byYear = year == null || item.year == year;
      return byBrand && byModel && byYear;
    }).toList();
  }

  String _errorText(Object? error) {
    return (error?.toString() ?? 'Error desconocido').replaceFirst(
      'Exception: ',
      '',
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: PublicUi.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: PublicUi.muted),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5A5A5A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5A5A5A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PublicUi.brown),
        ),
      ),
    );
  }
}
