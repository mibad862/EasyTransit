class ChatUser {
  final String receiverID;
  final String userName;
  final String userImage;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadMessages; // New field to store the count of unread messages

  ChatUser({
    required this.receiverID,
    required this.userName,
    required this.userImage,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadMessages,
  });
}
