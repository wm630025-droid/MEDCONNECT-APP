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
  final String type;
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
  final int receiverId;

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
  final ScrollController _scrollController = ScrollController(); // ✅ مضافة
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
      _startPolling();
    } else {
      print('⚠️ conversationId is null, calling _fetchOrCreateConversation');
      // _loading = false;
      _fetchOrCreateConversation();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _scrollController.dispose(); // ✅ مضافة
    _controller.dispose();       // ✅ مضافة
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && conversationId != null) {
        _checkNewMessages();
      }
    });
  }

  Future<void> _checkNewMessages() async {
    if (conversationId == null) return;
    try {
      final messages = await _api.getMessages(conversationId!);
      if (!mounted) return;
      if (messages.isNotEmpty) {
        final newLastId = messages.last['id'];
        final currentLastId = _messages.isNotEmpty ? _messages.last.id : null;
        if (newLastId != currentLastId) {
          await _loadMessages();
        }
      }
    } catch (e) {
      debugPrint('Error checking new messages: $e');
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
      }
    } catch (e) {
      debugPrint('Error fetching conversation: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (conversationId == null) return;
    try {
      final messages = await _api.getMessages(conversationId!);
      if (!mounted) return;
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
      await _api.markConversationAsRead(conversationId!);
      _scrollToBottom(); // ✅ مضافة
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ✅ دالة _sendMessage منفصلة تماماً ومُصلَحة
  Future<void> _sendMessage(String text) async {
    print("-------------------------------");
    print('Reciver ID : ${widget.receiverId}');
    print('Messsege ${text}');
    print("-------------------------------");
    if (text.trim().isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    _controller.clear();

    // أضف الرسالة مؤقتاً للـ UI
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

  void _scrollToBottom() {
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

  // ✅ sendAttachment مُصلَحة
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
          if (_loading)
            const LinearProgressIndicator(), // ✅ مضافة
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ✅ مضافة
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                        if (msg.type == "text")
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(msg.text ?? ""),
                          ),
                        if (msg.type == "image")
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.image, size: 40),
                              SizedBox(height: 4),
                              Text("Image attachment"),
                            ],
                          ),
                        if (msg.type == "file")
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.insert_drive_file, size: 40),
                              SizedBox(height: 4),
                              Text("File attachment"),
                            ],
                          ),
                        const SizedBox(height: 5),
                        Text(
                          formatTime(msg.time),
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
                    onSubmitted: _sendMessage, // ✅ إرسال بـ Enter
                  ),
                ),
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