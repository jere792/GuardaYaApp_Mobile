import 'package:flutter/material.dart';

class VentaDetailPage extends StatelessWidget {
  final String ventaId;
  const VentaDetailPage({super.key, required this.ventaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Venta')),
      body: Center(child: Text('Venta ID: $ventaId')),
    );
  }
}
