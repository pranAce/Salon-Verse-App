import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salonverse/core/storage/app_storage.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  bool _wasOffline = false;
  late final AnimationController _animController;
  late final Animation<double> _slideAnim;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _startMonitoring();
  }

  void _startMonitoring() {
    _subscription = AppStorage.connectionChecker.onStatusChange.listen((
      status,
    ) {
      final isOffline = status.toString().contains('disconnected');
      if (mounted) {
        setState(() {
          _wasOffline = _isOffline;
          _isOffline = isOffline;
        });
        if (_isOffline) {
          _animController.forward();
        } else {
          if (_wasOffline) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _animController.reverse();
            });
          } else {
            _animController.reverse();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _slideAnim,
      alignment: Alignment.bottomCenter,
      child: Material(
        color: _isOffline ? const Color(0xFFDC3545) : const Color(0xFF28A745),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _isOffline ? 'No internet connection' : 'Back online',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
