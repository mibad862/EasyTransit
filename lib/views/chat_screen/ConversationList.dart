import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class ConversationList extends StatelessWidget {
  final String name;
  final String messageText;
  final String time;
  final bool isMessageRead;
  final String imageUrl;

  const ConversationList({
    required this.name,
    required this.messageText,
    required this.time,
    required this.isMessageRead,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditionally render the profile picture
            imageUrl.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                  )
                : ProfilePicture(
                    name: name,
                    fontsize: 21,
                    radius: 24,
                    random: false,
                  ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    messageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                isMessageRead
                    ? Icon(
                        Icons.done_all,
                        color: Colors.blue,
                        size: 16,
                      )
                    : SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
