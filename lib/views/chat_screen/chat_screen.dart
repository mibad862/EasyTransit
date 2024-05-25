import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_project1/common_widgets/common_appbar.dart';
import 'package:demo_project1/views/chat_screen/ChatDetailPage.dart';
import 'package:demo_project1/views/chat_screen/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/chat/chat_services.dart';
import 'model/chat_user_model.dart';

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
  bool isLoading = true;

  ChatServices chatServices = new ChatServices();

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userid');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        appBar: CommonAppBar(title: "chat", showicon: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userID == null) {
      return const Scaffold(
        appBar: CommonAppBar(title: "chat", showicon: true),
        body: Center(child: Text("User ID not found")),
      );
    }

    return Scaffold(
      appBar: const CommonAppBar(title: "chat", showicon: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSearch(),
          Flexible(
            child: StreamBuilder<List<ChatUser>>(
              stream: ChatServices().chattedUsersStream(userID!, context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "No chats Available",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  List<ChatUser> chattedUsers = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: chattedUsers.length,
                    itemBuilder: (context, index) {
                      final user = chattedUsers[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 48,
                          height: 48,
                          child: user.userImage == ""
                              ? const CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      "https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTAxL3JtNjA5LXNvbGlkaWNvbi13LTAwMi1wLnBuZw.png"),
                                )
                              : ProfilePicture(
                                  name: user.userName.isNotEmpty
                                      ? user.userName
                                      : "User",
                                  fontsize: 16,
                                  radius: 24,
                                  random: true,
                                ),
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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

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
}

class ChatUsers {
  String? name;
  String? messageText;
  String image;
  String time;
  String text, secondaryText;
  int unreadMessages;
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

String _formatTimestamp(DateTime timestamp) {
  return DateFormat.Hm().format(timestamp);
}
