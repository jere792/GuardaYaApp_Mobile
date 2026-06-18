import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:guardaya_app/core/constants/api_constants.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) return false;
    try {
      final host = Uri.tryParse(ApiConstants.supabaseUrl)?.host ?? 'google.com';
      final list = await InternetAddress.lookup(host).timeout(const Duration(seconds: 3));
      return list.isNotEmpty && list.any((a) => a.rawAddress.isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isOffline async {
    return !(await isOnline);
  }
}
