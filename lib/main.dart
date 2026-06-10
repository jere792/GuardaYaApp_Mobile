import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guardaya_app/app.dart';
import 'package:guardaya_app/services/supabase_service.dart';
import 'package:guardaya_app/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');
  
  // Inicializar Supabase
  await SupabaseService.initialize();
  
  // Inicializar WorkManager para sync en background
  await SyncService.initialize();
  
  runApp(const GuardaYaApp());
}
