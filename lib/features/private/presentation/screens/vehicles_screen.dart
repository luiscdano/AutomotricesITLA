import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/private_repository.dart';
import '../../models/private_models.dart';
import '../image_picker_helper.dart';
import '../private_ui.dart';
import 'vehicle_detail_screen.dart';
import 'vehicle_form_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  late Future<List<VehicleItem>> _future;

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _load();

    _brandController.addListener(_onFilterChanged);
    _modelController.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    _brandController
      ..removeListener(_onFilterChanged)
      ..dispose();
    _modelController
      ..removeListener(_onFilterChanged)
      ..dispose();
    super.dispose();
  }

  Future<List<VehicleItem>> _load() async {
    final result = await context.read<PrivateRepository>().fetchVehicles(
      limit: 60,
    );
    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'No se pudo cargar el listado.');
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

  Future<void> _openCreate() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const VehicleFormScreen()),
    );

    if (changed == true) {
      _reload();
    }
  }

  Future<void> _openEdit(VehicleItem item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VehicleFormScreen(initialVehicle: item),
      ),
    );

    if (changed == true) {
      _reload();
    }
  }

  Future<void> _changePhoto(VehicleItem item) async {
    final repository = context.read<PrivateRepository>();
    final path = await pickImagePath(context);
    if (path == null || path.isEmpty) return;

    final result = await repository.uploadVehiclePhoto(
      id: item.id,
      filePath: path,
    );

    if (!mounted) return;

    final message = result.isSuccess
        ? 'Foto actualizada.'
        : (result.errorMessage ?? 'No se pudo actualizar la foto.');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (result.isSuccess) {
      _reload();
    }
  }

  List<VehicleItem> _applyFilter(List<VehicleItem> input) {
    final brand = _brandController.text.trim().toLowerCase();
    final model = _modelController.text.trim().toLowerCase();

    return input.where((item) {
      final byBrand = brand.isEmpty || item.marca.toLowerCase().contains(brand);
      final byModel =
          model.isEmpty || item.modelo.toLowerCase().contains(model);
      return byBrand && byModel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: const Text('Mis vehiculos'),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: PrivateUi.brown,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: PrivateUi.cardDecoration(),
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
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VehicleItem>>(
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

                final original = snapshot.data ?? <VehicleItem>[];
                if (original.isEmpty) {
                  return const PrivateEmptyView(
                    message: 'Aun no tienes vehiculos registrados.',
                  );
                }

                final vehicles = _applyFilter(original);
                if (vehicles.isEmpty) {
                  return const PrivateEmptyView(
                    message: 'No hay resultados para ese filtro.',
                  );
                }

                return RefreshIndicator(
                  color: PrivateUi.brown,
                  onRefresh: () async {
                    _reload();
                    await _future;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: vehicles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = vehicles[index];
                      return Container(
                        decoration: PrivateUi.cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.fotoUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: Image.network(
                                  item.fotoUrl,
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
                                    item.displayName,
                                    style: const TextStyle(
                                      color: PrivateUi.text,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Placa ${item.placa} | Anio ${item.anio} | Ruedas ${item.cantidadRuedas}',
                                    style: const TextStyle(
                                      color: PrivateUi.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      FilledButton.tonalIcon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  VehicleDetailScreen(
                                                    vehicleId: item.id,
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.assessment),
                                        label: const Text('Detalle'),
                                      ),
                                      FilledButton.tonalIcon(
                                        onPressed: () => _openEdit(item),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Editar'),
                                      ),
                                      FilledButton.tonalIcon(
                                        onPressed: () => _changePhoto(item),
                                        icon: const Icon(Icons.camera_alt),
                                        label: const Text('Foto'),
                                      ),
                                    ],
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
          ),
        ],
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

class _FilterField extends StatelessWidget {
  const _FilterField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
