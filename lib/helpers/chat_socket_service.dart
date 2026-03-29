import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_constants.dart';

enum ChatSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class ChatSocketEvent {
  final String action;
  final dynamic data;
  final String? requestId;
  final String? message;
  final Map<String, dynamic> raw;

  const ChatSocketEvent({
    required this.action,
    this.data,
    this.requestId,
    this.message,
    required this.raw,
  });
}

class ChatSocketException implements Exception {
  final String message;

  const ChatSocketException(this.message);

  @override
  String toString() => 'ChatSocketException($message)';
}

class ChatSocketService extends GetxService {
  ChatSocketService({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;
  final Uuid _uuid = const Uuid();
  final StreamController<ChatSocketEvent> _eventController =
      StreamController<ChatSocketEvent>.broadcast();

  final Rx<ChatSocketConnectionState> connectionState =
      ChatSocketConnectionState.disconnected.obs;
  final RxnString lastError = RxnString();

  final Map<String, Completer<dynamic>> _pendingRequests =
      <String, Completer<dynamic>>{};

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;
  DateTime? _realtimeDisabledUntil;
  DateTime? _connectedAt;

  Stream<ChatSocketEvent> get events => _eventController.stream;

  bool get isConnected =>
      connectionState.value == ChatSocketConnectionState.connected &&
      _socket != null;

  Future<void> connect({bool force = false}) async {
    if (_realtimeDisabledUntil != null &&
        DateTime.now().isBefore(_realtimeDisabledUntil!)) {
      throw ChatSocketException(
        'Realtime chat temporarily unavailable on this server',
      );
    }

    if (!force &&
        (connectionState.value == ChatSocketConnectionState.connected ||
            connectionState.value == ChatSocketConnectionState.connecting ||
            connectionState.value == ChatSocketConnectionState.reconnecting)) {
      return;
    }

    final token = sharedPreferences.getString(AppConstants.authToken) ?? '';
    if (token.trim().isEmpty) {
      throw const ChatSocketException(
        'Missing auth token for chat websocket connection',
      );
    }

    _manualDisconnect = false;
    _reconnectTimer?.cancel();

    if (force) {
      await _disposeSocket();
    }

    final wasConnectedBefore = _reconnectAttempts > 0;
    connectionState.value =
        wasConnectedBefore
            ? ChatSocketConnectionState.reconnecting
            : ChatSocketConnectionState.connecting;

    final socketUris = _buildSocketUris(token);
    Object? lastConnectError;
    StackTrace? lastConnectStackTrace;
    String? handshakeFailureCode;

    for (final uri in socketUris) {
      _log('connect.start', {'url': '${uri.scheme}://${uri.host}${uri.path}'});

      try {
        final socket = await WebSocket.connect(
          uri.toString(),
          headers: <String, dynamic>{'Authorization': 'Bearer $token'},
          compression: CompressionOptions.compressionOff,
        );

        _socket = socket;
        _connectedAt = DateTime.now();
        _socketSubscription = socket.listen(
          _handleIncomingMessage,
          onError: _handleSocketError,
          onDone: _handleSocketDone,
          cancelOnError: true,
        );

        _reconnectAttempts = 0;
        connectionState.value = ChatSocketConnectionState.connected;
        lastError.value = null;
        _startHeartbeat();
        _log('connect.success', {
          'url': '${uri.scheme}://${uri.host}${uri.path}',
        });
        return;
      } catch (error, stackTrace) {
        lastConnectError = error;
        lastConnectStackTrace = stackTrace;
        final errorText = error.toString().toLowerCase();
        if (errorText.contains('was not upgraded to websocket')) {
          if (errorText.contains('404')) {
            handshakeFailureCode = '404';
          } else if (errorText.contains('426')) {
            handshakeFailureCode = '426';
          }
        }
        _log('connect.failure', {
          'url': '${uri.scheme}://${uri.host}${uri.path}',
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        });
      }
    }

    lastError.value = lastConnectError?.toString();
    connectionState.value = ChatSocketConnectionState.disconnected;

    if (handshakeFailureCode != null) {
      _realtimeDisabledUntil = DateTime.now().add(const Duration(minutes: 10));
      _log('realtime.disabled', {
        'reason': 'websocket_upgrade_$handshakeFailureCode',
        'retryAfter': _realtimeDisabledUntil!.toIso8601String(),
      });
    } else {
      _scheduleReconnect();
    }

    if (lastConnectError != null && lastConnectStackTrace != null) {
      Error.throwWithStackTrace(lastConnectError, lastConnectStackTrace);
    }

    throw const ChatSocketException(
      'Unable to establish chat websocket connection',
    );
  }

  Future<dynamic> sendRequest(
    String action, {
    Map<String, dynamic>? data,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (!isConnected) {
      await connect();
    }

    final socket = _socket;
    if (socket == null || !isConnected) {
      throw const ChatSocketException('Chat websocket is not connected');
    }

    final requestId = _uuid.v4();
    final completer = Completer<dynamic>();
    _pendingRequests[requestId] = completer;

    final payload = <String, dynamic>{
      'action': action,
      'requestId': requestId,
      'data': data ?? <String, dynamic>{},
    };

    _log('request', {
      'action': action,
      'requestId': requestId,
      'data': data ?? {},
    });

    try {
      socket.add(jsonEncode(payload));
      final response = await completer.future.timeout(timeout);
      return response;
    } on TimeoutException {
      throw ChatSocketException('Timed out waiting for $action response');
    } finally {
      _pendingRequests.remove(requestId);
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    connectionState.value = ChatSocketConnectionState.disconnected;
    await _disposeSocket();
  }

  @override
  void onClose() {
    _eventController.close();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _disposeSocket();
    super.onClose();
  }

  List<Uri> _buildSocketUris(String token) {
    final baseUri = Uri.parse(AppConstants.BASE_URL);
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final socketPaths = <String>['/ws/chat'];

    return socketPaths.map((path) {
      if (baseUri.hasPort && baseUri.port > 0) {
        return Uri(
          scheme: scheme,
          host: baseUri.host,
          port: baseUri.port,
          path: path,
          queryParameters: <String, String>{'token': token},
        );
      }

      return Uri(
        scheme: scheme,
        host: baseUri.host,
        path: path,
        queryParameters: <String, String>{'token': token},
      );
    }).toList();
  }

  void _handleIncomingMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw.toString());
      if (decoded is! Map) {
        _log('message.ignored', {'raw': raw.toString()});
        return;
      }

      final payload = Map<String, dynamic>.from(decoded);
      final action = payload['action']?.toString() ?? 'unknown';
      final requestId = payload['requestId']?.toString();
      final message = payload['message']?.toString();
      final data = payload['data'];

      _log('event', {
        'action': action,
        'requestId': requestId,
        'message': message,
      });

      if (requestId != null && _pendingRequests.containsKey(requestId)) {
        final completer = _pendingRequests[requestId]!;
        if (!completer.isCompleted) {
          if (action == 'error') {
            completer.completeError(
              ChatSocketException(message ?? 'Socket request failed'),
            );
          } else {
            completer.complete(data);
          }
        }
      }

      _eventController.add(
        ChatSocketEvent(
          action: action,
          data: data,
          requestId: requestId,
          message: message,
          raw: payload,
        ),
      );
    } catch (error, stackTrace) {
      _log('message.parse.failure', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'raw': raw.toString(),
      });
    }
  }

