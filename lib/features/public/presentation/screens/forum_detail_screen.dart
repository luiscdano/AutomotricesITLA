import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/public_repository.dart';
import '../../models/public_models.dart';
import '../public_ui.dart';

class ForumDetailScreen extends StatefulWidget {
  const ForumDetailScreen({super.key, required this.topic});

  final ForumTopic topic;

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  late Future<ForumDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ForumDetail> _load() async {
    final result = await context
        .read<PublicRepository>()
        .fetchPublicForumDetail(id: widget.topic.id);

    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudo cargar el tema.');
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
        title: const Text('Tema del foro'),
        backgroundColor: PublicUi.bg,
        foregroundColor: PublicUi.text,
      ),
      body: FutureBuilder<ForumDetail>(
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: PublicUi.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((detail.topic.vehicleImage ?? '').isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.network(
                          detail.topic.vehicleImage!,
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
                            detail.topic.title,
                            style: const TextStyle(
                              color: PublicUi.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            detail.topic.description,
                            style: const TextStyle(
                              color: PublicUi.muted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(
                                icon: Icons.person_rounded,
                                text: detail.topic.author,
                              ),
                              _MetaChip(
                                icon: Icons.directions_car,
                                text: detail.topic.vehicle,
                              ),
                              _MetaChip(
                                icon: Icons.forum_rounded,
                                text: '${detail.replies.length} respuestas',
                              ),
                            ],
                          ),
                        ],
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
                      'Respuestas',
                      style: TextStyle(
                        color: PublicUi.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (detail.replies.isEmpty)
                      const Text(
                        'Aun no hay respuestas para este tema.',
                        style: TextStyle(color: PublicUi.muted),
                      )
                    else
                      ...detail.replies.map(
                        (reply) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: PublicUi.cream,
                                backgroundImage:
                                    (reply.authorPhoto ?? '').isNotEmpty
                                    ? NetworkImage(reply.authorPhoto!)
                                    : null,
                                child: (reply.authorPhoto ?? '').isEmpty
                                    ? Text(
                                        reply.author.characters.first,
                                        style: const TextStyle(
                                          color: PublicUi.darkText,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reply.author,
                                      style: const TextStyle(
                                        color: PublicUi.text,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if ((reply.date ?? '').isNotEmpty)
                                      Text(
                                        reply.date!,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Text(
                                      reply.content,
                                      style: const TextStyle(
                                        color: PublicUi.muted,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

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
            text,
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
