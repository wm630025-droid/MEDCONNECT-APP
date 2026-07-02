import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medconnect_app/services/api_service.dart';

//import 'package:medconnect_app/services/pusher_service.dart';
//ClientException with SocketException: Failed host lookup: 'pub.dev' (OS Error: No such host is known, errno = 11001), uri=https://pub.dev/api/packages/dio/advisories
// Failed to update packages.
// exit code 69
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
  final int receiverId; // هتحتاجيها عشان تبعتي رسالة

  const ChatScreen({
    super.key,
    required this.chatName,
    required this.conversationId,
    required this.receiverId,
  });

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('🟢 ChatScreen initState');
    print('📦 widget.conversationId: ${widget.conversationId}');
    print('📦 widget.receiverId: ${widget.receiverId}');

    if (widget.conversationId != null) {
      print('✅ conversationId set to: $conversationId');
      conversationId = widget.conversationId;
      _loadMessages();
      // _subscribeToPusher();
      _startPolling();
    } else {
      print('⚠️ conversationId is null, calling _fetchOrCreateConversation');
      // _loading = false;
      _fetchOrCreateConversation();
    }
  }

  // void _subscribeToPusher() {
  //   if (conversationId == null) return;

  //   PusherService().subscribeToConversation(conversationId!, (data) {
  //     // ✅ رسالة جديدة وصلت فوراً من Pusher
  //     if (mounted) {
  //       final isMe = data['sender']['id'] == ApiService.doctorId;
  //       setState(() {
  //         _messages.add(
  //           ChatMessage(
  //             id: data['id'],
  //             text: data['body'],
  //             type: 'text',
  //             time: DateTime.parse(data['sent_at']),
  //             isMe: isMe,
  //           ),
  //         );
  //       });

  //       // تحديث read_at تلقائياً
  //       if (!isMe) {
  //         _api.markConversationAsRead(conversationId!);
  //       }
  //     }
  //   });
  // }

  void _startPolling() {
    _pollTimer = Timer.periodic(Duration(seconds: 5), (Timer) {
      if (mounted && conversationId != null) {
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
    // if (conversationId != null) {
    //   PusherService().unsubscribeFromConversation(conversationId!);
    // }
    super.dispose();
  }

  Future<void> _fetchOrCreateConversation() async {
    try {
      final convs = await _api.getConversations();
      print('📦 Conversations: $convs');
      // دور على المحادثة اللي فيها الـ supplier name = widget.chatName
      final found = convs.firstWhere(
        (c) => c['other_user']['id'] == widget.receiverId,
        orElse: () => null,
      );
      if (found != null) {
        conversationId = found['id'];
        print('✅ Found conversation: $conversationId');
        await _loadMessages();
        _startPolling();
      } else {
        print('⚠️ No conversation found, waiting for first message');
        setState(() {
          _loading = false;
        });
        // في حالة لسه مفيش محادثة، هتعملي create أول رسالة
        // مش موجود الصراحة في الـ APIs، ممكن أول رسالة تعملها
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      print(e);
    }
  }

  Future<void> _loadMessages() async {
    if (conversationId == null) return;

    try {
      final messages = await _api.getMessages(conversationId!);
      if (mounted) {
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
      // ✅ بعد تحميل الرسائل نحددها كمقروءة
      await _api.markConversationAsRead(conversationId!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
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
    print("-------------------------------");
    print('Reciver ID : ${widget.receiverId}');
    print('Messsege ${text}');
    print("-------------------------------");
    if (text.trim().isEmpty) return;
    final tempId = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _messages.add(
        ChatMessage(
          id: tempId,
          text: text,
          type: 'text',
          time: DateTime.now(),
          isMe: true,
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    _controller.clear();
    try {
      final response = await _api.sendMessage(
        receiverId: widget.receiverId, // ✅ من الـ widget
        message: text,
      );
      print('📦 Full sendMessage Response: $response'); // ✅ برينت

      // ✅ تحقق من وجود البيانات قبل استخدامها
      //  Navigator.pop(context,true);
      final data = response['data'];
      final newMsg = data['message'];
      final conv = data['conversation'];

      // ✅ لو أول رسالة، ناخد conversationId
      if (conversationId == null && conv != null) {
        setState(() {
          conversationId = conv['id'];
        });
        _startPolling(); // ✅ نبدأ نسمع رسائل جديدة
      }
      if (newMsg != null && newMsg['id'] != null) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == tempId);
          if (index != -1) {
            _messages[index] = ChatMessage(
              id: newMsg['id'],
              text: text,
              type: 'text',
              time: DateTime.now(),
              isMe: true,
            );
          }
        });
      }
      // setState(() {
      //       final index = _messages.indexWhere((m) => m.id == tempId);
      //       if (index != -1) {
      //         _messages[index] = ChatMessage(
      //           id: newMsg['id'],
      //           text: text,
      //           type: 'text',
      //           time: DateTime.now(),
      //           isMe: true,
      //         );
      //       }
      //     });
      // Navigator.pop(context,true);
    } catch (e) {
      print(e);

      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
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
    if (mounted) {
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
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: Colors.white,
      ),

      body: Column(
        children: [
          /// الرسائل
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                return Align(
                  alignment: msg.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isMe ? Colors.blue[200] : Colors.grey[300],
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
                // IconButton(
                //   icon: const Icon(Icons.attach_file),
                //   onPressed: () {
                //     showModalBottomSheet(
                //       context: context,
                //       builder: (_) {
                //         return Wrap(
                //           children: [
                //             ListTile(
                //               leading: const Icon(Icons.image),
                //               title: const Text("Send Image"),
                //               onTap: () {
                //                 Navigator.pop(context);
                //                 sendAttachment("image");
                //               },
                //             ),
                //             ListTile(
                //               leading: const Icon(Icons.insert_drive_file),
                //               title: const Text("Send File"),
                //               onTap: () {
                //                 Navigator.pop(context);
                //                 sendAttachment("file");
                //               },
                //             ),
                //           ],
                //         );
                //       },
                //     );
                //   },
                // ),

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
          ),
        ],
      ),
    );
  }
}
