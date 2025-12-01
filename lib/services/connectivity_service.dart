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
    final results = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(results);

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> newResults) {
      final wasOnline = _isOnline;
      _isOnline = _isConnected(newResults);

      // Only emit if status changed
      if (wasOnline != _isOnline) {
        _connectionStatusController?.add(_isOnline);
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none);
  }

  void dispose() {
    _connectionStatusController?.close();
  }
}
