import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../data/public_repository.dart';
import '../../models/public_models.dart';
import '../public_ui.dart';
import '../url_launcher_helper.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({super.key, required this.item});

  final NewsItem item;

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late Future<NewsDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<NewsDetail> _load() async {
    final result = await context.read<PublicRepository>().fetchNewsDetail(
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
        title: const Text('Detalle de noticia'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: FutureBuilder<NewsDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: PublicUi.cream),
            );
          }

          if (snapshot.hasError) {
            return _NewsDetailErrorView(
              errorText: _errorText(snapshot.error),
              fallback: widget.item,
              onRetry: _reload,
            );
          }

          final detail = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: PublicUi.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((detail.item.imageUrl ?? '').isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.network(
                          detail.item.imageUrl!,
                          width: double.infinity,
                          height: 200,
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
                            detail.item.title,
                            style: const TextStyle(
                              color: PublicUi.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _InfoChip(
                                icon: Icons.calendar_today_rounded,
                                label: detail.item.date ?? 'Sin fecha',
                              ),
                              _InfoChip(
                                icon: Icons.public_rounded,
                                label:
                                    detail.item.source ?? 'Fuente no indicada',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Html(
                            data: detail.htmlContent.isNotEmpty
                                ? detail.htmlContent
                                : '<p>${detail.item.summary}</p>',
                            style: {
                              'body': Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                color: PublicUi.text,
                                fontSize: FontSize(16),
                                lineHeight: const LineHeight(1.45),
                              ),
                              'a': Style(color: PublicUi.cream),
                            },
                            onLinkTap: (url, _, _) {
                              if (url != null && url.isNotEmpty) {
                                openExternalUrl(context, url);
                              }
                            },
                          ),
                          if ((detail.item.link ?? '').isNotEmpty) ...[
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: PublicUi.brown,
                              ),
                              onPressed: () =>
                                  openExternalUrl(context, detail.item.link!),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Abrir fuente original'),
                            ),
                          ],
                        ],
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

class _NewsDetailErrorView extends StatelessWidget {
  const _NewsDetailErrorView({
    required this.errorText,
    required this.fallback,
    required this.onRetry,
  });

  final String errorText;
  final NewsItem fallback;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: PublicUi.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No se pudo cargar el detalle completo',
                style: TextStyle(
                  color: PublicUi.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(errorText, style: const TextStyle(color: PublicUi.muted)),
              const SizedBox(height: 14),
              Text(
                fallback.title,
                style: const TextStyle(
                  color: PublicUi.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (fallback.summary.isNotEmpty)
                Text(
                  fallback.summary,
                  style: const TextStyle(color: PublicUi.muted),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: PublicUi.brown,
                    ),
                    child: const Text('Reintentar'),
                  ),
                  if ((fallback.link ?? '').isNotEmpty)
                    FilledButton.tonalIcon(
                      onPressed: () => openExternalUrl(context, fallback.link!),
                      style: FilledButton.styleFrom(
                        backgroundColor: PublicUi.cream,
                        foregroundColor: PublicUi.darkText,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Abrir noticia'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PublicUi.cream),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
