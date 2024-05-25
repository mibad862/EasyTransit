// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_project1/services/chat/chat_services.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailPage extends StatefulWidget {
  final String userName;
  final String userImage;
  final String receiverID;
  final String senderID;

  const ChatDetailPage({
    required this.userName,
    required this.userImage,
    required this.receiverID,
    required this.senderID,
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> messages = [];
  ChatServices chatservice = ChatServices();
  late Stream<List<ChatMessage>> messageStream;
  XFile? _selectedImage;
  PlatformFile? _selectedFile;
  bool _sendingMessage = false; // Added to track message sending state
  late SharedPreferences prefs;
  String? userID;
  Map<int, double> downloadprocess = {};

  @override
  void initState() {
    init();
    messageStream = chatservice.getMessageStream(
        widget.senderID, widget.receiverID, context);

    super.initState();
  }

  Future<void> init() async {
    await initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      userID = prefs.getString('userid');
    });
  }

  Future<void> downloadFile(String url, BuildContext context, index) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/${Uri.parse(url).pathSegments.last}';

      // Show a snackbar indicating the download process has started
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloading")),
      );

      Dio().download(
        url,
        filePath,
        onReceiveProgress: (count, total) {
          double process = count / total;
          setState(() {
            downloadprocess[index] = process;
          });
        },
      );

      // Show a snackbar indicating the file has been downloaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloaded")),
      );

      // Delay for a short duration to show the snackbar
      await Future.delayed(const Duration(seconds: 1));

      // Open the downloaded file using open_file package
      await OpenFile.open(filePath);

      // Hide the download process indicator after opening the file
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (error) {
      print('Error downloading or opening file: $error');
      // Handle errors accordingly
    }
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _sendImage(pickedFile);
    }
  }

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _sendFile(result.files.first);
    }
  }

  // Sending message with image
  void _sendImage(XFile imageFile) async {
    // Display the selected image immediately
    setState(() {
      _selectedImage = imageFile;
    });

    String imagePath = imageFile.path;
    try {
      // Upload image to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(File(imagePath));
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Send message with image download URL
      chatservice.sendMessage(
        receiverID: widget.receiverID,
        messageImagePath: downloadURL,
        messageType: 'image',
        userName: widget.userName,
        userImage: widget.userImage,
        context: context,
      );

      // Clear the text field and selected image
      _messageController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

// Sending message with document
  void _sendFile(PlatformFile file) async {
    String filePath = file.path!;
    try {
      // Upload document to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('documents')
          .child(DateTime.now().toString() + '_' + file.name);
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Send message with document download URL
      chatservice.sendMessage(
        receiverID: widget.receiverID,
        messageDocumentPath: downloadURL,
        messageType: 'document',
        userName: widget.userName,
        userImage: widget.userImage,
        // ignore: use_build_context_synchronously
        context: context,
      );

      // Clear the text field and selected file
      _messageController.clear();
      setState(() {
        _selectedFile = null;
      });
    } catch (error) {
      print('Error uploading document: $error');
    }
  }

  void _sendMessage(String text) {
    // Handle sending the text message
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _sendingMessage = true; // Show loading indicator
      });
      chatservice.sendMessage(
        receiverID: widget.receiverID,
        messageContent: _messageController.text.trim(),
        messageType: 'text', // Set messageType to 'text'
        userName: widget.userName,
        userImage: widget.userImage,
        context: context,
      );
      _messageController.clear();
      setState(() {
        _sendingMessage = false; // Hide loading indicator after sending
      });
    } else {
      // Show a message to the user indicating that they need to enter something
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a message'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: ListTile(
            leading: _buildProfileImage(),
            title: Text(
              widget.userName,
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ),
        body: Stack(children: <Widget>[
          SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height - 140,
                child: StreamBuilder<List<ChatMessage>>(
                  stream: messageStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                        'No data Available',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ));
                    } else {
                      List<ChatMessage> messages = snapshot.data ?? [];
                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          double? progress = downloadprocess[index];
                          final isCurrentUserMessage =
                              messages[index].senderID == userID;

                          //XCtstouHR5YEKaKNfYOqykq3aOv2

                          if (messages[index].messageType == 'image') {
                            // Display image message
                            return GestureDetector(
                              onTap: () {
                                String? url = messages[index].messageImagePath;
                                downloadFile(url!, context, index);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio:
                                      16 / 9, // Set the aspect ratio as needed

                                  child: Image.network(
                                    messages[index].messageImagePath!,
                                    alignment: isCurrentUserMessage
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                  ),
                                ),
                              ),
                            );
                          } else if (messages[index].messageType ==
                              'document') {
                            // Display file message
                            return // Display file message
                                Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isCurrentUserMessage
                                      ? Colors.blue[200]
                                      : Colors.grey.shade200,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: isCurrentUserMessage
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: const [
                                      Icon(Icons.file_present_rounded),
                                      SizedBox(width: 8),
                                      Text(
                                        'Document',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  subtitle: progress != null
                                      ? LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.black,
                                        )
                                      : null,
                                  onTap: () {
                                    String? url =
                                        messages[index].messageDocumentPath;
                                    downloadFile(url!, context, index);
                                  },
                                ),
                              ),
                            );
                          } else {
                            // Display text message
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              child: Align(
                                alignment: isCurrentUserMessage
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: isCurrentUserMessage
                                        ? Colors.blue[200]
                                        : Colors.grey.shade200,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              messages[index].messageContent!,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            messages[index].isSeen!
                                                ? Icons.done_all
                                                : Icons.done,
                                            color: messages[index].isSeen!
                                                ? Colors.blue
                                                : Colors.grey,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _formatTimestamp(
                                            messages[index].timestamp),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              )),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: _handlePlusIconTap,
                    child: Container(
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.attachment_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _sendingMessage // Disable button if sending
                        ? null
                        : () => _sendMessage(_messageController.text),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    child: _sendingMessage // Show loading indicator
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ],
              ),
            ),
          )
        ]));
  }

  void _handlePlusIconTap() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_size_select_actual_outlined,
                  color: Colors.blueAccent,
                ),
                title: const Text(
                  'Photo',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _selectImage();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.drive_file_move_rtl_outlined,
                  color: Colors.blueAccent,
                ),
                title: const Text(
                  'File',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _selectFile();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    String profileName = widget.userName.isNotEmpty ? widget.userName : 'User';
    return SizedBox(
        height: 20,
        width: 30,
        child: widget.userImage.isNotEmpty
            ? CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.userImage),
              )
            : const CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                    "https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTAxL3JtNjA5LXNvbGlkaWNvbi13LTAwMi1wLnBuZw.png"),
              )
        // : ProfilePicture(
        //     name: profileName,
        //     fontsize: 16,
        //     radius: 24,
        //     random: false,
        //   ),
        );
  }
}

class ChatMessage {
  String? senderID;
  String? messageContent;
  String? messageType; // 'text', 'image', or 'document'
  String? messageImagePath; // Path to the image (if messageType is 'image')
  String?
      messageDocumentPath; // Path to the document (if messageType is 'document')
  bool? isSeen;
  DateTime? timestamp;

  ChatMessage({
    this.senderID,
    this.messageContent,
    this.messageType,
    this.messageImagePath,
    this.messageDocumentPath,
    this.isSeen,
    this.timestamp,
  });
}

List<ChatMessage> messages = [];

String _formatTimestamp(DateTime? timestamp) {
  if (timestamp != null) {
    return DateFormat.Hm().format(timestamp); // Format time as HH:mm
  } else {
    return ''; // Return an empty string or handle the null case accordingly
  }
}
