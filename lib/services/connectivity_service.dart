import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier for managing connectivity status
class ConnectivityStatusNotifier extends StateNotifier<bool> {
  final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityStatusNotifier(this._connectivity) : super(true) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    state = _isConnected(results);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> newResults) {
      state = _isConnected(newResults);
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

// Riverpod provider for ConnectivityStatusNotifier
final connectivityStatusProvider = StateNotifierProvider<ConnectivityStatusNotifier, bool>((ref) {
  return ConnectivityStatusNotifier(Connectivity());
});
