import 'service/socket_io_client.dart' as IO;

import 'models/error_model.dart';

class SignalingService {
  IO.Signaling? _socket;
  final String _port;
  Map<String, Function(dynamic)> listeners = {};

  SignalingService(this._port);

  /// Connect to server
  void connect({
    required String instanceId,
    required String apiKey,
    Function()? whenConnect,
    Function(dynamic data)? whenConnectError,
    Function(dynamic data)? whenReconnect,
    Function(dynamic data)? whenReconnectError,
    Function()? whenDisconnect,
    Function(ErrorModel data)? whenGetError,
  }) {
    try {
      _socket = IO.io('wss://Signaling.AuroStream.com/$_port', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'extraHeaders': {
          'instanceid': instanceId,
          'apikey': apiKey,
        }
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
              eventName: stringToErrorCases(data['eventName']),
              message: stringToErrorMSG(data['message']),
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

  /// Disconnect the socket
  void disconnect() {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Connect to Server First to can use server functions.');
    }
    _socket!.disconnect();
  }

  /// Expose the connection status
  bool get isConnected => _socket?.connected ?? false;

  void restoreListeners() {
    listeners.forEach((event, handler) {
      _socket?.on(event, handler);
    });
  }
}
