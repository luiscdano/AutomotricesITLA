import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/private_repository.dart';
import '../../models/private_models.dart';
import '../image_picker_helper.dart';
import '../private_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _future;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<UserProfile> _load() async {
    final result = await context.read<PrivateRepository>().fetchProfile();
    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudo cargar el perfil.');
    }
    return result.data!;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _changePhoto() async {
    final repository = context.read<PrivateRepository>();
    final path = await pickImagePath(context);
    if (path == null || path.isEmpty) return;

    setState(() => _isUploading = true);

    final result = await repository.uploadProfilePhoto(
      filePath: path,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      final message = result.isSuccess
          ? 'Foto de perfil actualizada.'
          : (result.errorMessage ?? 'No se pudo actualizar la foto.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
      ),
      body: FutureBuilder<UserProfile>(
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

          final profile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: PrivateUi.cardDecoration(),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: PrivateUi.cream,
                      backgroundImage: profile.fotoUrl.isNotEmpty
                          ? NetworkImage(profile.fotoUrl)
                          : null,
                      child: profile.fotoUrl.isEmpty
                          ? Text(
                              profile.displayName.isEmpty
                                  ? 'U'
                                  : profile.displayName.characters.first,
                              style: const TextStyle(
                                color: PrivateUi.darkText,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        color: PrivateUi.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.correo,
                      style: const TextStyle(color: PrivateUi.muted),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isUploading ? null : _changePhoto,
                      style: FilledButton.styleFrom(
                        backgroundColor: PrivateUi.brown,
                      ),
                      icon: _isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_camera),
                      label: const Text('Cambiar foto (camara/galeria)'),
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
                    _InfoRow(label: 'Matricula', value: profile.matricula),
                    _InfoRow(label: 'Nombre', value: profile.nombre),
                    _InfoRow(label: 'Apellido', value: profile.apellido),
                    _InfoRow(label: 'Correo', value: profile.correo),
                    _InfoRow(label: 'Rol', value: profile.rol),
                    _InfoRow(label: 'Grupo', value: profile.grupo),
                    _InfoRow(
                      label: 'Fecha registro',
                      value: profile.fechaRegistro,
                      isLast: true,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: PrivateUi.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: PrivateUi.muted),
            ),
          ),
        ],
      ),
    );
  }
}
