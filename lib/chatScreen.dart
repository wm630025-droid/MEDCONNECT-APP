

import 'package:flutter/material.dart';
class ChatMessage {
  final String? text;
  final String type; // text | image | file
  final DateTime time;
  final bool isMe;

  ChatMessage({
    this.text,
    required this.type,
    required this.time,
    required this.isMe,
  });
}
class ChatScreen extends StatefulWidget {
  final String chatName;

  const ChatScreen({super.key, required this.chatName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _controller = TextEditingController();

  List<ChatMessage> messages = [
    ChatMessage(
      text: "Hello, do you have surgical tables?",
      type: "text",
      time: DateTime.now(),
      isMe: false,
    ),
    ChatMessage(
      text: "Yes, we have multiple models available.",
      type: "text",
      time: DateTime.now(),
      isMe: true,
    ),
  ];

  void sendTextMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: _controller.text.trim(),
          type: "text",
          time: DateTime.now(),
          isMe: true,
        ),
      );
    });

    _controller.clear();
  }

  // زرار الإرفاق (دلوقتي تجريبي)
  void sendAttachment(String type) {
    setState(() {
      messages.add(
        ChatMessage(
          text: type == "image" ? "Image Sent" : "File Sent",
          type: type,
          time: DateTime.now(),
          isMe: true,
        ),
      );
    });
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: Colors.white,
        ),
      
      body: Column(
        children: [

          /// الرسائل
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment:
                      msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color:
                          msg.isMe ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        /// محتوى الرسالة
                        if (msg.type == "text")
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(msg.text ?? ""),
                          ),

                        if (msg.type == "image")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.image, size: 40),
                              SizedBox(height: 4),
                              Text("Image attachment"),
                            ],
                          ),

                        if (msg.type == "file")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.insert_drive_file, size: 40),
                              SizedBox(height: 4),
                              Text("File attachment"),
                            ],
                          ),

                        const SizedBox(height: 5),
                        /// الوقت
                        Text(
                          formatTime(msg.time),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// شريط الإدخال
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [

                /// زرار الإرفاق
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text("Send Image"),
                              onTap: () {
                                Navigator.pop(context);
                                sendAttachment("image");
                              },
                            ),
                            ListTile(
                              leading:
                                  const Icon(Icons.insert_drive_file),
                              title: const Text("Send File"),
                              onTap: () {
                                Navigator.pop(context);
                                sendAttachment("file");
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                /// TextField
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                /// زرار الإرسال
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendTextMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}