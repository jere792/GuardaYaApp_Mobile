import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
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
        requiresBatteryNotLow: true,
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
    // TODO: Implementar logica de sync de pending_ventas
    return Future.value(true);
  });
}
