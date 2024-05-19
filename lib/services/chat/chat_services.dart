import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../views/chat_screen/ChatDetailPage.dart';
import '../../views/chat_screen/model/chat_user_model.dart';



class ChatServices extends ChangeNotifier {
  late SharedPreferences prefs;
  String? userID;
  String? currentUserName;
  String? currentUserImage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatServices() {
    init();
  }

  Stream<String?> getUserIDStream() {
    return Stream.fromFuture(Future.value(userID));
  }

  Future<void> init() async {
    await initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();

    userID = prefs.getString('userid');
    currentUserName = prefs.getString('userName');
    currentUserImage = prefs.getString('userImage');
    print(userID);
    notifyListeners();
  }

  Stream<List<ChatMessage>> getMessageStream(
      String senderID, String receiverID, BuildContext context) {
    String chatRoomID = constructChatRoomID(senderID, receiverID);
    return _firestore
        .collection('messages')
        .doc(chatRoomID)
        .collection('chats')
        .orderBy('timestamp')
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatMessage> messages = [];
      for (final doc in snapshot.docs) {
        final messageType = doc['messageType'] as String?;
        late ChatMessage message;

        DateTime? timestamp = doc['timestamp'] != null
            ? (doc['timestamp'] as Timestamp).toDate()
            : null;

        if (messageType == 'image') {
          message = ChatMessage(
            senderID: doc['senderID'], // Add senderID to the ChatMessage
            messageType: messageType,
            messageImagePath: doc['messageImagePath'],
            isSeen: doc['isSeen'],
            timestamp: timestamp,
          );
        } else if (messageType == 'document') {
          message = ChatMessage(
            senderID: doc['senderID'], // Add senderID to the ChatMessage
            messageType: messageType,
            messageDocumentPath: doc['messageDocumentPath'],
            isSeen: doc['isSeen'],
            timestamp: timestamp,
          );
        } else {
          message = ChatMessage(
            senderID: doc['senderID'], // Add senderID to the ChatMessage
            messageContent: doc['messageContent'],
            messageType: 'text',
            isSeen: doc['isSeen'],
            timestamp: timestamp,
          );
        }

        messages.add(message);

        if (message.senderID != senderID && !message.isSeen!) {
          // If message is from the sender and not seen, mark it as seen
          await markMessageAsSeen(doc.id, senderID, receiverID, context);
          // Update the isSeen value in the message object as well
          message.isSeen = true;
        }
      }
      return messages;
    });
  }

  Future<void> markMessageAsSeen(String messageId, String senderID,
      String receiverID, BuildContext context) async {
    try {
      String chatRoomID = constructChatRoomID(senderID, receiverID);
      CollectionReference chatsCollection =
          _firestore.collection('messages').doc(chatRoomID).collection('chats');
      await chatsCollection.doc(messageId).update({'isSeen': true});
    } catch (error) {

      print('Error marking message as seen: $error');
      throw error;
    }
  }

  Stream<List<ChatMessage>> fetchMessagesBetweenUsers(
      String senderID, String receiverID, BuildContext context) {
    try {
      String chatRoomID = constructChatRoomID(senderID, receiverID);

      return _firestore
          .collection('messages')
          .doc(chatRoomID)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((querySnapshot) {
        List<ChatMessage> messages = querySnapshot.docs.map((doc) {
          final messageType = doc['messageType'] as String?;
          late ChatMessage message;

          DateTime? timestamp = doc['timestamp'] != null
              ? (doc['timestamp'] as Timestamp).toDate()
              : null;

          if (messageType == 'image') {
            message = ChatMessage(
              senderID: doc['senderID'], // Add senderID to the ChatMessage

              messageType: messageType,
              messageImagePath: doc['messageImagePath'],
              isSeen: doc['isSeen'],
              timestamp: timestamp,
            );
          } else if (messageType == 'document') {
            message = ChatMessage(
              senderID: doc['senderID'], // Add senderID to the ChatMessage

              messageType: messageType,
              messageDocumentPath: doc['messageDocumentPath'],
              isSeen: doc['isSeen'],
              timestamp: timestamp,
            );
          } else {
            message = ChatMessage(
              senderID: doc['senderID'], // Add senderID to the ChatMessage

              messageContent: doc['messageContent'],
              messageType: 'text',
              isSeen: doc['isSeen'],
              timestamp: timestamp,
            );
          }

          return message;
        }).toList();

        return messages;
      });
    } catch (error) {
      print('Error fetching messages: $error');
      throw error;
    }
  }

  Future<void> sendMessage({
    required BuildContext context,
    required String receiverID,
    required String messageType,
    String? messageContent,
    String? messageImagePath,
    String? messageDocumentPath,
    required String userName,
    required String userImage,
  }) async {
    try {
      String currentUserID = userID!;
      String chatRoomID = constructChatRoomID(currentUserID, receiverID);
      bool chatRoomExists = await _chatRoomExists(chatRoomID);

      if (!chatRoomExists) {
        await _createChatRoomCollection(chatRoomID);
      }

      Map<String, dynamic> newMessage = {
        'senderID': currentUserID,
        'receiverID': receiverID,
        'messageType': messageType,
        'messageContent': messageContent ?? '',
        'messageImagePath': messageImagePath ?? '',
        'messageDocumentPath': messageDocumentPath ?? '',
        'isSeen': false,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('messages')
          .doc(chatRoomID)
          .collection('chats')
          .add(newMessage);

      await updateChattedUsers(
          currentUserID, receiverID, userName, userImage, context);

      await updateChattedUsers(receiverID, currentUserID, currentUserName!,
          currentUserImage!, context);
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  Future<bool> _chatRoomExists(String chatRoomID) async {
    DocumentSnapshot chatRoomSnapshot =
        await _firestore.collection('messages').doc(chatRoomID).get();
    return chatRoomSnapshot.exists;
  }

  Future<void> _createChatRoomCollection(String chatRoomID) async {
    await _firestore.collection('messages').doc(chatRoomID).set({});
  }

  Stream<QuerySnapshot> getMessages(String receiverID) {
    String currentUserID = userID!;
    String chatRoomID = constructChatRoomID(currentUserID, receiverID);

    return _firestore
        .collection('messages')
        .doc(chatRoomID)
        .collection('chats')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> updateChattedUsers(
    String currentUserID,
    String receiverID,
    String userName,
    String userImage,
    BuildContext context,
  ) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore
          .collection('chatted_users')
          .doc(currentUserID)
          .collection('users')
          .doc(receiverID)
          .get();

      if (!userSnapshot.exists) {
        await _firestore
            .collection('chatted_users')
            .doc(currentUserID)
            .collection('users')
            .doc(receiverID)
            .set({
          'receiverID': receiverID,
          'userName': userName,
          'userImage': userImage,
        });

        print('Chatted user added successfully!');
      } else {
        print('Chatted user already exists!');
      }
    } catch (error) {
      
      print('Error updating chatted users: $error');
    }
  }

  Stream<List<ChatUser>> chattedUsersStream(
      String userid, BuildContext context) {
    return _firestore
        .collection('chatted_users')
        .doc(userid)
        .collection('users')
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatUser> chattedUsers = [];
      for (final doc in snapshot.docs) {
        final receiverID = doc['receiverID'] as String?;
        final userName = doc['userName'] as String?;
        final userImage = doc['userImage'] as String?;
        if (receiverID != null && userName != null && userImage != null) {
          try {
            final lastMessage =
                await getLastMessage(userid, receiverID, context);
            int unreadMessages =
                await getUnreadMessageCount(userid, receiverID);

            chattedUsers.add(ChatUser(
              receiverID: receiverID,
              userName: userName,
              userImage: userImage,
              lastMessage: lastMessage?.messageContent ?? '',
              timestamp: lastMessage?.timestamp ?? DateTime.now(),
              unreadMessages: unreadMessages,
            ));
          } catch (error) {
            // Handle the error here
            print('Error fetching data for user $receiverID: $error');
            // You can choose to continue processing other users or return an empty list
          }
        }
      }
      return chattedUsers;
    });
  }

  Future<int> getUnreadMessageCount(String userID, String receiverID) async {
    try {
      String chatRoomID = constructChatRoomID(userID, receiverID);
      QuerySnapshot querySnapshot = await _firestore
          .collection('messages')
          .doc(chatRoomID)
          .collection('chats')
          .where('senderID',
              isNotEqualTo: userID) // Exclude messages sent by the current user
          .where('isSeen', isEqualTo: false) // Filter unread messages
          .get();
      return querySnapshot.docs.length;
    } catch (error) {
      print('Error getting unread message count: $error');
      return 0;
    }
  }

  Future<ChatMessage?> getLastMessage(
      String userID, String receiverID, BuildContext context) async {
    try {
      String chatRoomID = constructChatRoomID(userID, receiverID);
      QuerySnapshot querySnapshot = await _firestore
          .collection('messages')
          .doc(chatRoomID)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final messageType = doc['messageType'] as String?;
        DateTime? timestamp = doc['timestamp'] != null
            ? (doc['timestamp'] as Timestamp).toDate()
            : null;

        if (messageType == 'image') {
          return ChatMessage(
            senderID: doc['senderID'], // Add senderID to the ChatMessage

            messageType: messageType,
            messageImagePath: doc['messageImagePath'],
            isSeen: doc['isSeen'],
            timestamp: timestamp,
          );
        } else if (messageType == 'document') {
          return ChatMessage(
            senderID: doc['senderID'], // Add senderID to the ChatMessage

            messageType: messageType,
            messageDocumentPath: doc['messageDocumentPath'],
            isSeen: doc['isSeen'],
            timestamp: timestamp,
          );
        } else {
          return ChatMessage(
            messageContent: doc['messageContent'],
            messageType: 'text',
            isSeen: doc['isSeen'],
            timestamp: timestamp,
          );
        }
      }
      return null;
    } catch (error) {

      print('Error getting last message: $error');
      return null;
    }
  }
}

String constructChatRoomID(String userID1, String userID2) {
  List<String> ids = [userID1, userID2];
  ids.sort();
  return '${ids[0]}_${ids[1]}';
}
