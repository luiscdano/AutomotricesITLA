import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/public_repository.dart';
import '../../models/public_models.dart';
import '../public_ui.dart';
import '../url_launcher_helper.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late Future<List<VideoItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<VideoItem>> _load() async {
    final result = await context.read<PublicRepository>().fetchVideos();
    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudieron cargar videos.');
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
        title: const Text('Videos educativos'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: FutureBuilder<List<VideoItem>>(
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

          final items = snapshot.data ?? <VideoItem>[];
          if (items.isEmpty) {
            return const PublicEmptyView(
              message: 'No hay videos publicados por el momento.',
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
                return Container(
                  decoration: PublicUi.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((item.thumbnail ?? '').isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: Image.network(
                            item.thumbnail!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if ((item.description).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                item.description,
                                style: const TextStyle(color: PublicUi.muted),
                              ),
                            ],
                            if ((item.category ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Categoria: ${item.category}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: item.url.isEmpty
                                  ? null
                                  : () => openExternalUrl(context, item.url),
                              style: FilledButton.styleFrom(
                                backgroundColor: PublicUi.brown,
                              ),
                              icon: const Icon(Icons.play_circle_fill_rounded),
                              label: const Text('Abrir video'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
