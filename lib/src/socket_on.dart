import 'crypto.dart';
import 'models/models.dart';
import 'socket_service.dart';

void _baseListener({
  required SignalingService socket,
  required String event,
  required Function(dynamic data) handler,
  required bool isRemove,
}) {
  listener(encryptedData) {
    final Map<String, dynamic> decryptedData =
        CryptoUtils.decryptEventsData(encryptedData['data']);
    if (decryptedData['success'] == true) {
      final data = decryptedData['data'];
      handler(data);
    } else {
      throw Exception(
          "Failed to decrypt data: ${decryptedData['errorMessage']}");
    }
  }

  if (isRemove) {
    socket.off(event, listener);
  } else {
    socket.on(event, listener);
  }
}

void onCreateRoom({
  required SignalingService socket,
  required Function(RoomManagementModel data) handler,
  required bool isRemove,
}) {
  listener(data) {
    final roomManagement = RoomManagementModel(
      roomID: data['roomId'],
      userID: data['userID'],
    );
    handler(roomManagement);
  }

  _baseListener(
    socket: socket,
    event: 'room-created',
    handler: listener,
    isRemove: isRemove,
  );
}

void onDeleteRoom({
  required SignalingService socket,
  required Function(RoomManagementModel data) handler,
  required bool isRemove,
}) {
  listener(data) {
    final roomManagement = RoomManagementModel(
      roomID: data['roomId'],
      userID: data['userID'],
    );
    handler(roomManagement);
  }

  _baseListener(
    socket: socket,
    event: 'room-deleted',
    handler: listener,
    isRemove: isRemove,
  );
}

void onJoinRoom({
  required SignalingService socket,
  required Function(RoomActionModel data) handler,
  required bool isRemove,
}) {
  listener(data) {
    final roomAction = RoomActionModel(
      roomID: data['roomId'],
      userID: data['userID'],
      username: data['userName'],
    );
    handler(roomAction);
  }

  _baseListener(
    socket: socket,
    event: 'room-joined',
    handler: listener,
    isRemove: isRemove,
  );
}

void onLeaveRoom({
  required SignalingService socket,
  required Function(RoomActionModel data) handler,
  required bool isRemove,
}) {
  listener(data) {
    final roomAction = RoomActionModel(
      roomID: data['roomId'],
      userID: data['userID'],
      username: data['userName'],
    );
    handler(roomAction);
  }

  _baseListener(
    socket: socket,
    event: 'room-left',
    handler: listener,
    isRemove: isRemove,
  );
}

void onReceiveObjectFromRoom({
  required SignalingService socket,
  required String eventName,
  required Function(dynamic data) handler,
  required bool isRemove,
}) {
  _baseListener(
    socket: socket,
    event: "room-$eventName",
    handler: handler,
    isRemove: isRemove,
  );
}

void onReceiveObjectFromALL({
  required SignalingService socket,
  required String eventName,
  required Function(dynamic data) handler,
  required bool isRemove,
}) {
  _baseListener(
    socket: socket,
    event: "all-$eventName",
    handler: handler,
    isRemove: isRemove,
  );
}

void onReceiveObjectFromUser({
  required SignalingService socket,
  required String eventName,
  required Function(dynamic data) handler,
  required bool isRemove,
}) {
  _baseListener(
    socket: socket,
    event: "private-$eventName",
    handler: handler,
    isRemove: isRemove,
  );
}