
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


class ErrorModel {
  final ErrorCases eventName;
  final ErrorMSG message;

  ErrorModel({
    required this.eventName,
    required this.message,
  });

  @override
  String toString() {
    return 'Error(eventName: $eventName, message: $message)';
  }

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      eventName: json['eventName'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'message': message,
    };
  }
}