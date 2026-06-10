import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  Stream<ConnectivityResult> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> get isOffline async {
    return !(await isOnline);
  }
}