import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/app.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/services/supabase_service.dart';
import 'package:guardaya_app/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (.env para desarrollo)
  // En producción con --dart-define, dotenv buscará el archivo pero
  // api_constants usará las variables compiladas
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Si .env no existe o falla, continuar igual
    // (usará --dart-define si está disponible)
  }

  // Inicializar Supabase
  await SupabaseService.initialize();

  // Inicializar WorkManager para sync en background
  await SyncService.initialize();

  // Crear un container para hacer checkAuth antes de runApp
  final container = ProviderContainer();
  try {
    await container.read(authProvider.notifier).checkAuth();
  } catch (e) {
    // Ignorar errores de checkAuth, la app seguirá al login
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GuardaYaApp(),
    ),
  );
}
