import 'package:flutter/material.dart';

class VentasListPage extends StatelessWidget {
  const VentasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas del Dia')),
      body: const Center(child: Text('Lista de ventas')),
    );
  }
}