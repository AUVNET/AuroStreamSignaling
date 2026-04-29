class RoomActionModel {
  final String roomID;
  final String userID;
  final String username;
  final bool? isDuplicate;

  RoomActionModel({
    required this.roomID,
    required this.userID,
    required this.username,
    this.isDuplicate,
  });

  @override
  String toString() {
    return 'RoomAction(roomID: $roomID, userID: $userID, username: $username, isDuplicate: $isDuplicate)';
  }

  factory RoomActionModel.fromJson(Map<String, dynamic> json) {
    return RoomActionModel(
      roomID: json['roomID'],
      userID: json['userID'],
      username: json['username'],
      isDuplicate: json['isDuplicate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomID': roomID,
      'userID': userID,
      'username': username,
      'isDuplicate': isDuplicate,
    };
  }
}