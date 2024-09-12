import 'package:auro_stream_signaling/auro_stream_signaling.dart';
import 'package:flutter/material.dart';

class AuroStreamSignalingServices {
  String? username;
  String? roomId;
  String eventName = 'wlcMsg';
  VoidCallback? updateUI;
  BuildContext? context;

  AuroStreamSignalingServices();

  void initUsername({
    required String usernameId,
  }) {
    username = usernameId;
  }

  void initRoomService({
    required String targetRoomId,
    required bool isCreateBoolean,
  }) {
    roomId = targetRoomId;
    if (isCreateBoolean) {
      createRoom();
    } else {
      joinRoom();
    }
  }

  void initUpdateUI({
    required VoidCallback update,
    required BuildContext bContext,
  }) {
    updateUI = update;
    context = bContext;
  }

  /// Functions Implementation

  void connectServer() {
    AuroStreamSignaling.instance.connectServer(
      whenConnect: whenConnect,
      whenConnectError: whenConnectError,
      whenReconnect: whenReconnect,
      whenReconnectError: whenReconnectError,
      whenDisconnect: whenDisconnect,
      whenGetError: whenGetError,
    );
  }

  bool isConnected() {
    return AuroStreamSignaling.instance.isConnected();
  }

  void disconnectServer() {
    return AuroStreamSignaling.instance.disconnectServer();
  }

  void startListeners() {
    if (isConnected()) {
      AuroStreamSignaling.instance
          .onJoinRoomListener(whenJoinedRoom: whenJoinedRoom);
      AuroStreamSignaling.instance
          .onLeaveRoomListener(whenLeftRoom: whenLeftRoom);
      AuroStreamSignaling.instance.onReceiveObjectFromAllListener(
        eventName: eventName,
        whenReceiveObjectFromAll: whenReceiveObjectFromAll,
      );
      AuroStreamSignaling.instance.onReceiveObjectFromRoomListener(
        eventName: eventName,
        whenReceiveObjectFromRoom: whenReceiveObjectFromRoom,
      );
      AuroStreamSignaling.instance.onReceiveObjectFromUserListener(
        eventName: eventName,
        whenReceiveObjectFromUser: whenReceiveObjectFromUser,
      );
    }
  }

  void removeListeners() {
    /// To remove listener should set removeListener true (default false)
    if (isConnected()) {
      AuroStreamSignaling.instance.onJoinRoomListener(
        whenJoinedRoom: whenJoinedRoom,
        removeListener: true,
      );
      AuroStreamSignaling.instance.onLeaveRoomListener(
        whenLeftRoom: whenLeftRoom,
        removeListener: true,
      );
      AuroStreamSignaling.instance.onReceiveObjectFromAllListener(
        eventName: eventName,
        whenReceiveObjectFromAll: whenReceiveObjectFromAll,
        removeListener: true,
      );
      AuroStreamSignaling.instance.onReceiveObjectFromRoomListener(
        eventName: eventName,
        whenReceiveObjectFromRoom: whenReceiveObjectFromRoom,
        removeListener: true,
      );
      AuroStreamSignaling.instance.onReceiveObjectFromUserListener(
        eventName: eventName,
        whenReceiveObjectFromUser: whenReceiveObjectFromUser,
        removeListener: true,
      );
    }
  }

  void createRoom() async {
    AuroStreamSignaling.instance.createRoom(
      roomId: roomId!,
    );
  }

  void deleteRoom() async {
    AuroStreamSignaling.instance.deleteRoom(
      roomId: roomId!,
    );
  }

  void joinRoom() {
    AuroStreamSignaling.instance.joinRoom(
      roomId: roomId!,
      username: username!,
    );
  }

  void leaveRoom() {
    AuroStreamSignaling.instance.leaveRoom(
      roomId: roomId!,
      username: username!,
    );
  }

  void sendObjectTOAll(dynamic object, bool exceptMe) {
    AuroStreamSignaling.instance.sendObjectTOAll(
      eventName: eventName,
      exceptMe: exceptMe,
      object: object,
    );
  }

  void sendObjectTORoom(dynamic object, String roomId, bool exceptMe) {
    AuroStreamSignaling.instance.sendObjectTORoom(
      eventName: eventName,
      roomId: roomId,
      exceptMe: exceptMe,
      object: object,
    );
  }

  void sendObjectTOUser(dynamic object, String userId) {
    AuroStreamSignaling.instance.sendObjectTOUser(
      eventName: eventName,
      userId: userId,
      object: object,
    );
  }

  /// Listeners Implementation

