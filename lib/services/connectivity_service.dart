import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectionStatusController;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged {
    _connectionStatusController ??= StreamController<bool>.broadcast();
    return _connectionStatusController!.stream;
  }

  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(result.first);

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline = _isConnected(results.first);

      // Only emit if status changed
      if (wasOnline != _isOnline) {
        _connectionStatusController?.add(_isOnline);
      }
    });
  }

  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _connectionStatusController?.close();
  }
}
