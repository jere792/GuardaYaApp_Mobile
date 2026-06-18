import 'package:flutter/material.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    this.title = 'Confirmar',
    required this.message,
    this.confirmText = 'Guardar',
    this.cancelText = 'Cancelar',
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Confirmar',
    required String message,
    String confirmText = 'Guardar',
    String cancelText = 'Cancelar',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.help_outline, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 15, color: cs.onSurface, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText, style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF8C42)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onConfirm,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  confirmText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
