
enum ErrorCases {
  createRoom,
  deleteRoom,
  joinRoom,
  leaveRoom,
  sendMessageToAll,
  sendMessage,
  sendMessageToUser,
}

ErrorCases stringToErrorCases(String inputString) {
  return ErrorCases.values.firstWhere(
        (e) => e.toString().split('.').last == inputString,
    orElse: () {
      // Optionally, handle the case where the string does not match any enum value.
      throw ArgumentError('Unknown ErrorCases value: $inputString');
    },
  );
}

enum ErrorMSG {
  invalidCredentials,
  authorizationFailed,
  encryptionFailed,
  roomNotFound,
}

ErrorMSG stringToErrorMSG(String inputString) {
  return ErrorMSG.values.firstWhere(
        (e) => e.toString().split('.').last == inputString,
    orElse: () {
      throw ArgumentError('Unknown ErrorMSG value: $inputString');
    },
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