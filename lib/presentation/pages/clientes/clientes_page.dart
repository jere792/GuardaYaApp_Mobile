import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          'Clientes - Próximamente',
          style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}