  void _handleSocketError(Object error) {
    _heartbeatTimer?.cancel();
    lastError.value = error.toString();
    connectionState.value = ChatSocketConnectionState.disconnected;
    _failPendingRequests(error);
    _log('socket.error', {'error': error.toString()});
    _scheduleReconnect();
  }

  void _handleSocketDone() {
    final connectedForMs =
        _connectedAt == null
            ? null
            : DateTime.now().difference(_connectedAt!).inMilliseconds;
    final closeCode = _socket?.closeCode;
    _heartbeatTimer?.cancel();
    connectionState.value = ChatSocketConnectionState.disconnected;
    _failPendingRequests(
      const ChatSocketException('Chat websocket connection closed'),
    );
    _log('socket.done', {
      'closeCode': closeCode,
      'closeReason': _socket?.closeReason,
      'connectedForMs': connectedForMs,
    });
    if (closeCode == 1002) {
      lastError.value =
          'Chat websocket closed with protocol error (1002). This usually points to proxy/control-frame handling on the server path.';
    }
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      final socket = _socket;
      if (socket == null || !isConnected) {
        return;
      }

      try {
        socket.add(
          jsonEncode(<String, dynamic>{
            'action': 'ping',
            'data': <String, dynamic>{
              'sentAt': DateTime.now().toIso8601String(),
            },
          }),
        );
      } catch (error) {
        _log('heartbeat.failure', {'error': error.toString()});
      }
    });
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) {
      return;
    }
    if (_realtimeDisabledUntil != null &&
        DateTime.now().isBefore(_realtimeDisabledUntil!)) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts += 1;

    final delaySeconds =
        _reconnectAttempts < 2
            ? 2
            : _reconnectAttempts < 4
            ? 5
            : 10;

    _log('reconnect.scheduled', {'delaySeconds': delaySeconds});

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      try {
        await connect(force: true);
      } catch (_) {
        // A failing reconnect already schedules the next retry.
      }
    });
  }

  void _failPendingRequests(Object error) {
    final failure =
        error is ChatSocketException
            ? error
            : ChatSocketException(error.toString());

    for (final entry in _pendingRequests.entries) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(failure);
      }
    }
    _pendingRequests.clear();
  }

  Future<void> _disposeSocket() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _connectedAt = null;

    final socket = _socket;
    _socket = null;
    if (socket != null) {
      await socket.close();
    }
  }

  void _log(String event, [Map<String, dynamic>? payload]) {
    debugPrint(
      '[CHAT_WS] $event ${payload == null ? '' : jsonEncode(payload)}',
    );
  }
}
