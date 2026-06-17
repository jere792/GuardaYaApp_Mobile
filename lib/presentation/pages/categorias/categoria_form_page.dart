import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/presentation/providers/categorias_provider.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class CategoriaFormPage extends ConsumerStatefulWidget {
  final String? categoriaId;

  const CategoriaFormPage({super.key, this.categoriaId});

  @override
  ConsumerState<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends ConsumerState<CategoriaFormPage> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.categoriaId != null;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargarDatos());
    }
  }

  void _cargarDatos() {
    final state = ref.read(categoriasProvider);
    final cat = state.categorias.where((c) => c.id == widget.categoriaId).firstOrNull;
    if (cat != null) {
      _nombreController.text = cat.nombre;
      _descripcionController.text = cat.descripcion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardar() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }

    final usuario = ref.read(authProvider).usuario;
    final empresaId = usuario?.empresaId;
    if (empresaId == null || empresaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: empresa no encontrada')),
      );
      return;
    }

    final now = DateTime.now();

    if (_isEditing) {
      final state = ref.read(categoriasProvider);
      final original = state.categorias.where((c) => c.id == widget.categoriaId).firstOrNull;
      if (original == null) return;

      await ref.read(categoriasProvider.notifier).actualizarCategoria(
        original.copyWith(
          nombre: nombre,
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
        ),
      );
    } else {
      await ref.read(categoriasProvider.notifier).crearCategoria(
        Categoria(
          id: '',
          empresaId: empresaId,
          nombre: nombre,
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          activo: true,
          createdAt: now,
        ),
      );
    }

    final newState = ref.read(categoriasProvider);
    if (newState.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Categoría actualizada' : 'Categoría creada')),
      );
      ref.read(categoriasProvider.notifier).resetSuccess();
      if (context.mounted) context.pop();
    } else if (newState.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState.error!), backgroundColor: Colors.red),
      );
      ref.read(categoriasProvider.notifier).resetError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            Consumer(builder: (context, ref, _) {
              final state = ref.watch(categoriasProvider);
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: state.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Guardar Cambios' : 'Crear Categoría', style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}