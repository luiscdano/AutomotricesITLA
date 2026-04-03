import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/private_repository.dart';
import '../../models/private_models.dart';
import '../image_picker_helper.dart';
import '../private_ui.dart';

class VehicleOperationsScreen extends StatefulWidget {
  const VehicleOperationsScreen({super.key});

  @override
  State<VehicleOperationsScreen> createState() =>
      _VehicleOperationsScreenState();
}

class _VehicleOperationsScreenState extends State<VehicleOperationsScreen> {
  late Future<List<VehicleItem>> _vehiclesFuture;
  int? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _loadVehicles();
  }

  Future<List<VehicleItem>> _loadVehicles() async {
    final result = await context.read<PrivateRepository>().fetchVehicles(
      limit: 120,
    );
    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? 'No se pudo cargar la lista de vehiculos.',
      );
    }

    final vehicles = result.data!.items;
    if (vehicles.isNotEmpty) {
      final current = _selectedVehicleId;
      final exists =
          current != null && vehicles.any((item) => item.id == current);
      _selectedVehicleId = exists ? current : vehicles.first.id;
    }

    return vehicles;
  }

  void _reloadVehicles() {
    setState(() {
      _vehiclesFuture = _loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: const Text('Fase 4 - Operaciones del vehiculo'),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
      ),
      body: FutureBuilder<List<VehicleItem>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: PrivateUi.cream),
            );
          }

          if (snapshot.hasError) {
            return PrivateErrorView(
              message: _errorText(snapshot.error),
              onRetry: _reloadVehicles,
            );
          }

          final vehicles = snapshot.data ?? <VehicleItem>[];
          if (vehicles.isEmpty) {
            return const PrivateEmptyView(
              message:
                  'No tienes vehiculos. Registra uno en "Mis vehiculos" antes de usar este modulo.',
            );
          }

          final selectedId = _selectedVehicleId ?? vehicles.first.id;

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: PrivateUi.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecciona el vehiculo a gestionar',
                          style: TextStyle(
                            color: PrivateUi.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _VehicleDropdown(
                          vehicles: vehicles,
                          value: selectedId,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedVehicleId = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const TabBar(
                    labelColor: PrivateUi.text,
                    unselectedLabelColor: PrivateUi.muted,
                    indicatorColor: PrivateUi.brown,
                    tabs: [
                      Tab(text: 'Manten.'),
                      Tab(text: 'Combust.'),
                      Tab(text: 'Gomas'),
                      Tab(text: 'Finanzas'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _MaintenanceModule(
                        key: ValueKey<int>(selectedId * 10 + 1),
                        vehicleId: selectedId,
                      ),
                      _FuelModule(
                        key: ValueKey<int>(selectedId * 10 + 2),
                        vehicleId: selectedId,
                      ),
                      _TiresModule(
                        key: ValueKey<int>(selectedId * 10 + 3),
                        vehicleId: selectedId,
                      ),
                      _FinanceModule(
                        key: ValueKey<int>(selectedId * 10 + 4),
                        vehicleId: selectedId,
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
  }

  String _errorText(Object? error) {
    return (error?.toString() ?? 'Error desconocido').replaceFirst(
      'Exception: ',
      '',
    );
  }
}

class _VehicleDropdown extends StatelessWidget {
  const _VehicleDropdown({
    required this.vehicles,
    required this.value,
    required this.onChanged,
  });

  final List<VehicleItem> vehicles;
  final int value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      key: ValueKey<int>(value),
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: PrivateUi.text),
      decoration: _darkInputDecoration('Vehiculo'),
      items: vehicles
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.id,
              child: Text('${item.marca} ${item.modelo} - ${item.placa}'),
            ),
          )
          .toList(),
    );
  }
}

class _MaintenanceModule extends StatefulWidget {
  const _MaintenanceModule({required this.vehicleId, super.key});

  final int vehicleId;

  @override
  State<_MaintenanceModule> createState() => _MaintenanceModuleState();
}

class _MaintenanceModuleState extends State<_MaintenanceModule> {
  final _money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');
  final _filterController = TextEditingController();

