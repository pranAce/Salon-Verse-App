import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salonverse/services/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  static SocketService get instance => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final StreamController<Map<String, dynamic>> _subscriptionUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _bookingCreatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _bookingUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _availabilityUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _loyaltyTierUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _loyaltyBalanceUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _settlementUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onSubscriptionUpdated => _subscriptionUpdateController.stream;
  Stream<Map<String, dynamic>> get onBookingCreated => _bookingCreatedController.stream;
  Stream<Map<String, dynamic>> get onBookingUpdated => _bookingUpdatedController.stream;
  Stream<Map<String, dynamic>> get onAvailabilityUpdated => _availabilityUpdatedController.stream;
  Stream<Map<String, dynamic>> get onLoyaltyTierUpdated => _loyaltyTierUpdatedController.stream;
  Stream<Map<String, dynamic>> get onLoyaltyBalanceUpdated => _loyaltyBalanceUpdatedController.stream;
  Stream<Map<String, dynamic>> get onSettlementUpdated => _settlementUpdatedController.stream;

  Future<void> connect([String? explicitToken]) async {
    String? token = explicitToken;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('backend_access_token');
    }

    if (token == null || token.isEmpty) {
      if (kDebugMode) debugPrint('[SocketService] Cannot connect: No access token available');
      return;
    }

    if (_socket != null && _socket!.connected) {
      if (kDebugMode) debugPrint('[SocketService] Already connected');
      return;
    }

    disconnect();

    final serverUrl = ApiConfig.baseUrl;

    try {
      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        if (kDebugMode) debugPrint('[SocketService] Socket connected to $serverUrl');
      });

      _socket!.onDisconnect((reason) {
        _isConnected = false;
        if (kDebugMode) debugPrint('[SocketService] Socket disconnected: $reason');
      });

      _socket!.onConnectError((err) {
        _isConnected = false;
        if (kDebugMode) debugPrint('[SocketService] Socket connect error: $err');
      });

      _socket!.onError((err) {
        if (kDebugMode) debugPrint('[SocketService] Socket error: $err');
      });

      // Server event listeners
      _socket!.on('subscription:updated', (data) {
        if (kDebugMode) debugPrint('[SocketService] Received subscription:updated: $data');
        if (data is Map) {
          _subscriptionUpdateController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('booking:created', (data) {
        if (kDebugMode) debugPrint('[SocketService] Received booking:created: $data');
        if (data is Map) {
          _bookingCreatedController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('booking:updated', (data) {
        if (kDebugMode) debugPrint('[SocketService] Received booking:updated: $data');
        if (data is Map) {
          _bookingUpdatedController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('availability:updated', (data) {
        if (kDebugMode) debugPrint('[SocketService] Received availability:updated: $data');
        if (data is Map) {
          _availabilityUpdatedController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('loyalty:tier:updated', (data) {
        if (kDebugMode) debugPrint('[SocketService] Received loyalty:tier:updated: $data');
        if (data is Map) {
          _loyaltyTierUpdatedController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('loyalty:balance:updated', (data) {
        if (kDebugMode) debugPrint('[SocketService] Received loyalty:balance:updated: $data');
        if (data is Map) {
          _loyaltyBalanceUpdatedController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.on('settlement:updated', (data) {
        if (kDebugMode) debugPrint('[SocketService] Received settlement:updated: $data');
        if (data is Map) {
          _settlementUpdatedController.add(Map<String, dynamic>.from(data));
        }
      });

    } catch (e) {
      if (kDebugMode) debugPrint('[SocketService Exception] $e');
    }
  }

  void joinSalon(String salonId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join:salon', salonId);
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    if (kDebugMode) debugPrint('[SocketService] Disconnected and cleaned up listeners');
  }
}
