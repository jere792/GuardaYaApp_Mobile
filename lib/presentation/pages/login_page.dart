import 'package:flutter/material.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.storefront, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'GuardaYa',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gestion de Ventas con OCR',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contrasena',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar login
                },
                child: const Text('Iniciar Sesion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}