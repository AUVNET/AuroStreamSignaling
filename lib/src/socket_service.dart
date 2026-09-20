import 'service/socket_io_client.dart' as IO;

import 'models/error_model.dart';

class SignalingService {
  IO.Signaling? _socket;
  final String _port;
  Map<String, Function(dynamic)> listeners = {};

  SignalingService(this._port);

  /// Handshake headers, kept so a refreshed user token is used by the next
  /// (re)connection without rebuilding the socket.
  final Map<String, dynamic> _headers = {};

  /// Sets / clears the end-user token sent as `x-aurostream-token`.
  void setUserToken(String? userToken) {
    if (userToken == null || userToken.isEmpty) {
      _headers.remove('x-aurostream-token');
    } else {
      _headers['x-aurostream-token'] = userToken;
    }
  }

  /// Connect to server
  void connect({
    required String instanceId,
    required String apiKey,
    String? userToken,
    Function()? whenConnect,
    Function(dynamic data)? whenConnectError,
    Function(dynamic data)? whenReconnect,
    Function(dynamic data)? whenReconnectError,
    Function()? whenDisconnect,
    Function(ErrorModel data)? whenGetError,
  }) {
    try {
      _headers
        ..clear()
        ..['instanceid'] = instanceId
        ..['apikey'] = apiKey;
      setUserToken(userToken);
      _socket = IO.io('wss://Signaling.AuroStream.com/$_port', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'extraHeaders': _headers,
        // ── Reconnection ─────────────────────────────────────────────────────
        // Without these, socket_io_client's defaults apply:
        // reconnectionDelay 1s backing off to reconnectionDelayMax, which
        // defaults to **5 s** — so after a few attempts the client retries
        // every 5 seconds forever. On Android that is exactly what happens
        // while the app is backgrounded and the OS has cut its network: a real
        // 14-minute session logged 197 `Failed host lookup` errors, arriving on
        // the dot every 5 s from the chat and signaling sockets. (The live
        // socket, which already set these options with a 10 s cap, produced
        // visibly fewer: 48 versus 66 each for chat and signaling.)
        //
        // A longer cap plus jitter keeps a genuine outage from turning into a
        // radio-waking retry storm, while still reconnecting promptly after a
        // brief drop.
        'reconnection': true,
        'reconnectionAttempts': double.infinity,
        'reconnectionDelay': 1000, // 1 s before the first retry
        'reconnectionDelayMax': 30000, // ...backing off to 30 s, not 5 s
        'randomizationFactor': 0.5, // jitter, so clients don't sync up
        // Give the OS time to wake the network stack when the connection is
        // attempted right after the app returns to the foreground.
        'timeout': 20000,
      })
        ..onConnect((_) {
          if (whenConnect != null) {
            whenConnect();
          }
        })
        ..onConnectError((data) {
          if (whenConnectError != null) {
            whenConnectError(data);
          }
        })
        ..onDisconnect((_) {
          if (whenDisconnect != null) {
            whenDisconnect();
          }
        })..onReconnect((data) {
          restoreListeners();
          if (whenReconnect != null) {
            whenReconnect(data);
          }
        })..onReconnectError((data) {
          if (whenReconnectError != null) {
            whenReconnectError(data);
          }
        })
        ..on('error-message', (data) {
          if (whenGetError != null) {
            final error = ErrorModel(
              eventName: data['eventName'] != null
                  ? stringToErrorCases(data['eventName'])
                  : ErrorCases.none,
              message: data['message'] != null
                  ? stringToErrorMSG(data['message'])
                  : ErrorMSG.none,
            );
            whenGetError(error);
          }
        });

      _socket!.connect();
    } catch (error) {
      throw Exception('Failed to Connect Server: ${error.toString()}');
    }
  }

  /// Emit events with data
  void emit(String event, [dynamic data]) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Connect to Server First to can use server functions.');
    }
    _socket!.emit(event, data);
  }

  /// Subscribe to events
  void on(String event, Function(dynamic) handler) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Connect to Server First to use server functions.');
    }
    // First, remove any existing listeners for this event to prevent duplicate handlers
    _socket!.off(event);
    // Then, subscribe the new handler
    _socket!.on(event, handler);
    // Save or update the handler in the listeners map
    listeners[event] = handler;
  }

  /// Unsubscribe from events
  void off(String event, [Function(dynamic)? handler]) {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Connect to Server First to use server functions.');
    }
    if (handler != null) {
      // If a specific handler is provided, remove only that handler for the event
      _socket!.off(event, handler);
      // Check if the handler being removed is the one stored in the map
      if (listeners[event] == handler) {
        listeners.remove(event); // Remove from map if it matches
      }
    } else {
      // If no handler is provided, remove all listeners for that event
      _socket!.off(event);
      // Also remove from the map as all listeners are removed
      listeners.remove(event);
    }
  }

  /// Disconnect the socket and stop any reconnection attempts.
  ///
  /// This used to throw when the socket was not currently connected — which is
  /// precisely the state it is in while stuck in a reconnect loop, so there was
  /// **no way to stop a retrying socket**. Callers that tried (e.g. suspending
  /// sockets when the app is backgrounded) had their call turned into an
  /// exception and the retry storm carried on regardless.
  ///
  /// Disconnecting is now idempotent and always safe: it stops reconnection,
  /// closes the socket if it is open, and releases its listeners. A later
  /// `connect()` builds a fresh socket, so disposing here is safe.
  void disconnect() {
    final s = _socket;
    if (s == null) return;
    try {
      s.disconnect();
    } catch (_) {}
    try {
      s.dispose();
    } catch (_) {}
    _socket = null;
  }

  /// Expose the connection status
  bool get isConnected => _socket?.connected ?? false;

  void restoreListeners() {
    listeners.forEach((event, handler) {
      _socket?.on(event, handler);
    });
  }
}