  late Future<List<MaintenanceRecord>> _future;
  String? _tipoFilter;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<List<MaintenanceRecord>> _load() async {
    final result = await context.read<PrivateRepository>().fetchMaintenances(
      vehiculoId: widget.vehicleId,
      tipo: _tipoFilter,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? 'No se pudieron cargar los mantenimientos.',
      );
    }

    return result.data!;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _createMaintenance() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _MaintenanceFormSheet(vehicleId: widget.vehicleId),
    );

    if (changed == true) {
      _reload();
    }
  }

  Future<void> _openDetail(int id) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _MaintenanceDetailSheet(maintenanceId: id),
    );
  }

  Future<void> _addPhotos(int id) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _MaintenancePhotosSheet(maintenanceId: id),
    );

    if (changed == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: PrivateUi.cardDecoration(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _filterController,
                        style: const TextStyle(color: PrivateUi.text),
                        decoration: _darkInputDecoration('Filtrar por tipo'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Aplicar',
                      onPressed: () {
                        final value = _filterController.text.trim();
                        setState(() {
                          _tipoFilter = value.isEmpty ? null : value;
                          _future = _load();
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Limpiar',
                      onPressed: () {
                        _filterController.clear();
                        setState(() {
                          _tipoFilter = null;
                          _future = _load();
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _createMaintenance,
                    style: FilledButton.styleFrom(
                      backgroundColor: PrivateUi.brown,
                    ),
                    icon: const Icon(Icons.build_circle_outlined),
                    label: const Text('Registrar mantenimiento'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MaintenanceRecord>>(
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

              final items = snapshot.data ?? <MaintenanceRecord>[];
              if (items.isEmpty) {
                return const PrivateEmptyView(
                  message:
                      'No hay mantenimientos registrados para este vehiculo.',
                );
              }

              return RefreshIndicator(
                color: PrivateUi.brown,
                onRefresh: () async {
                  _reload();
                  await _future;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      decoration: PrivateUi.cardDecoration(),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tipo.isEmpty ? 'Mantenimiento' : item.tipo,
                            style: const TextStyle(
                              color: PrivateUi.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Costo: ${_money.format(item.costo)}',
                            style: const TextStyle(color: PrivateUi.cream),
                          ),
                          Text(
                            'Fecha: ${item.fecha.isEmpty ? '-' : item.fecha}',
                            style: const TextStyle(color: PrivateUi.muted),
                          ),
                          if (item.piezas.isNotEmpty)
                            Text(
                              'Piezas: ${item.piezas}',
                              style: const TextStyle(color: PrivateUi.muted),
                            ),
                          if (item.fotos.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 70,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: item.fotos.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, photoIndex) {
                                  final url = item.fotos[photoIndex];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      url,
                                      width: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 90,
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: PrivateUi.muted,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _openDetail(item.id),
                                icon: const Icon(Icons.visibility_outlined),
                                label: const Text('Detalle'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => _addPhotos(item.id),
                                icon: const Icon(Icons.add_a_photo),
                                label: const Text('Subir fotos'),
                              ),
                            ],
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
    );
  }
}

class _MaintenanceDetailSheet extends StatefulWidget {
  const _MaintenanceDetailSheet({required this.maintenanceId});

  final int maintenanceId;

  @override
  State<_MaintenanceDetailSheet> createState() =>
      _MaintenanceDetailSheetState();
}

class _MaintenanceDetailSheetState extends State<_MaintenanceDetailSheet> {
  late Future<MaintenanceRecord> _future;
  final _money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<MaintenanceRecord> _load() async {
    final result = await context
        .read<PrivateRepository>()
        .fetchMaintenanceDetail(id: widget.maintenanceId);

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ??
            'No se pudo cargar el detalle del mantenimiento.',
      );
    }

    return result.data!;
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Detalle mantenimiento',
      child: FutureBuilder<MaintenanceRecord>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: PrivateUi.cream),
              ),
            );
          }

          if (snapshot.hasError) {
            return Text(
              _errorText(snapshot.error),
              style: const TextStyle(color: Colors.redAccent),
            );
          }

          final item = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.tipo,
                style: const TextStyle(
                  color: PrivateUi.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Costo: ${_money.format(item.costo)}',
                style: const TextStyle(color: PrivateUi.cream),
              ),
              Text(
                'Fecha: ${item.fecha.isEmpty ? '-' : item.fecha}',
                style: const TextStyle(color: PrivateUi.muted),
              ),
              if (item.piezas.isNotEmpty)
                Text(
                  'Piezas: ${item.piezas}',
                  style: const TextStyle(color: PrivateUi.muted),
                ),
              const SizedBox(height: 12),
              const Text(
                'Fotos',
                style: TextStyle(
                  color: PrivateUi.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (item.fotos.isEmpty)
                const Text(
                  'No hay fotos registradas.',
                  style: TextStyle(color: PrivateUi.muted),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.fotos
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.white.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: PrivateUi.muted,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MaintenancePhotosSheet extends StatefulWidget {
  const _MaintenancePhotosSheet({required this.maintenanceId});

  final int maintenanceId;

  @override
  State<_MaintenancePhotosSheet> createState() =>
      _MaintenancePhotosSheetState();
}

class _MaintenancePhotosSheetState extends State<_MaintenancePhotosSheet> {
  final List<String> _photos = <String>[];
  bool _saving = false;

  Future<void> _pickPhoto() async {
    if (_photos.length >= 5) return;

    final path = await pickImagePath(context);
    if (path == null || path.isEmpty) return;

    setState(() {
      _photos.add(path);
    });
  }

  Future<void> _submit() async {
    if (_photos.isEmpty) {
      _showSnack('Agrega al menos una foto.');
      return;
    }

    setState(() => _saving = true);

    final result = await context
        .read<PrivateRepository>()
        .uploadMaintenancePhotos(
          maintenanceId: widget.maintenanceId,
          photoPaths: _photos,
        );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.isFailure) {
      _showSnack(result.errorMessage ?? 'No se pudieron subir las fotos.');
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Subir fotos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Puedes subir hasta 5 fotos en una sola carga.',
            style: TextStyle(color: PrivateUi.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _photos.length; i++)
                Chip(
                  label: Text(
                    'Foto ${i + 1}',
                    style: const TextStyle(color: PrivateUi.text),
                  ),
                  deleteIconColor: Colors.redAccent,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  onDeleted: () {
                    setState(() {
                      _photos.removeAt(i);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _photos.length >= 5 ? null : _pickPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Agregar foto'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: PrivateUi.brown),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Subir fotos'),
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

class _MaintenanceFormSheet extends StatefulWidget {
  const _MaintenanceFormSheet({required this.vehicleId});

  final int vehicleId;

  @override
  State<_MaintenanceFormSheet> createState() => _MaintenanceFormSheetState();
}

class _MaintenanceFormSheetState extends State<_MaintenanceFormSheet> {
  final _typeController = TextEditingController();
  final _costController = TextEditingController();
  final _piecesController = TextEditingController();
  final _dateController = TextEditingController();

  final List<String> _photos = <String>[];
  bool _saving = false;

  @override
  void dispose() {
    _typeController.dispose();
    _costController.dispose();
    _piecesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= 5) return;

    final path = await pickImagePath(context);
    if (path == null || path.isEmpty) return;

    setState(() {
      _photos.add(path);
    });
  }

  Future<void> _submit() async {
    final tipo = _typeController.text.trim();
    final costo = double.tryParse(_costController.text.trim());

    if (tipo.isEmpty) {
      _showSnack('El tipo es obligatorio.');
      return;
    }
    if (costo == null || costo <= 0) {
      _showSnack('Ingresa un costo valido.');
      return;
    }

    setState(() => _saving = true);

    final result = await context.read<PrivateRepository>().createMaintenance(
      input: MaintenanceInput(
        vehiculoId: widget.vehicleId,
        tipo: tipo,
        costo: costo,
        piezas: _piecesController.text.trim(),
        fecha: _dateController.text.trim(),
      ),
      photoPaths: _photos,
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.isFailure) {
      _showSnack(
        result.errorMessage ?? 'No se pudo registrar el mantenimiento.',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Nuevo mantenimiento',
      child: Column(
        children: [
          TextField(
            controller: _typeController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Tipo (ej: Cambio de aceite)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _costController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Costo'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _piecesController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Piezas (opcional)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _dateController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Fecha YYYY-MM-DD (opcional)'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _photos.length; i++)
                  Chip(
                    label: Text(
                      'Foto ${i + 1}',
                      style: const TextStyle(color: PrivateUi.text),
                    ),
                    deleteIconColor: Colors.redAccent,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    onDeleted: () {
                      setState(() {
                        _photos.removeAt(i);
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _photos.length >= 5 ? null : _pickPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: Text(
                _photos.length >= 5
                    ? 'Limite alcanzado (5)'
                    : 'Agregar foto (opcional)',
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: PrivateUi.brown),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Registrar'),
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

class _FuelModule extends StatefulWidget {
  const _FuelModule({required this.vehicleId, super.key});

  final int vehicleId;

  @override
  State<_FuelModule> createState() => _FuelModuleState();
}

class _FuelModuleState extends State<_FuelModule> {
  final _money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');
  late Future<List<FuelRecord>> _future;
  String? _tipo;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<FuelRecord>> _load() async {
    final result = await context.read<PrivateRepository>().fetchFuelRecords(
      vehiculoId: widget.vehicleId,
      tipo: _tipo,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? 'No se pudo cargar el historial de combustible.',
      );
    }

    return result.data!;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _openCreate() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _FuelFormSheet(vehicleId: widget.vehicleId),
    );

    if (changed == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: PrivateUi.cardDecoration(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey<String?>(_tipo),
                  initialValue: _tipo,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: PrivateUi.text),
                  decoration: _darkInputDecoration('Filtrar por tipo'),
                  items: const [
                    DropdownMenuItem<String>(value: null, child: Text('Todos')),
                    DropdownMenuItem<String>(
                      value: 'combustible',
                      child: Text('Combustible'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'aceite',
                      child: Text('Aceite'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipo = value;
                      _future = _load();
                    });
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openCreate,
                    style: FilledButton.styleFrom(
                      backgroundColor: PrivateUi.brown,
                    ),
                    icon: const Icon(Icons.local_gas_station_outlined),
                    label: const Text('Registrar carga'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<FuelRecord>>(
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

              final items = snapshot.data ?? <FuelRecord>[];
              if (items.isEmpty) {
                return const PrivateEmptyView(
                  message:
                      'No hay registros de combustible/aceite para este vehiculo.',
                );
              }

              return RefreshIndicator(
                color: PrivateUi.brown,
                onRefresh: () async {
                  _reload();
                  await _future;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      decoration: PrivateUi.cardDecoration(),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tipo.toUpperCase(),
                            style: const TextStyle(
                              color: PrivateUi.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Cantidad: ${item.cantidad} ${item.unidad}',
                            style: const TextStyle(color: PrivateUi.muted),
                          ),
                          Text(
                            'Monto: ${_money.format(item.monto)}',
                            style: const TextStyle(color: PrivateUi.cream),
                          ),
                          Text(
                            'Fecha: ${item.fecha.isEmpty ? '-' : item.fecha}',
                            style: const TextStyle(color: PrivateUi.muted),
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
    );
  }
}

class _FuelFormSheet extends StatefulWidget {
  const _FuelFormSheet({required this.vehicleId});

  final int vehicleId;

  @override
  State<_FuelFormSheet> createState() => _FuelFormSheetState();
}

class _FuelFormSheetState extends State<_FuelFormSheet> {
  String _tipo = 'combustible';
  final _cantidadController = TextEditingController();
  final _unidadController = TextEditingController(text: 'galones');
  final _montoController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _unidadController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cantidad = double.tryParse(_cantidadController.text.trim());
    final monto = double.tryParse(_montoController.text.trim());
    final unidad = _unidadController.text.trim();

    if (cantidad == null || cantidad <= 0) {
      _showSnack('Ingresa una cantidad valida.');
      return;
    }
    if (monto == null || monto <= 0) {
      _showSnack('Ingresa un monto valido.');
      return;
    }
    if (unidad.isEmpty) {
      _showSnack('La unidad es obligatoria.');
      return;
    }

    setState(() => _saving = true);

    final result = await context.read<PrivateRepository>().createFuelRecord(
      input: FuelInput(
        vehiculoId: widget.vehicleId,
        tipo: _tipo,
        cantidad: cantidad,
        unidad: unidad,
        monto: monto,
      ),
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.isFailure) {
      _showSnack(result.errorMessage ?? 'No se pudo registrar la carga.');
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Registrar carga',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey<String>(_tipo),
            initialValue: _tipo,
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Tipo'),
            items: const [
              DropdownMenuItem(
                value: 'combustible',
                child: Text('Combustible'),
              ),
              DropdownMenuItem(value: 'aceite', child: Text('Aceite')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _tipo = value);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cantidadController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Cantidad'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _unidadController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Unidad (galones, litros, etc.)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Monto'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: PrivateUi.brown),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar'),
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

class _TiresModule extends StatefulWidget {
  const _TiresModule({required this.vehicleId, super.key});

  final int vehicleId;

  @override
  State<_TiresModule> createState() => _TiresModuleState();
}

class _TiresModuleState extends State<_TiresModule> {
  static const List<String> _states = <String>[
    'buena',
    'regular',
    'mala',
    'reemplazada',
  ];

  late Future<TireState> _future;
  final Map<int, String> _pendingStates = <int, String>{};
  int? _updatingTireId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<TireState> _load() async {
    final result = await context.read<PrivateRepository>().fetchTireState(
      vehiculoId: widget.vehicleId,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? 'No se pudo cargar el estado de las gomas.',
      );
    }

    return result.data!;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _saveState(TireStatus tire) async {
    final state =
        _pendingStates[tire.id] ??
        (tire.estado.isEmpty ? 'buena' : tire.estado);

    setState(() => _updatingTireId = tire.id);

    final result = await context.read<PrivateRepository>().updateTireStatus(
      tireId: tire.id,
      estado: state,
    );

    if (!mounted) return;

    setState(() => _updatingTireId = null);

    final message = result.isSuccess
        ? 'Estado de goma actualizado.'
        : (result.errorMessage ?? 'No se pudo actualizar la goma.');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (result.isSuccess) {
      _reload();
    }
  }

  Future<void> _registerPuncture(TireStatus tire) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _TirePunctureSheet(tireId: tire.id),
    );

    if (changed == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TireState>(
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

        final state = snapshot.data!;
        if (state.gomas.isEmpty) {
          return const PrivateEmptyView(
            message: 'No hay gomas registradas para este vehiculo.',
          );
        }

        return RefreshIndicator(
          color: PrivateUi.brown,
          onRefresh: () async {
            _reload();
            await _future;
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: state.gomas.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  decoration: PrivateUi.cardDecoration(),
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Cantidad de ruedas configurada: ${state.cantidadRuedas}',
                    style: const TextStyle(
                      color: PrivateUi.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              final tire = state.gomas[index - 1];
              final current =
                  _pendingStates[tire.id] ??
                  (tire.estado.isEmpty ? 'buena' : tire.estado);

              return Container(
                decoration: PrivateUi.cardDecoration(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posicion ${tire.posicion} (Eje ${tire.eje})',
                      style: const TextStyle(
                        color: PrivateUi.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pinchazos registrados: ${tire.totalPinchazos}',
                      style: const TextStyle(color: PrivateUi.muted),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      key: ValueKey<String>(current),
                      initialValue: _states.contains(current)
                          ? current
                          : _states.first,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: PrivateUi.text),
                      decoration: _darkInputDecoration('Estado'),
                      items: _states
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _pendingStates[tire.id] = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _updatingTireId == tire.id
                              ? null
                              : () => _saveState(tire),
                          style: FilledButton.styleFrom(
                            backgroundColor: PrivateUi.brown,
                          ),
                          icon: _updatingTireId == tire.id
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Actualizar estado'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _registerPuncture(tire),
                          icon: const Icon(Icons.report_problem_outlined),
                          label: const Text('Registrar pinchazo'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TirePunctureSheet extends StatefulWidget {
  const _TirePunctureSheet({required this.tireId});

  final int tireId;

  @override
  State<_TirePunctureSheet> createState() => _TirePunctureSheetState();
}

class _TirePunctureSheetState extends State<_TirePunctureSheet> {
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);

    final result = await context.read<PrivateRepository>().registerTirePuncture(
      tireId: widget.tireId,
      descripcion: _descriptionController.text.trim(),
      fecha: _dateController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'No se pudo registrar el pinchazo.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Registrar pinchazo',
      child: Column(
        children: [
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Descripcion (opcional)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _dateController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Fecha YYYY-MM-DD (opcional)'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: PrivateUi.brown),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar pinchazo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceModule extends StatefulWidget {
  const _FinanceModule({required this.vehicleId, super.key});

  final int vehicleId;

  @override
  State<_FinanceModule> createState() => _FinanceModuleState();
}

class _FinanceModuleState extends State<_FinanceModule> {
  final _money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');
  late Future<_FinanceData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_FinanceData> _load() async {
    final repository = context.read<PrivateRepository>();

    final expensesResult = await repository.fetchExpenses(
      vehiculoId: widget.vehicleId,
    );
    if (expensesResult.isFailure || expensesResult.data == null) {
      throw Exception(
        expensesResult.errorMessage ?? 'No se pudieron cargar los gastos.',
      );
    }

    final incomesResult = await repository.fetchIncomes(
      vehiculoId: widget.vehicleId,
    );
    if (incomesResult.isFailure || incomesResult.data == null) {
      throw Exception(
        incomesResult.errorMessage ?? 'No se pudieron cargar los ingresos.',
      );
    }

    final categoriesResult = await repository.fetchExpenseCategories();
    final categories = categoriesResult.data ?? <ExpenseCategory>[];

    return _FinanceData(
      categories: categories,
      expenses: expensesResult.data!,
      incomes: incomesResult.data!,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _createExpense(List<ExpenseCategory> categories) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _ExpenseFormSheet(
        vehicleId: widget.vehicleId,
        categories: categories,
      ),
    );

    if (changed == true) {
      _reload();
    }
  }

  Future<void> _createIncome() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PrivateUi.bg,
      builder: (_) => _IncomeFormSheet(vehicleId: widget.vehicleId),
    );

    if (changed == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FinanceData>(
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

        final data = snapshot.data!;
        final totalExpenses = data.expenses.fold<double>(
          0,
          (sum, item) => sum + item.monto,
        );
        final totalIncomes = data.incomes.fold<double>(
          0,
          (sum, item) => sum + item.monto,
        );
        final balance = totalIncomes - totalExpenses;

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
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de gastos e ingresos',
                      style: TextStyle(
                        color: PrivateUi.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total gastos: ${_money.format(totalExpenses)}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    Text(
                      'Total ingresos: ${_money.format(totalIncomes)}',
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                    Text(
                      'Balance: ${_money.format(balance)}',
                      style: TextStyle(
                        color: balance >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _createExpense(data.categories),
                          style: FilledButton.styleFrom(
                            backgroundColor: PrivateUi.brown,
                          ),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('Registrar gasto'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _createIncome,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Registrar ingreso'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _FinanceListCard(
                title: 'Gastos',
                emptyText: 'No hay gastos para este vehiculo.',
                children: data.expenses
                    .map(
                      (item) => _FinanceRow(
                        title: item.categoriaNombre.isEmpty
                            ? 'Categoria ${item.categoriaId}'
                            : item.categoriaNombre,
                        subtitle: item.descripcion.isEmpty
                            ? item.fecha
                            : '${item.descripcion} | ${item.fecha}',
                        amountText: _money.format(item.monto),
                        amountColor: Colors.redAccent,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              _FinanceListCard(
                title: 'Ingresos',
                emptyText: 'No hay ingresos para este vehiculo.',
                children: data.incomes
                    .map(
                      (item) => _FinanceRow(
                        title: item.concepto,
                        subtitle: item.fecha,
                        amountText: _money.format(item.monto),
                        amountColor: Colors.greenAccent,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FinanceData {
  const _FinanceData({
    required this.categories,
    required this.expenses,
    required this.incomes,
  });

  final List<ExpenseCategory> categories;
  final List<ExpenseRecord> expenses;
  final List<IncomeRecord> incomes;
}

class _FinanceListCard extends StatelessWidget {
  const _FinanceListCard({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PrivateUi.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PrivateUi.text,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          if (children.isEmpty)
            Text(emptyText, style: const TextStyle(color: PrivateUi.muted))
          else
            ...children,
        ],
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  const _FinanceRow({
    required this.title,
    required this.subtitle,
    required this.amountText,
    required this.amountColor,
  });

  final String title;
  final String subtitle;
  final String amountText;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PrivateUi.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle.isEmpty ? '-' : subtitle,
                  style: const TextStyle(color: PrivateUi.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ExpenseFormSheet extends StatefulWidget {
  const _ExpenseFormSheet({required this.vehicleId, required this.categories});

  final int vehicleId;
  final List<ExpenseCategory> categories;

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  int? _categoryId;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _categoryId = widget.categories.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_categoryId == null) {
      _showSnack('No hay categorias disponibles.');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnack('Ingresa un monto valido.');
      return;
    }

    setState(() => _saving = true);

    final result = await context.read<PrivateRepository>().createExpense(
      input: ExpenseInput(
        vehiculoId: widget.vehicleId,
        categoriaId: _categoryId!,
        monto: amount,
        descripcion: _descriptionController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.isFailure) {
      _showSnack(result.errorMessage ?? 'No se pudo registrar el gasto.');
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Registrar gasto',
      child: Column(
        children: [
          if (widget.categories.isEmpty)
            const Text(
              'No se pudieron cargar categorias de gasto desde el backend.',
              style: TextStyle(color: Colors.redAccent),
            )
          else
            DropdownButtonFormField<int>(
              key: ValueKey<int?>(_categoryId),
              initialValue: _categoryId,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: PrivateUi.text),
              decoration: _darkInputDecoration('Categoria'),
              items: widget.categories
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.nombre),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _categoryId = value),
            ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Monto'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Descripcion (opcional)'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_saving || widget.categories.isEmpty)
                  ? null
                  : _submit,
              style: FilledButton.styleFrom(backgroundColor: PrivateUi.brown),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar gasto'),
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

class _IncomeFormSheet extends StatefulWidget {
  const _IncomeFormSheet({required this.vehicleId});

  final int vehicleId;

  @override
  State<_IncomeFormSheet> createState() => _IncomeFormSheetState();
}

class _IncomeFormSheetState extends State<_IncomeFormSheet> {
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    final concept = _conceptController.text.trim();

    if (amount == null || amount <= 0) {
      _showSnack('Ingresa un monto valido.');
      return;
    }
    if (concept.isEmpty) {
      _showSnack('El concepto es obligatorio.');
      return;
    }

    setState(() => _saving = true);

    final result = await context.read<PrivateRepository>().createIncome(
      input: IncomeInput(
        vehiculoId: widget.vehicleId,
        monto: amount,
        concepto: concept,
      ),
    );

    if (!mounted) return;

    setState(() => _saving = false);

    if (result.isFailure) {
      _showSnack(result.errorMessage ?? 'No se pudo registrar el ingreso.');
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Registrar ingreso',
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Monto'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _conceptController,
            style: const TextStyle(color: PrivateUi.text),
            decoration: _darkInputDecoration('Concepto'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: PrivateUi.brown),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Guardar ingreso'),
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

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
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
              child,
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _darkInputDecoration(String label) {
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

String _errorText(Object? error) {
  return (error?.toString() ?? 'Error desconocido').replaceFirst(
    'Exception: ',
    '',
  );
}
