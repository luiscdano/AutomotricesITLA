import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/private_repository.dart';
import '../../models/private_models.dart';
import '../private_ui.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Future<VehicleDetail> _future;
  final _money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<VehicleDetail> _load() async {
    final result = await context.read<PrivateRepository>().fetchVehicleDetail(
      id: widget.vehicleId,
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
      backgroundColor: PrivateUi.bg,
      appBar: AppBar(
        title: const Text('Detalle vehiculo'),
        backgroundColor: PrivateUi.bg,
        foregroundColor: PrivateUi.text,
      ),
      body: FutureBuilder<VehicleDetail>(
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
          final vehicle = detail.vehicle;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: PrivateUi.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vehicle.fotoUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.network(
                          vehicle.fotoUrl,
                          width: double.infinity,
                          height: 190,
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
                            vehicle.displayName,
                            style: const TextStyle(
                              color: PrivateUi.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Placa: ${vehicle.placa}',
                            style: const TextStyle(color: PrivateUi.muted),
                          ),
                          Text(
                            'Chasis: ${vehicle.chasis}',
                            style: const TextStyle(color: PrivateUi.muted),
                          ),
                          Text(
                            'Anio: ${vehicle.anio}',
                            style: const TextStyle(color: PrivateUi.muted),
                          ),
                          Text(
                            'Ruedas: ${vehicle.cantidadRuedas}',
                            style: const TextStyle(color: PrivateUi.muted),
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
                      'Resumen financiero',
                      style: TextStyle(
                        color: PrivateUi.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MoneyRow(
                      label: 'Total mantenimientos',
                      value: _money.format(detail.summary.totalMantenimientos),
                    ),
                    _MoneyRow(
                      label: 'Total combustible',
                      value: _money.format(detail.summary.totalCombustible),
                    ),
                    _MoneyRow(
                      label: 'Total gastos',
                      value: _money.format(detail.summary.totalGastos),
                    ),
                    _MoneyRow(
                      label: 'Total ingresos',
                      value: _money.format(detail.summary.totalIngresos),
                    ),
                    _MoneyRow(
                      label: 'Total invertido',
                      value: _money.format(detail.summary.totalInvertido),
                    ),
                    _MoneyRow(
                      label: 'Balance',
                      value: _money.format(detail.summary.balance),
                      isLast: true,
                      valueColor: detail.summary.balance >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
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

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isLast;
  final Color? valueColor;

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
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: PrivateUi.text)),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? PrivateUi.cream,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
