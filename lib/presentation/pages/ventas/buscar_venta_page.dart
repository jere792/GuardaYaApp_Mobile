import 'package:flutter/material.dart';

class BuscarVentaPage extends StatelessWidget {
  const BuscarVentaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Venta')),
      body: const Center(child: Text('Busqueda por codigo, telefono o nombre')),
    );
  }
}