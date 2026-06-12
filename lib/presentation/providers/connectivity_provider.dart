import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:guardaya_app/services/connectivity_service.dart';

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  final ConnectivityService _service = ConnectivityService();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(true) {
    _init();
  }

  void _init() {
    _subscription = _service.onConnectivityChanged.listen((results) {
      state = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    });
    checkNow();
  }

  Future<void> checkNow() async {
    state = await _service.isOnline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
