import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/private_repository.dart';
import '../../models/private_models.dart';
import '../private_ui.dart';
import 'authenticated_forum_detail_screen.dart';

class AuthenticatedForumScreen extends StatefulWidget {
  const AuthenticatedForumScreen({super.key});

  @override
  State<AuthenticatedForumScreen> createState() =>
      _AuthenticatedForumScreenState();
}

class _AuthenticatedForumScreenState extends State<AuthenticatedForumScreen> {
  late Future<List<PrivateForumTopic>> _topicsFuture;
  late Future<List<PrivateForumTopic>> _myTopicsFuture;
  late Future<List<VehicleItem>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _loadTopics();
    _myTopicsFuture = _loadMyTopics();
    _vehiclesFuture = _loadVehicles();
  }

  Future<List<PrivateForumTopic>> _loadTopics() async {
    final result = await context.read<PrivateRepository>().fetchForumTopics();
    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? 'No se pudo cargar el foro autenticado.',
      );
    }
    return result.data!;
  }

  Future<List<PrivateForumTopic>> _loadMyTopics() async {
    final result = await context.read<PrivateRepository>().fetchMyForumTopics();
    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudo cargar tus temas.');
    }
    return result.data!;
  }

  Future<List<VehicleItem>> _loadVehicles() async {
    final result = await context.read<PrivateRepository>().fetchVehicles(
      limit: 120,
    );
    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? 'No se pudieron cargar tus vehiculos.',
      );
    }
    return result.data!.items;
  }

  void _reloadTopics() {
    setState(() {
      _topicsFuture = _loadTopics();
    });
  }

  void _reloadMyTopics() {
    setState(() {
      _myTopicsFuture = _loadMyTopics();
    });
  }

  void _reloadAll() {
    setState(() {
      _topicsFuture = _loadTopics();
      _myTopicsFuture = _loadMyTopics();
    });
  }

  Future<void> _openCreateTopic() async {
    List<VehicleItem> vehicles;
    try {
      vehicles = await _vehiclesFuture;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cargar la lista de vehiculos. Abre Fase 3 y registra al menos un vehiculo.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    if (vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Necesitas al menos un vehiculo para crear un tema en el foro.',
          ),
        ),
      );
      return;
    }

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _CreateForumTopicSheet(vehicles: vehicles),
    );

    if (created == true) {
      _reloadAll();
    }
  }

  Future<void> _openTopic(PrivateForumTopic topic) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthenticatedForumDetailScreen(
          topicId: topic.id,
          topicTitle: topic.titulo,
        ),
      ),
    );

    if (!mounted) return;
    _reloadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: const Text('Fase 4 - Foro autenticado'),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTopic,
        backgroundColor: PrivateUi.brown,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Nuevo tema'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const TabBar(
                labelColor: PrivateUi.text,
                unselectedLabelColor: PrivateUi.muted,
                indicatorColor: PrivateUi.brown,
                tabs: [
                  Tab(text: 'Temas abiertos'),
                  Tab(text: 'Mis temas'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ForumTopicList(
                    future: _topicsFuture,
                    emptyMessage: 'No hay temas publicados en este momento.',
                    onRetry: _reloadTopics,
                    onOpen: _openTopic,
                  ),
                  _ForumTopicList(
                    future: _myTopicsFuture,
                    emptyMessage: 'Aun no has creado temas.',
                    onRetry: _reloadMyTopics,
                    onOpen: _openTopic,
                    showLastReply: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumTopicList extends StatelessWidget {
  const _ForumTopicList({
    required this.future,
    required this.emptyMessage,
    required this.onRetry,
    required this.onOpen,
    this.showLastReply = false,
  });

  final Future<List<PrivateForumTopic>> future;
  final String emptyMessage;
  final VoidCallback onRetry;
  final ValueChanged<PrivateForumTopic> onOpen;
  final bool showLastReply;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PrivateForumTopic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: PrivateUi.cream),
          );
        }

        if (snapshot.hasError) {
          return PrivateErrorView(
            message: _errorText(snapshot.error),
            onRetry: onRetry,
          );
        }

        final items = snapshot.data ?? <PrivateForumTopic>[];
        if (items.isEmpty) {
          return PrivateEmptyView(message: emptyMessage);
        }

        return RefreshIndicator(
          color: PrivateUi.brown,
          onRefresh: () async => onRetry(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final topic = items[index];

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onOpen(topic),
                child: Ink(
                  decoration: PrivateUi.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (topic.vehiculoFoto.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: Image.network(
                            topic.vehiculoFoto,
                            width: double.infinity,
                            height: 150,
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
                              topic.titulo.isEmpty ? 'Tema' : topic.titulo,
                              style: const TextStyle(
                                color: PrivateUi.text,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              topic.descripcion,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: PrivateUi.muted),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Chip(icon: Icons.person, text: topic.autor),
                                _Chip(
                                  icon: Icons.directions_car,
                                  text: topic.vehiculo,
                                ),
                                _Chip(
                                  icon: Icons.forum,
                                  text: '${topic.totalRespuestas} respuestas',
                                ),
                              ],
                            ),
                            if (showLastReply &&
                                topic.ultimaRespuesta.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Ultima respuesta: ${topic.ultimaRespuesta}',
                                style: const TextStyle(
                                  color: PrivateUi.cream,
                                  fontSize: 12,
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
    );
  }
}

class _CreateForumTopicSheet extends StatefulWidget {
  const _CreateForumTopicSheet({required this.vehicles});

  final List<VehicleItem> vehicles;

  @override
  State<_CreateForumTopicSheet> createState() => _CreateForumTopicSheetState();
}

class _CreateForumTopicSheetState extends State<_CreateForumTopicSheet> {
  late int _vehicleId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _vehicleId = widget.vehicles.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnack('Completa titulo y descripcion.');
      return;
    }

    setState(() => _saving = true);

    final result = await context.read<PrivateRepository>().createForumTopic(
      vehiculoId: _vehicleId,
      titulo: title,
      descripcion: description,
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.isFailure) {
      _showSnack(result.errorMessage ?? 'No se pudo crear el tema.');
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, insets.bottom + 16),
        child: Container(
          decoration: PrivateUi.cardDecoration(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Crear tema',
                      style: TextStyle(
                        color: PrivateUi.text,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: PrivateUi.text,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                key: ValueKey<int>(_vehicleId),
                initialValue: _vehicleId,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: PrivateUi.text),
                decoration: _input('Vehiculo'),
                items: widget.vehicles
                    .map(
                      (item) => DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(
                          '${item.marca} ${item.modelo} - ${item.placa}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _vehicleId = value);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: PrivateUi.text),
                decoration: _input('Titulo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                style: const TextStyle(color: PrivateUi.text),
                decoration: _input('Descripcion'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: PrivateUi.brown,
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Publicar tema'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: PrivateUi.muted),
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
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});

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

String _errorText(Object? error) {
  return (error?.toString() ?? 'Error desconocido').replaceFirst(
    'Exception: ',
    '',
  );
}
