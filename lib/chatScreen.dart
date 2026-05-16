

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medconnect_app/services/api_service.dart';
class ChatMessage {
  final int id;
  final String? text;
  final String type; // text | image | file
  final DateTime time;
  final bool isMe;

  ChatMessage({
    required this.id,
    this.text,
    required this.type,
    required this.time,
    required this.isMe,
  });
}
class ChatScreen extends StatefulWidget {
  final String chatName;
  final int? conversationId;

  const ChatScreen({super.key, required this.chatName, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _controller = TextEditingController();
  final ApiService _api = ApiService();
  List<ChatMessage> _messages = [];
  bool _loading = true;
  String? _error;
  int? conversationId;
  Timer? _pollTimer;

   @override
  void initState() {
    super.initState();
    if(widget.conversationId != null){
      conversationId =widget.conversationId;
      _loadMessages();

      _startPolling();
    }else {
      _fetchOrCreateConversation();
    }
    
   
    
  }

  void _startPolling() {
    _pollTimer = Timer.periodic( Duration(seconds: 5), (Timer) {
      if(mounted && conversationId != null) {
        _checkNewMessages();
      }
    });
  }
  Future<void> _checkNewMessages() async {
  if (conversationId == null) return;

  try {
    final messages = await _api.getMessages(conversationId!);
    final lastMessage = messages.isNotEmpty ? messages.last['body'] : '';

    // ✅ هنا تقارني بين آخر رسالة موجودة عندك والجديدة
    if (_messages.isNotEmpty && messages.isNotEmpty) {
      final currentLastId = _messages.last.id;
      final newLastId = messages.last['id'];

      if (newLastId != currentLastId) {
        // فيه رسائل جديدة
        await _loadMessages();
      }
    } else if (messages.isNotEmpty && _messages.isEmpty) {
      await _loadMessages();
    }
  } catch (e) {
    print('Error checking new messages: $e');
  }
}
@override
void dispose() {
  _pollTimer?.cancel();
  super.dispose();
}
  Future<void> _fetchOrCreateConversation() async {
    try {
      final convs = await _api.getConversations();
      // دور على المحادثة اللي فيها الـ supplier name = widget.chatName
      final found = convs.firstWhere(
        (c) => c['other_user']['fullname'] == widget.chatName,
        orElse: () => null,
      );
      if (found != null) {
        conversationId = found['id'];
        await _loadMessages();
      } else {
        // في حالة لسه مفيش محادثة، هتعملي create أول رسالة
        // مش موجود الصراحة في الـ APIs، ممكن أول رسالة تعملها
      }
    } catch (e) {
      print(e);
    }
  }


  Future<void> _loadMessages() async {
  if (conversationId == null) return;

  try {
    final messages = await _api.getMessages(conversationId!);
    setState(() {
      _messages = messages.map((m) {
        return ChatMessage(
          id: m['id'],
          text: m['body'],
          type: 'text',
          time: DateTime.parse(m['created_at']),
          isMe: m['sender']['role'] == 'doctor',
        );
      }).toList();
      _loading = false;
    });

    // ✅ بعد تحميل الرسائل نحددها كمقروءة
    await _api.markConversationAsRead(conversationId!);
  } catch (e) {
    setState(() {
      _loading = false;
      _error = e.toString();
    });
  }
}
//  Future<void> _loadMessages() async {
//     if (conversationId == null) return;
//     final List<dynamic> msgs = await _api.getMessages(conversationId!);
//     setState(() {
//       _messages = msgs.map((m) {
//         return ChatMessage(
//           text: m['body'],
//           type: 'text',
//           time: DateTime.parse(m['created_at']),
//           isMe: m['sender']['role'] == 'doctor',
//         );
//       }).toList();
//       _loading = false;
//     });


    
//   }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    try {
      final newMsg = await _api.sendMessage(
        receiverId: 30001, // هنا هتحتاجي الـ supplier id
        message: text,
      );
      setState(() {
        _messages.add(ChatMessage(
          id: newMsg['id'],
          text: text,
          type: 'text',
          time: DateTime.now(),
          isMe: true,
        ));
      });
      _controller.clear();
      Navigator.pop(context,true);
    } catch (e) {
      print(e);
    }
  }
  // void sendTextMessage() {
  //   if (_controller.text.trim().isEmpty) return;

  //   setState(() {
  //     _messages.add(
  //       ChatMessage(
  //         text: _controller.text.trim(),
  //         type: "text",
  //         time: DateTime.now(),
  //         isMe: true,
  //       ),
  //     );
  //   });

  //   _controller.clear();
  // }

  // زرار الإرفاق (دلوقتي تجريبي)
  void sendAttachment(String type) {
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

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
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}