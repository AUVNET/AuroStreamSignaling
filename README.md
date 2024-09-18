
# AuroStream Signaling SDK

**AuroStream Signaling** is a real-time signaling SDK built to enable seamless real-time communication between clients, facilitating event-driven architecture using WebSockets. This SDK can handle room creation, messaging, user management, and event-driven actions across various platforms.

## Features

- **Real-time Communication**: Supports real-time event-based communication using WebSockets.
- **Room Management**: Easily create, join, and delete rooms.
- **Event-based Signaling**: Send and receive custom events or objects to/from users or rooms.
- **User Presence Detection**: Track when users join or leave rooms.
- **Error Handling**: Provides comprehensive error handling and callback mechanisms for connection issues.
- **Customizable Callbacks**: Flexible callbacks for different events such as user joining, room creation, and error handling.

## Installation

To get started with **AuroStream Signaling**, add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  auro_stream_signaling: ^0.0.1
```

Then, run the following command in your terminal:

```bash
dart pub get
```

## Usage

### 1. Initialize the SDK

Before using the SDK, you need to initialize it with your project credentials (`projectId`, `apiKey`, and `port`):

```dart
import 'package:auro_stream_signaling/auro_stream_signaling.dart';

void main() {
  AuroStreamSignaling.initialize(
    projectId: 'your_project_id',
    apiKey: 'your_api_key',
    port: 'your_port',
  );
}
```

### 2. Connecting to the Server

Once initialized, you can connect to the server:

```dart
AuroStreamSignaling.instance.connectServer(
  whenConnect: () {
    print('Connected to the signaling server.');
  },
  whenConnectError: (error) {
    print('Connection error: $error');
  },
  whenReconnect: (data) {
    print('Reconnected successfully.');
  },
  whenReconnectError: (error) {
    print('Reconnection failed: $error');
  },
  whenDisconnect: () {
    print('Disconnected from the server.');
  },
);
```

### 3. Creating and Managing Rooms

#### Create a Room

```dart
AuroStreamSignaling.instance.createRoom(roomId: 'my_room');
```

#### Join a Room

```dart
AuroStreamSignaling.instance.joinRoom(
  roomId: 'my_room',
  username: 'user1',
);
```

#### Leave a Room

```dart
AuroStreamSignaling.instance.leaveRoom(
  roomId: 'my_room',
  username: 'user1',
);
```

### 4. Sending and Receiving Events

#### Send a Custom Event to a Room

```dart
AuroStreamSignaling.instance.sendObjectTORoom(
  roomId: 'my_room',
  eventName: 'custom_event',
  object: {'message': 'Hello, World!'},
  exceptMe: false,
);
```

#### Send a Custom Event to All Users

```dart
AuroStreamSignaling.instance.sendObjectTOAll(
  eventName: 'broadcast_event',
  object: {'message': 'Broadcast message'},
  exceptMe: false,
);
```

#### Send a Custom Event to a Specific User

```dart
AuroStreamSignaling.instance.sendObjectTOUser(
  userId: 'user123',
  eventName: 'private_message',
  object: {'message': 'Hello, User!'},
);
```

#### Receive Events from a Room

To listen for custom events from a room:

```dart
AuroStreamSignaling.instance.onReceiveObjectFromRoomListener(
  eventName: 'custom_event',
  whenReceiveObjectFromRoom: (data) {
    print('Event received from room: $data');
  },
);
```

### 5. Error Handling

Listen for errors during operations:

```dart
AuroStreamSignaling.instance.connectServer(
  whenGetError: (error) {
    print('An error occurred: $error');
  },
);
```

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/aurostream/auro_stream_signaling/LICENSE) file for more details.
