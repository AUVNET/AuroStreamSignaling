
enum ErrorCases {
  createRoom,
  deleteRoom,
  joinRoom,
  leaveRoom,
  sendMessageToAll,
  sendMessage,
  sendMessageToUser,
  none,
}

ErrorCases stringToErrorCases(String inputString) {
  return ErrorCases.values.firstWhere(
        (e) => e.toString().split('.').last == inputString,
    orElse: () => ErrorCases.none,
  );
}

enum ErrorMSG {
  invalidCredentials,
  authorizationFailed,
  encryptionFailed,
  roomNotFound,
  none,
}

ErrorMSG stringToErrorMSG(String inputString) {
  return ErrorMSG.values.firstWhere(
        (e) => e.toString().split('.').last == inputString,
    orElse: () => ErrorMSG.none,
  );
}


/// Reads the optional `roomId` of an `error-message` payload: top level
/// (servers from 2026-10-21) or inside `errorData`. Null for older servers
/// and for errors that are not about one room.
String? errorRoomIdOf(dynamic data) {
  if (data is! Map) return null;
  final dynamic direct = data['roomId'];
  if (direct != null && direct.toString().isNotEmpty) return direct.toString();
  final dynamic nested = data['errorData'];
  if (nested is Map) {
    final dynamic inner = nested['roomId'];
    if (inner != null && inner.toString().isNotEmpty) return inner.toString();
  }
  return null;
}

/// An `error-message` sent by the server for one of this socket's requests.
class ErrorModel {
  final ErrorCases eventName;
  final ErrorMSG message;

  /// The room the failed request was about (join-room / create-room), when
  /// the server says so. Null with older servers.
  final String? roomId;

  ErrorModel({
    required this.eventName,
    required this.message,
    this.roomId,
  });

  @override
  String toString() {
    return 'Error(eventName: $eventName, message: $message, roomId: $roomId)';
  }

  /// Builds the model from a raw `error-message` payload.
  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      eventName: json['eventName'] != null
          ? stringToErrorCases(json['eventName'].toString())
          : ErrorCases.none,
      message: json['message'] != null
          ? stringToErrorMSG(json['message'].toString())
          : ErrorMSG.none,
      roomId: errorRoomIdOf(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName.name,
      'message': message.name,
      'roomId': roomId,
    };
  }
}