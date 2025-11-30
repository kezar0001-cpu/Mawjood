import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../utils/app_colors.dart';

class OfflineIndicator extends StatefulWidget {
  final Widget child;

  const OfflineIndicator({
    super.key,
    required this.child,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;
    _connectivityService.onConnectivityChanged.listen((isOnline) {
      setState(() {
        _isOnline = isOnline;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isOnline ? 0 : 32,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isOnline ? 0 : 1,
            child: Container(
              width: double.infinity,
              color: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'وضع غير متصل • Offline Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