  whenConnect() {
    print('Connected');
    startListeners();
  }

  whenReconnect(data) {
    print('Reconnected: $data');
  }

  whenReconnectError(data) {
    print('Reconnected Error: $data');
  }

  whenConnectError(data) {
    print('Connection error: $data');
  }

  whenDisconnect() {
    print('Disconnected');
  }

  whenGetError(ErrorModel data) {
    print(data.eventName); // Printing the event name for all cases
    switch (data.eventName) {
      case ErrorCases.createRoom:
        print('Handling createRoom');
        handleCreateRoomErrors(data.message); // Specific handler for createRoom
        break;
      case ErrorCases.deleteRoom:
        print('Handling deleteRoom');
        handleDeleteRoomErrors(data.message); // Generic handler used
        break;
      case ErrorCases.joinRoom:
        print('Handling joinRoom');
        handleJoinRoomErrors(data.message); // Generic handler used
        break;
      case ErrorCases.leaveRoom:
        print('Handling leaveRoom');
        handleLeaveRoomErrors(data.message); // Generic handler used
        break;
      case ErrorCases.sendMessageToAll:
        print('Handling sendObjectTOAll');
        handleSendObjectErrors(data.message); // Generic handler used
        break;
      case ErrorCases.sendMessage:
        print('Handling sendObjectTORoom');
        handleSendObjectErrors(data.message); // Generic handler used
        break;
      case ErrorCases.sendMessageToUser:
        print('Handling sendObjectTOUser');
        handleSendObjectErrors(data.message); // Generic handler used
        break;
      default:
        print('Unhandled case: ${data.eventName}');
        break;
    }
  }

  void handleCreateRoomErrors(ErrorMSG message) {
    print('Handling createRoom errors');
    switch (message) {
      case ErrorMSG.invalidCredentials:
        print('Handling invalidCredentials error');
        break;
      case ErrorMSG.encryptionFailed:
        print('Handling encryptionFailed error');
        break;
      default:
        print('Unhandled error message: $message');
        break;
    }
  }

  void handleDeleteRoomErrors(ErrorMSG message) {
    genericErrorHandler(message);
  }

  void handleJoinRoomErrors(ErrorMSG message) {
    genericErrorHandler(message);
  }

  void handleLeaveRoomErrors(ErrorMSG message) {
    genericErrorHandler(message);
  }

  void handleSendObjectErrors(ErrorMSG message) {
    genericErrorHandler(message);
  }

  void genericErrorHandler(ErrorMSG message) {
    print('Handling errors');
    switch (message) {
      case ErrorMSG.invalidCredentials:
        print('Handling invalidCredentials error');
        break;
      case ErrorMSG.authorizationFailed:
        print('Handling authorizationFailed error');
        break;
      case ErrorMSG.encryptionFailed:
        print('Handling encryptionFailed error');
        break;
      case ErrorMSG.roomNotFound:
        print('Handling roomNotFound error');
        break;
      default:
        print('Unhandled error message: $message');
        break;
    }
  }

  whenCreateRoomForME(RoomManagementModel roomManagement) {
    print(roomManagement.toString());
  }

  whenDeleteRoom(RoomManagementModel roomManagement) {
    print(roomManagement.toString());
  }

  whenJoinedRoom(RoomActionModel roomAction) {
    print(roomAction.toString());
    if (updateUI != null) {
      updateUI!();
    }
  }

  whenLeftRoom(RoomActionModel roomAction) {
    print(roomAction.toString());
    if (updateUI != null) {
      updateUI!();
    }
  }

  whenReceiveObjectFromAll(dynamic data) {
    print(data.toString());
    alert(data['object'].toString());
    if (updateUI != null) {
      updateUI!();
    }
  }

  whenReceiveObjectFromRoom(dynamic data) {
    print(data.toString());
    alert(data['object'].toString());
    if (updateUI != null) {
      updateUI!();
    }
  }

  whenReceiveGiftFromLive(dynamic data) {
    print(data.toString());
    alert(data['object'].toString());
    if (updateUI != null) {
      updateUI!();
    }
  }

  whenReceiveObjectFromUser(dynamic data) {
    print(data.toString());
    alert(data['object'].toString());
    if (updateUI != null) {
      updateUI!();
    }
  }

  Future<void> alert(String msg) async {
    return await showDialog(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alarm'),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        );
      },
    );
  }
}

class Object {
  final String sender;
  final String text;

  Object({
    required this.sender,
    required this.text,
  });

  factory Object.fromJson(Map<String, dynamic> json) {
    return Object(
      sender: json['sender'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
    };
  }
}
