import 'package:flutter/material.dart';

class BuscarVentaPage extends StatelessWidget {
  const BuscarVentaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Venta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const Center(child: Text('Busqueda por codigo, telefono o nombre')),
    );
  }
}
