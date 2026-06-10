import 'package:flutter/material.dart';

class RegistrarVentaPage extends StatelessWidget {
  const RegistrarVentaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: const Center(child: Text('Formulario + OCR de Comprobante')),
    );
  }
}