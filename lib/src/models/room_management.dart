class RoomManagementModel {
  final String roomID;
  final String userID;

  RoomManagementModel({
    required this.roomID,
    required this.userID,
  });

  @override
  String toString() {
    return 'RoomManagement(roomID: $roomID, userID: $userID)';
  }

  factory RoomManagementModel.fromJson(Map<String, dynamic> json) {
    return RoomManagementModel(
      roomID: json['roomID'],
      userID: json['userID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomID': roomID,
      'userID': userID,
    };
  }
}