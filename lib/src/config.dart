import 'models/models.dart';
import 'socket_emit.dart';
import 'socket_on.dart';
import 'socket_service.dart';

class AuroStreamSignaling {
  static String? _instanceId;
  static String? _apiKey;
  static String? _port;
  static SignalingService? _socketService;
  static AuroStreamSignaling? _instance;

  AuroStreamSignaling._internal();

  static AuroStreamSignaling get instance {
    _instance ??= AuroStreamSignaling._internal();
    return _instance!;
  }

  /// Initialize AuroStream Signaling SDK with your Project details [projectId], [apiKey], and [port]
  static void initialize({
    required String projectId,
    required String apiKey,
    required String port,
  }) {
    if (projectId.isEmpty) {
      throw ArgumentError("ProjectId cannot be empty.");
    }
    if (apiKey.isEmpty) {
      throw ArgumentError("ApiKey cannot be empty.");
    }
    if (port.isEmpty) {
      throw ArgumentError("Port cannot be empty.");
    }
    _instanceId = projectId;
    _apiKey = apiKey;
    _port = port;
  }

  void _mainValidator() {
    if (!isConnected()) return;
    if (_instanceId == null || _instanceId!.isEmpty) {
      throw ArgumentError("AuroStream is not initialized with a instanceId.");
    }
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw ArgumentError("AuroStream is not initialized with a apiKey.");
    }
    if (_port == null || _port!.isEmpty) {
      throw ArgumentError("AuroStream is not initialized with a port.");
    }
    if (_socketService == null) {
      throw ArgumentError("AuroStream is not connected to socket server.");
    }
  }

  void _validator({
    String? roomId,
    String? username,
    String? eventName,
  }) {
    _mainValidator();
    if (roomId != null && roomId.isEmpty) {
      throw ArgumentError("Room ID cannot be empty.");
    }
    if (username != null && username.isEmpty) {
      throw ArgumentError("Username cannot be empty.");
    }
    if (eventName != null && eventName.isEmpty) {
      throw ArgumentError("Event Name cannot be empty.");
    }
  }

  /// Initiates a connection to the server and handles various connection events.
  ///
  /// This function is designed to establish a connection to a server and provide
  /// callbacks for different events that can occur during the lifecycle of this
  /// connection. These events include successful connection, errors during
  /// connection, reconnection attempts, disconnection, and generic errors.
  ///
  /// Parameters:
  /// - `whenConnect`: A callback function that is invoked when a connection to the
  ///   server is successfully established. This function takes no parameters.
  ///
  /// - `whenConnectError`: A callback function that is called when there is an error
  ///   while trying to connect to the server. It receives a dynamic parameter `data`
  ///   that contains information about the error.
  ///
  /// - `whenReconnect`: A callback function that is invoked when a reconnection attempt
  ///   is made after losing the connection. It receives a dynamic parameter `data`
  ///   that can contain information related to the reconnection attempt.
  ///
  /// - `whenReconnectError`: Similar to `whenConnectError`, but specifically for
  ///   errors that occur during reconnection attempts. It also receives a dynamic
  ///   parameter `data` with error details.
  ///
  /// - `whenDisconnect`: A callback function that is called when the connection to the
  ///   server is intentionally closed. This function takes no parameters.
  ///
  /// - `whenGetError`: A callback function for handling generic errors that can occur
  ///   with server functions. It receives a dynamic parameter `data`
  ///   with error details.
  void connectServer({
    Function()? whenConnect,
    Function(dynamic data)? whenConnectError,
    Function(dynamic data)? whenReconnect,
    Function(dynamic data)? whenReconnectError,
    Function()? whenDisconnect,
    Function(ErrorModel data)? whenGetError,
  }) {
    if (_instanceId == null || _instanceId!.isEmpty) {
      throw ArgumentError("AuroStream is not initialized with a instanceId.");
    }
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw ArgumentError("AuroStream is not initialized with a apiKey.");
    }
    if (_port == null || _port!.isEmpty) {
      throw ArgumentError("AuroStream is not initialized with a port.");
    }
    _socketService = SignalingService(_port!);
    _socketService?.connect(
      instanceId: _instanceId!,
      apiKey: _apiKey!,
      whenConnect: whenConnect,
      whenConnectError: whenConnectError,
      whenReconnect: whenReconnect,
      whenReconnectError: whenReconnectError,
      whenDisconnect: whenDisconnect,
      whenGetError: whenGetError,
    );
  }

  /// Check if server connected
  bool isConnected() {
    return _socketService?.isConnected ?? false;
  }

  /// Disconnect server connection
  void disconnectServer() {
    _mainValidator();
    _socketService!.disconnect();
  }

  void onCreateRoomListenerForME({
    required Function(RoomManagementModel roomManagement) whenMECreateRoom,
    bool removeListener = false,
  }) {
    _mainValidator();
    onCreateRoom(
      socket: _socketService!,
      handler: whenMECreateRoom,
      isRemove: removeListener,
    );
  }

  void onDeleteRoomListener({
    required Function(RoomManagementModel roomManagement) whenDeleteRoom,
    bool removeListener = false,
  }) {
    _mainValidator();
    onDeleteRoom(
      socket: _socketService!,
      handler: whenDeleteRoom,
      isRemove: removeListener,
    );
  }

  /// Sets up a listener for tracking when any user joins a chat room.
  ///
  /// Within the real-time chat service package, this function is essential for
  /// enabling dynamic and interactive chat environments. It listens for events
  /// signaling that a user has joined a chat room, facilitating real-time updates
  /// to room participants and supporting features like user count updates, welcome
  /// messages, or activity logs.
  ///
  /// This functionality enhances the chat app's user experience by making chat rooms
  /// feel more alive and responsive. It allows for immediate feedback when new users
  /// join a room, which is crucial for collaborative and social features of the app.
  ///
  /// Parameter:
  /// - `whenJoinedRoom`: A required callback function that is executed whenever a new
  ///   user joins a room. It takes dynamic data about the event, enabling the app to
  ///   respond appropriately, such as updating the UI or notifying existing users.
  /// - `removeListener` (optional): A boolean value that, when set to true, instructs the function to
  ///   remove the set `whenStoppedTyping` listener. This is useful for cleaning up listeners
  ///   when they are no longer needed, such as when a user leaves a chat room or the application
  ///   wants to reduce the number of active listeners. The default value is false, indicating that
  ///   the listener should be set up rather than removed.
  void onJoinRoomListener({
    required Function(RoomActionModel roomManagement) whenJoinedRoom,
    bool removeListener = false,
  }) {
    onJoinRoom(
      socket: _socketService!,
      handler: whenJoinedRoom,
      isRemove: removeListener,
    );
  }

  /// Sets up or removes a listener for tracking when a user leaves a chat room.
  ///
  /// This function is an integral part of the chat application's real-time service
  /// package, designed to monitor and react to events when users exit a chat room.
  /// It's pivotal for supporting features that require real-time updates to the
  /// participant list, such as adjusting the user count, removing users from the
  /// chat UI, or triggering notifications about the change in room occupancy.
  ///
  /// The ability to detect and respond to a user leaving a room enhances the
  /// application's interactivity and ensures that the chat environment remains
  /// dynamic and current. It aids in creating a more engaging and informed user
  /// experience by keeping participants aware of the presence and availability
  /// of their peers.
  ///
  /// Parameter:
  /// - `whenLeftRoom`: A required callback function that is invoked when a user
  ///   leaves a room. It receives dynamic data about the event, enabling the
  ///   application to perform necessary updates or actions in response, such as
  ///   displaying a message that a user has exited or updating the room's user list.
  /// - `removeListener` (optional): A boolean value that, when set to true, instructs the function to
  ///   remove the set `whenStoppedTyping` listener. This is useful for cleaning up listeners
  ///   when they are no longer needed, such as when a user leaves a chat room or the application
  ///   wants to reduce the number of active listeners. The default value is false, indicating that
  ///   the listener should be set up rather than removed.
  void onLeaveRoomListener({
    required Function(RoomActionModel roomManagement) whenLeftRoom,
    bool removeListener = false,
  }) {
    onLeaveRoom(
      socket: _socketService!,
      handler: whenLeftRoom,
      isRemove: removeListener,
    );
  }

  void onReceiveObjectFromRoomListener({
    required String eventName,
    required Function(dynamic data) whenReceiveObjectFromRoom,
    bool removeListener = false,
  }) {
    onReceiveObjectFromRoom(
      socket: _socketService!,
      eventName: eventName,
      handler: whenReceiveObjectFromRoom,
      isRemove: removeListener,
    );
  }

  void onReceiveObjectFromAllListener({
    required String eventName,
    required Function(dynamic data) whenReceiveObjectFromAll,
    bool removeListener = false,
  }) {
    onReceiveObjectFromALL(
      socket: _socketService!,
      eventName: eventName,
      handler: whenReceiveObjectFromAll,
      isRemove: removeListener,
    );
  }

  void onReceiveObjectFromUserListener({
    required String eventName,
    required Function(dynamic data) whenReceiveObjectFromUser,
    bool removeListener = false,
  }) {
    onReceiveObjectFromUser(
      socket: _socketService!,
      eventName: eventName,
      handler: whenReceiveObjectFromUser,
      isRemove: removeListener,
    );
  }

  /// Creates a new chat room with the specified [roomId].
  ///
  /// This streamlined function is essential for initiating new chat spaces within the application,
  /// allowing users to engage in conversations within specifically identified rooms. The uniqueness
  /// of the [roomId] is paramount to ensure each chat room is distinct and can be accurately
  /// referenced and accessed across the chat application.
  ///
  /// Parameter:
  /// - `roomId`: A unique String identifier for the new chat room. This ID is crucial for the room's
  ///   identification, ensuring messages and participants are correctly associated with the correct
  ///   chat space.
  void createRoom({
    required String roomId,
  }) {
    _mainValidator();
    if (roomId.isEmpty) {
      throw ArgumentError("Room ID cannot be empty.");
    }
    emitCreateRoom(
      socket: _socketService!,
      roomId: roomId,
    );
  }

  /// Deletes an existing chat room identified by [roomId].
  ///
  /// This function is key to managing the lifecycle of chat rooms within the application,
  /// allowing for the removal of rooms that are no longer active or needed. By specifying
  /// the [roomId], this operation ensures that the targeted chat space is accurately identified
  /// and removed, along with any associated data such as messages or participant lists.
  ///
  /// Parameter:
  /// - `roomId`: The unique String identifier for the chat room to be deleted. This ID ensures
  ///   that the correct room is targeted for deletion, maintaining the integrity of the chat
  ///   application's room management.
  void deleteRoom({
    required String roomId,
  }) {
    _mainValidator();
    if (roomId.isEmpty) {
      throw ArgumentError("Room ID cannot be empty.");
    }
    emitDeleteRoom(
      socket: _socketService!,
      roomId: roomId,
    );
  }

  /// Joins a user to a chat room identified by [roomId].
  ///
  /// This function facilitates the addition of a user to a specific chat room, enabling them to participate
  /// in conversations and receive messages in real time. The [roomId] identifies the target chat room,
  /// while the [username] uniquely identifies the user joining the room. This operation is essential for
  /// user interaction within the chat application, allowing for dynamic participation in various chat rooms.
  ///
  /// Parameters:
  /// - `roomId`: The unique String identifier for the chat room the user wishes to join. This ID ensures
  ///   that messages are directed to the correct conversation space.
  /// - `username`: The unique String representing the user joining the room. This could be a username or
  ///   any unique identifier associated with the user, facilitating user tracking and message attribution
  ///   within the room.
  void joinRoom({
    required String roomId,
    required String username,
  }) {
    _validator(
      roomId: roomId,
      username: username,
    );
    emitJoinRoom(
      socket: _socketService!,
      roomId: roomId,
      username: username,
    );
  }

  /// Removes a user from a chat room identified by [roomId].
  ///
  /// This function allows a user to exit a chat room, ceasing their participation in that room's conversations.
  /// It requires the [roomId] to specify which room the user intends to leave and the [username] to identify
  /// the departing user. This operation is crucial for managing user presence and ensuring that users can
  /// freely navigate between different chat spaces within the application.
  ///
  /// Parameters:
  /// - `roomId`: The unique String identifier for the chat room from which the user is leaving. This ensures
  ///   the correct room is updated upon the user's departure.
  /// - `username`: The unique String representing the user leaving the room. This could be a username or
  ///   any unique identifier for the user, used to remove the correct user from the room's participant list.
  void leaveRoom({
    required String roomId,
    required String username,
  }) {
    _validator(
      roomId: roomId,
      username: username,
    );
    emitLeaveRoom(
      socket: _socketService!,
      roomId: roomId,
      username: username,
    );
  }

  void sendObjectTORoom({
    required String roomId,
    required String eventName,
    required bool exceptMe,
    required dynamic object,
  }) {
    _validator(
      roomId: roomId,
      eventName: eventName,
    );
    emitSendObjectTORoom(
      socket: _socketService!,
      roomId: roomId,
      eventName: eventName,
      exceptMe: exceptMe,
      object: object,
    );
  }

  void sendObjectTOAll({
    required String eventName,
    required bool exceptMe,
    required dynamic object,
  }) {
    _validator(
      eventName: eventName,
    );
    emitSendObjectTOALL(
      socket: _socketService!,
      eventName: eventName,
      exceptMe: exceptMe,
      object: object,
    );
  }

  void sendObjectTOUser({
    required String userId,
    required String eventName,
    required dynamic object,
  }) {
    _validator(
      username: userId,
      eventName: eventName,
    );
    emitSendObjectTOUser(
      socket: _socketService!,
      userId: userId,
      eventName: eventName,
      object: object,
    );
  }
}
