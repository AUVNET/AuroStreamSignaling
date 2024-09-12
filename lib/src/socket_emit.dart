import 'socket_service.dart';
import 'crypto.dart';

void _baseEmitter({
  required SignalingService socket,
  required String event,
  required Map<String, dynamic> data,
}) {
  final Map<String, dynamic> encryptedData =
      CryptoUtils.encryptEventsData(data);
  if (encryptedData['success'] == true) {
    final Map<String, dynamic> jsonData = {
      "data": encryptedData['data'],
    };
    socket.emit(event, jsonData);
  } else {
    throw Exception("Failed to encrypt data: ${encryptedData['errorMessage']}");
  }
}

void emitCreateRoom({
  required SignalingService socket,
  required String roomId,
}) {
  final Map<String, dynamic> data = {
    "roomId": roomId,
  };
  _baseEmitter(socket: socket, event: 'create-room', data: data);
}

void emitDeleteRoom({
  required SignalingService socket,
  required String roomId,
}) {
  final Map<String, dynamic> data = {
    "roomId": roomId,
  };
  _baseEmitter(socket: socket, event: 'delete-room', data: data);
}

void emitJoinRoom({
  required SignalingService socket,
  required String roomId,
  required String username,
}) {
  final Map<String, dynamic> data = {
    "roomId": roomId,
    "userName": username,
  };
  _baseEmitter(socket: socket, event: 'join-room', data: data);
}

void emitLeaveRoom({
  required SignalingService socket,
  required String roomId,
  required String username,
}) {
  final Map<String, dynamic> data = {
    "roomId": roomId,
    "userName": username,
  };
  _baseEmitter(socket: socket, event: 'leave-room', data: data);
}

void emitSendObjectTORoom({
  required SignalingService socket,
  required String roomId,
  required String eventName,
  required bool exceptMe,
  required dynamic object,
}) {
  final Map<String, dynamic> data = {
    "roomId": roomId,
    "eventName": eventName,
    "exceptMe": exceptMe,
    "object": object,
  };
  _baseEmitter(socket: socket, event: 'send-message', data: data);
}

void emitSendObjectTOALL({
  required SignalingService socket,
  required String eventName,
  required bool exceptMe,
  required dynamic object,
}) {
  final Map<String, dynamic> data = {
    "eventName": eventName,
    "exceptMe": exceptMe,
    "object": object,
  };
  _baseEmitter(socket: socket, event: 'send-message-to-all', data: data);
}

void emitSendObjectTOUser({
  required SignalingService socket,
  required String userId,
  required String eventName,
  required dynamic object,
}) {
  final Map<String, dynamic> data = {
    "userId": userId,
    "eventName": eventName,
    "object": object,
  };
  _baseEmitter(socket: socket, event: 'send-message-to-user', data: data);
}