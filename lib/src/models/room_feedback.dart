class RoomFeedbackModel {
  final String userID;
  final String username;

  RoomFeedbackModel({
    required this.userID,
    required this.username,
  });

  @override
  String toString() {
    return 'RoomFeedback(userID: $userID, username: $username)';
  }

  factory RoomFeedbackModel.fromJson(Map<String, dynamic> json) {
    return RoomFeedbackModel(
      userID: json['userID'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'username': username,
    };
  }
}
