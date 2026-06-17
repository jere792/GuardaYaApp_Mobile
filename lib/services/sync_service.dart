import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:guardaya_app/core/constants/api_constants.dart';
import 'package:guardaya_app/core/constants/app_constants.dart';

class SyncService {
  static const String syncTaskName = 'guardaya_sync_ventas';

  static Future<void> initialize() async {
    // Workmanager no funciona en web
    if (kIsWeb) return;
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> registerPeriodicSync() async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      syncTaskName,
      syncTaskName,
      frequency: Duration(minutes: AppConstants.syncIntervalMinutes),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelSync() async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName(syncTaskName);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // No hay credenciales compiladas => no se puede sync
      if (ApiConstants.supabaseUrl.isEmpty || ApiConstants.supabaseAnonKey.isEmpty) {
        return Future.value(false);
      }

      await Supabase.initialize(
        url: ApiConstants.supabaseUrl,
        publishableKey: ApiConstants.supabaseAnonKey,
      );
      final supabase = Supabase.instance.client;

      // Abrir la base de datos local
      final dbPath = join(await getDatabasesPath(), 'guardaya.db');
      final db = await openDatabase(dbPath);

      // Leer ventas pendientes que no hayan excedido reintentos
      final pending = await db.query(
        'pending_ventas',
        where: 'sync_status = ? AND retry_count < ?',
        whereArgs: ['pending', 10],
      );

      for (final venta in pending) {
        try {
          final ventaMap = Map<String, dynamic>.from(venta);
          // Limpiar campos internos antes de enviar
          ventaMap.remove('sync_status');
          ventaMap.remove('sync_error');
          ventaMap.remove('retry_count');
          ventaMap.remove('imagen_yape_local_path');
          ventaMap.remove('imagen_entrega_local_path');
          ventaMap.remove('cliente_id');
          // Convertir fecha_yape a ISO 8601
          if (ventaMap['fecha_yape'] != null && ventaMap['fecha_yape'] is String) {
            final parsed = _parseFechaToIso(ventaMap['fecha_yape'] as String);
            ventaMap['fecha_yape'] = parsed;
          }
          ventaMap['created_at'] = ventaMap['created_at'] ?? DateTime.now().toIso8601String();

          await supabase.from('ventas').insert(ventaMap);

          await db.update(
            'pending_ventas',
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [venta['id']],
          );
        } catch (e) {
          final currentRetries = (venta['retry_count'] as int? ?? 0) + 1;
          await db.update(
            'pending_ventas',
            {
              'sync_status': currentRetries >= 10 ? 'failed' : 'error',
              'sync_error': e.toString().substring(0, 500),
              'retry_count': currentRetries,
            },
            where: 'id = ?',
            whereArgs: [venta['id']],
          );
        }
      }

      await db.close();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

String? _parseFechaToIso(String fecha) {
  try {
    final parts = fecha.split(RegExp(r'[/-]'));
    if (parts.length == 3 && parts[0].length <= 2) {
      final dia = parts[0].padLeft(2, '0');
      final mes = parts[1].padLeft(2, '0');
      final anio = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
      return '$anio-$mes-${dia}T00:00:00.000Z';
    }

    const meses = {
      'ene': '01', 'feb': '02', 'mar': '03', 'abr': '04',
      'may': '05', 'jun': '06', 'jul': '07', 'ago': '08',
      'sep': '09', 'oct': '10', 'nov': '11', 'dic': '12',
    };
    final textMatch = RegExp(r'(\d{1,2})\s+([a-z]{3})[a-z]*\.?\s+(\d{4})', caseSensitive: false).firstMatch(fecha);
    if (textMatch != null) {
      final dia = textMatch.group(1)!.padLeft(2, '0');
      final mes = meses[textMatch.group(2)!.toLowerCase()] ?? '01';
      final anio = textMatch.group(3)!;
      return '$anio-$mes-${dia}T00:00:00.000Z';
    }
  } catch (_) {}
  return fecha;
}
