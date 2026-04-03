import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/public_repository.dart';
import '../../models/public_models.dart';
import '../public_ui.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<NewsItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<NewsItem>> _load() async {
    final result = await context.read<PublicRepository>().fetchNews();
    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudieron cargar noticias.');
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
        title: const Text('Noticias automotrices'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: FutureBuilder<List<NewsItem>>(
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

          final items = snapshot.data ?? <NewsItem>[];
          if (items.isEmpty) {
            return const PublicEmptyView(
              message: 'No hay noticias disponibles ahora mismo.',
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
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => NewsDetailScreen(item: item),
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
                              height: 170,
                              width: double.infinity,
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
                                item.title,
                                style: const TextStyle(
                                  color: PublicUi.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if ((item.summary).isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  item.summary,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: PublicUi.muted),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      _metaDate(item.date),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: PublicUi.cream,
                                  ),
                                ],
                              ),
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
    );
  }

  String _metaDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Fecha no disponible';
    return raw;
  }

  String _errorText(Object? error) {
    final raw = error?.toString() ?? 'Error desconocido';
    return raw.replaceFirst('Exception: ', '');
  }
}
