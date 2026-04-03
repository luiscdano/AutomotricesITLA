import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/private_repository.dart';
import '../../models/private_models.dart';
import '../image_picker_helper.dart';
import '../private_ui.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, this.initialVehicle});

  final VehicleItem? initialVehicle;

  bool get isEditing => initialVehicle != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  late final TextEditingController _placaController;
  late final TextEditingController _chasisController;
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _anioController;
  late final TextEditingController _ruedasController;

  bool _isSaving = false;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final v = widget.initialVehicle;

    _placaController = TextEditingController(text: v?.placa ?? '');
    _chasisController = TextEditingController(text: v?.chasis ?? '');
    _marcaController = TextEditingController(text: v?.marca ?? '');
    _modeloController = TextEditingController(text: v?.modelo ?? '');
    _anioController = TextEditingController(
      text: v != null && v.anio > 0 ? v.anio.toString() : '',
    );
    _ruedasController = TextEditingController(
      text: v != null && v.cantidadRuedas > 0
          ? v.cantidadRuedas.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _placaController.dispose();
    _chasisController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _ruedasController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await pickImagePath(context);
    if (path == null || path.isEmpty) return;

    if (mounted) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _save() async {
    final placa = _placaController.text.trim();
    final chasis = _chasisController.text.trim();
    final marca = _marcaController.text.trim();
    final modelo = _modeloController.text.trim();
    final anio = int.tryParse(_anioController.text.trim());
    final ruedas = int.tryParse(_ruedasController.text.trim());

    if (placa.isEmpty || chasis.isEmpty || marca.isEmpty || modelo.isEmpty) {
      _showSnack('Completa placa, chasis, marca y modelo.');
      return;
    }

    if (anio == null || anio < 1900) {
      _showSnack('Ingresa un anio valido.');
      return;
    }

    if (ruedas == null || ruedas < 2) {
      _showSnack('Cantidad de ruedas invalida.');
      return;
    }

    setState(() => _isSaving = true);

    final repository = context.read<PrivateRepository>();
    final input = VehicleInput(
      placa: placa,
      chasis: chasis,
      marca: marca,
      modelo: modelo,
      anio: anio,
      cantidadRuedas: ruedas,
    );

    if (widget.isEditing) {
      final update = await repository.updateVehicle(
        id: widget.initialVehicle!.id,
        input: input,
      );

      if (update.isFailure) {
        if (mounted) {
          setState(() => _isSaving = false);
          _showSnack(update.errorMessage ?? 'No se pudo editar el vehiculo.');
        }
        return;
      }

      if (_photoPath != null && _photoPath!.isNotEmpty) {
        final photo = await repository.uploadVehiclePhoto(
          id: widget.initialVehicle!.id,
          filePath: _photoPath!,
        );
        if (photo.isFailure && mounted) {
          _showSnack(
            photo.errorMessage ?? 'Se edito el vehiculo, pero fallo la foto.',
          );
        }
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(true);
      }
      return;
    }

    final create = await repository.createVehicle(
      input: input,
      photoPath: _photoPath,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (create.isFailure) {
        _showSnack(create.errorMessage ?? 'No se pudo registrar el vehiculo.');
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar vehiculo' : 'Registrar vehiculo',
        ),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: PrivateUi.cardDecoration(),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _FormField(controller: _placaController, label: 'Placa'),
                const SizedBox(height: 10),
                _FormField(controller: _chasisController, label: 'Chasis'),
                const SizedBox(height: 10),
                _FormField(controller: _marcaController, label: 'Marca'),
                const SizedBox(height: 10),
                _FormField(controller: _modeloController, label: 'Modelo'),
                const SizedBox(height: 10),
                _FormField(
                  controller: _anioController,
                  label: 'Anio',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _FormField(
                  controller: _ruedasController,
                  label: 'Cantidad de ruedas',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _isSaving ? null : _pickPhoto,
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(
                          _photoPath == null ? 'Elegir foto' : 'Foto lista',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: PrivateUi.brown,
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      widget.isEditing ? 'Guardar cambios' : 'Registrar',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
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
      style: const TextStyle(color: PrivateUi.text),
      decoration: InputDecoration(
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
      ),
    );
  }
}
