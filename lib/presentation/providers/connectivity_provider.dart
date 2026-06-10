import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/services/connectivity_service.dart';

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  final ConnectivityService _service = ConnectivityService();

  ConnectivityNotifier() : super(true) {
    _init();
  }

  void _init() {
    _service.onConnectivityChanged.listen((result) {
      state = result != ConnectivityResult.none;
    });
    checkNow();
  }

  Future<void> checkNow() async {
    state = await _service.isOnline;
  }
}