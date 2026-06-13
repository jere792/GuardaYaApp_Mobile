import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoriasPage extends StatelessWidget {
  const CategoriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          'Categorías - Próximamente',
          style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}