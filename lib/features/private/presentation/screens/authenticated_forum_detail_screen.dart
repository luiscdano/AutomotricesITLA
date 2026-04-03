import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/private_repository.dart';
import '../../models/private_models.dart';
import '../private_ui.dart';

class AuthenticatedForumDetailScreen extends StatefulWidget {
  const AuthenticatedForumDetailScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  final int topicId;
  final String topicTitle;

  @override
  State<AuthenticatedForumDetailScreen> createState() =>
      _AuthenticatedForumDetailScreenState();
}

class _AuthenticatedForumDetailScreenState
    extends State<AuthenticatedForumDetailScreen> {
  late Future<PrivateForumDetail> _future;
  final _replyController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<PrivateForumDetail> _load() async {
    final result = await context
        .read<PrivateRepository>()
        .fetchForumTopicDetail(id: widget.topicId);

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

  Future<void> _sendReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una respuesta antes de enviar.')),
      );
      return;
    }

    setState(() => _sending = true);

    final result = await context.read<PrivateRepository>().replyToForumTopic(
      temaId: widget.topicId,
      contenido: content,
    );

    if (!mounted) return;

    setState(() => _sending = false);

    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'No se pudo publicar la respuesta.',
          ),
        ),
      );
      return;
    }

    _replyController.clear();
    _reload();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Respuesta publicada.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: Text(
          widget.topicTitle.isEmpty ? 'Tema del foro' : widget.topicTitle,
        ),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<PrivateForumDetail>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: PrivateUi.cream),
                  );
                }

                if (snapshot.hasError) {
                  return PrivateErrorView(
                    message: _errorText(snapshot.error),
                    onRetry: _reload,
                  );
                }

                final detail = snapshot.data!;
                return RefreshIndicator(
                  color: PrivateUi.brown,
                  onRefresh: () async {
                    _reload();
                    await _future;
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Container(
                        decoration: PrivateUi.cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (detail.topic.vehiculoFoto.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: Image.network(
                                  detail.topic.vehiculoFoto,
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
                                    detail.topic.titulo,
                                    style: const TextStyle(
                                      color: PrivateUi.text,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    detail.topic.descripcion,
                                    style: const TextStyle(
                                      color: PrivateUi.muted,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _TopicChip(
                                        icon: Icons.person,
                                        text: detail.topic.autor,
                                      ),
                                      _TopicChip(
                                        icon: Icons.directions_car,
                                        text: detail.topic.vehiculo,
                                      ),
                                      _TopicChip(
                                        icon: Icons.forum,
                                        text:
                                            '${detail.replies.length} respuestas',
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
                        decoration: PrivateUi.cardDecoration(),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Respuestas',
                              style: TextStyle(
                                color: PrivateUi.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (detail.replies.isEmpty)
                              const Text(
                                'Aun no hay respuestas para este tema.',
                                style: TextStyle(color: PrivateUi.muted),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: PrivateUi.cream,
                                        backgroundImage:
                                            reply.autorFotoUrl.isNotEmpty
                                            ? NetworkImage(reply.autorFotoUrl)
                                            : null,
                                        child: reply.autorFotoUrl.isEmpty
                                            ? Text(
                                                _initial(reply.autor),
                                                style: const TextStyle(
                                                  color: PrivateUi.darkText,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reply.autor.isEmpty
                                                  ? 'Usuario'
                                                  : reply.autor,
                                              style: const TextStyle(
                                                color: PrivateUi.text,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (reply.fecha.isNotEmpty)
                                              Text(
                                                reply.fecha,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            Text(
                                              reply.contenido,
                                              style: const TextStyle(
                                                color: PrivateUi.muted,
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
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(color: PrivateUi.text),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu respuesta...',
                      hintStyle: const TextStyle(color: PrivateUi.muted),
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
                        borderSide: const BorderSide(color: PrivateUi.brown),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sending ? null : _sendReply,
                  style: FilledButton.styleFrom(
                    backgroundColor: PrivateUi.brown,
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed.characters.first;
  }

  String _errorText(Object? error) {
    return (error?.toString() ?? 'Error desconocido').replaceFirst(
      'Exception: ',
      '',
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.icon, required this.text});

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
          Icon(icon, size: 14, color: PrivateUi.cream),
          const SizedBox(width: 5),
          Text(
            text.isEmpty ? '-' : text,
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
