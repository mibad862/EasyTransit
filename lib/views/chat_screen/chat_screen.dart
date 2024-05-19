import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_project1/views/chat_screen/ChatDetailPage.dart';
import 'package:demo_project1/views/chat_screen/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../services/chat/chat_services.dart';
import 'model/chat_user_model.dart';
import 'model/search_user.dart';

// Model class representing a chat

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ChatProvider(), child: const ChatScreen());
  }
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  late SharedPreferences prefs;
  String? userID;

  ChatServices chatServices = new ChatServices();

  @override
  void initState() {
    initSharedPreferences();

    super.initState();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userid');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    "Chat",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      const Center(child: CircularProgressIndicator());
                      _showUserListDialog(context);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.pink[50],
                      ),
                      child: const Row(
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            color: Colors.pink,
                            size: 20,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Add New",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSearch(),
          Flexible(
            child: StreamBuilder<String?>(
              stream: ChatServices().getUserIDStream(),
              builder: (context, snapshot) => StreamBuilder<List<ChatUser>>(
                stream: ChatServices().chattedUsersStream(userID!,
                    context), // Stream that provides chatted users data
                builder: (context, snapshot) {
                  print(snapshot.data);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "No chats Available",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  } else {
                    List<ChatUser> chattedUsers = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: chattedUsers.length,
                      itemBuilder: (context, index) {
                        final user = chattedUsers[index];
                        return ListTile(
                          leading: user.userImage == null ||
                                  user.userImage.endsWith("/")
                              ? CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      user.userImage),
                                )
                              : ProfilePicture(
                                  name: user.userName,
                                  fontsize: 16,
                                  radius: 24,
                                  random: true,
                                ),
                          title: Text(user.userName.toUpperCase()),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(user.lastMessage),
                            ],
                          ),
                          trailing: Column(
                            children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                _formatTimestamp(user.timestamp),
                                style: const TextStyle(color: Colors.grey),
                              ),
                              user.unreadMessages > 0
                                  ? Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                        child: Text(
                                          (user.unreadMessages.toString()),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : const Text(''),
                            ],
                          ),
                          onTap: () {
                            setState(() {});
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailPage(
                                  receiverID: user.receiverID,
                                  senderID: userID!,
                                  userImage: user.userImage,
                                  userName: user.userName,
                                ),
                              ),
                            );

                            // Navigate to chat detail page or do something else
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // void dispose() {
  //   _messageController.dispose();
  //   super.dispose();
  // }

  Widget _buildSearch() {
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: SizedBox(
          height: 100,
          width: 400,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserListDialog(BuildContext context) async {
    // Show circular progress indicator while fetching data
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Fetching chat users...'),
            ],
          ),
        );
      },
    );

    TextEditingController searchController = TextEditingController();
    final List<SearchUsers> allUsers =
        await fetchChatUsers(userID!, "", context);

    // Dismiss the loading dialog
    Navigator.pop(context);

    List<SearchUsers> displayedUsers = List.from(allUsers);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chat Users'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        displayedUsers = allUsers
                            .where((user) => user.adminName
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  displayedUsers.isEmpty
                      ? const Text('No users found')
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: displayedUsers.length,
                            itemBuilder: (context, index) {
                              final user = displayedUsers[index];

                              return SizedBox(
                                width: 100,
                                child: ListTile(
                                  leading: user.image == null ||
                                          !user.image.endsWith("/")
                                      ? CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  user.image),
                                        )
                                      : ProfilePicture(
                                          name: user.adminName,
                                          fontsize: 16,
                                          radius: 24,
                                          random: true,
                                        ),
                                  title: Text(user.adminName),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateToUserScreen(context, user);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToUserScreen(BuildContext context, SearchUsers user) {
    // Navigate to the user screen
    print("User id is${userID!}");
    print("reciver id is${user.id}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          userName: user.adminName,
          userImage: user.image,
          receiverID: user.id,
          senderID: userID ?? "1",
        ),
      ),
    );
  }

}

class ChatUsers {
  String? name;
  String? messageText;
  String image;
  String time;
  String text, secondaryText;
  int unreadMessages; // New field to store the count of unread messages
  ChatUsers({
    this.name,
    this.messageText,
    required this.image,
    required this.time,
    required this.text,
    required this.secondaryText,
    this.unreadMessages = 0,
  });
}

Future<List<SearchUsers>> fetchChatUsers(
    String userID, String search, BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('https://alkhandaq-b.s-tip.com/stip_api/Api/chat_userlist'),
      body: {
        'userID': userID,
        'search': search,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<SearchUsers> users = [];

      jsonData['data'].forEach((key, value) {
        final List<dynamic> userList = value;
        userList.forEach((user) {
          users.add(SearchUsers.fromJson(user));
        });
      });

      return users;
    } else {
      throw Exception('Failed to load chat users: ${response.statusCode}');
    }
  } catch (error) {
    

    throw Exception('Failed to load chat users: $error');
  }
}

String _formatTimestamp(DateTime timestamp) {
  // Format timestamp as desired (e.g., HH:mm)
  return DateFormat.Hm().format(timestamp);
}
