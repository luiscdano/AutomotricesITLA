import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/public_repository.dart';
import '../../models/public_models.dart';
import '../public_ui.dart';

class CatalogDetailScreen extends StatefulWidget {
  const CatalogDetailScreen({super.key, required this.item});

  final CatalogItem item;

  @override
  State<CatalogDetailScreen> createState() => _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  late Future<CatalogDetail> _future;
  final _money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<CatalogDetail> _load() async {
    final result = await context.read<PublicRepository>().fetchCatalogDetail(
      id: widget.item.id,
    
    );

    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudo cargar el detalle.');
    }

    return result.data!;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PublicUi.bg,
      appBar: AppBar(
        title: const Text('Detalle de vehiculo'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: FutureBuilder<CatalogDetail>(
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

          final detail = snapshot.data!;
          final images = detail.images.isNotEmpty
              ? detail.images
              : (widget.item.imageUrl ?? '').isNotEmpty
              ? [widget.item.imageUrl!]
              : <String>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: PublicUi.cardDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${detail.brand} ${detail.model}',
                        style: const TextStyle(
                          color: PublicUi.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Anio ${detail.year}',
                        style: const TextStyle(color: PublicUi.muted),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PublicUi.brown,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _money.format(detail.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.white.withValues(alpha: 0.04),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: PublicUi.muted,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                decoration: PublicUi.cardDecoration(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        color: PublicUi.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail.description.isEmpty
                          ? 'Sin descripción para este vehiculo.'
                          : detail.description,
                      style: const TextStyle(
                        color: PublicUi.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: PublicUi.cardDecoration(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Especificaciones',
                      style: TextStyle(
                        color: PublicUi.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (detail.specifications.isEmpty)
                      const Text(
                        'Sin especificaciones publicadas.',
                        style: TextStyle(color: PublicUi.muted),
                      )
                    else
                      ...detail.specifications.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${entry.key}:',
                                  style: const TextStyle(
                                    color: PublicUi.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  entry.value?.toString() ?? '-',
                                  style: const TextStyle(color: PublicUi.muted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _errorText(Object? error) {
    return (error?.toString() ?? 'Error desconocido').replaceFirst(
      'Exception: ',
      '',
    );
  }
}
