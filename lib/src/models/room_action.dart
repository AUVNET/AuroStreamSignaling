class RoomActionModel {
  final String roomID;
  final String userID;
  final String username;

  RoomActionModel({
    required this.roomID,
    required this.userID,
    required this.username,
  });

  @override
  String toString() {
    return 'RoomAction(roomID: $roomID, userID: $userID, username: $username)';
  }

  factory RoomActionModel.fromJson(Map<String, dynamic> json) {
    return RoomActionModel(
      roomID: json['roomID'],
      userID: json['userID'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomID': roomID,
      'userID': userID,
      'username': username,
    };
  }
}