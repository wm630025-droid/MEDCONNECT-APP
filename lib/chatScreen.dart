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
  final Map<String, dynamic>? productData; // ✅ جديد

  ChatMessage({
    required this.id,
    this.text,
    required this.type,
    required this.time,
    required this.isMe,
    this.productData, // ✅ جديد
  });
}

class ChatScreen extends StatefulWidget {
  final String chatName;
  final int? conversationId;
  final int receiverId; // هتحتاجيها عشان تبعتي رسالة
  final Map<String, dynamic>? initialMessage; // ✅ جديد
  final String? text; // ✅ جديد
  const ChatScreen({
    super.key,
    required this.chatName,
    required this.conversationId,
    required this.receiverId,
    this.initialMessage,
    this.text,
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
    // print('🟢 ChatScreen initState');
    // print('📦 widget.conversationId: ${widget.conversationId}');
    // print('📦 widget.receiverId: ${widget.receiverId}');

    //print('✅ conversationId set to: $conversationId');
    conversationId = widget.conversationId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.conversationId != null) {
        _loadMessages();
        _startPolling();

        // _subscribeToPusher();
      } else {
        print('⚠️ conversationId is null, calling _fetchOrCreateConversation');
        // _loading = false;
        await _fetchOrCreateConversation();
      }
      print("initialMessage: ${widget.initialMessage}");
      if (widget.initialMessage != null) {
        //  WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMessages();
        _sendSharedProduct(widget.initialMessage!, widget.text ?? '');
        //  });
      }
    });

    // ✅ لو في رسالة مسبقة (Share Product)
  }

  Future<void> _sendSharedProduct(
    Map<String, dynamic> productData,
    String text,
  ) async {
    print('📦 دخلت shared product');
    if (conversationId == null) {
      // نحاول نبحث عن محادثة أو ننشئ واحدة
      await _fetchOrCreateConversation();
      if (conversationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Cannot start conversation with this supplier'),
          ),
        );
        return;
      }
    }
    // ✅ بناء الرسالة
    //  final message = "🛒 Shared Product: ${productData['productName']}";

    // ✅ إرسال الرسالة
    await _sendMessage(text, isProduct: true, productData: productData);
    print("after send shared product");
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
    _pollTimer = Timer.periodic(Duration(seconds: 1), (Timer) {
      if (mounted && conversationId != null) {
        _checkNewMessages();
      }
    });
  }

  Future<void> _checkNewMessages() async {
    if (conversationId == null) return;

    try {
      final messages = await _api.getMessages(conversationId!);
      final lastMessage = messages.isNotEmpty ? messages.last['message'] : '';

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
        setState(() {
          conversationId = found['id'];
        });
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

      print("messages length: ${messages.length}");
      if (messages.isNotEmpty) {
        print('📦 Last message: ${messages.last}');
      }
      if (mounted) {
        setState(() {
          _messages = messages.map((m) {
            final hasProduct =
                m['product_name'] != null && m['product_image'] != null;
            return ChatMessage(
              id: m['id'],
              text: m['message'],
              type: 'text',
              time: DateTime.parse(m['created_at']),
              isMe: m['sender']['role'] == 'doctor',
              productData:
                  (m['product_name'] != null && m['product_image'] != null)
                  ? {
                      'productName': m['product_name'],
                      'productImage': m['product_image'],
                    }
                  : null,
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

  Future<void> _sendMessage(
    String text, {
    bool isProduct = false,
    Map<String, dynamic>? productData,
  }) async {
    print("-------------------------------");
    print('Reciver ID : ${widget.receiverId}');
    print('Messsege ${text}');
    print("-------------------------------");
    if (text.trim().isEmpty && !isProduct) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _messages.add(
        ChatMessage(
          id: tempId,
          text: text,
          type: 'text',
          time: DateTime.now(),
          isMe: true,
          productData: isProduct ? productData : null, // ✅ بيانات المنتج
        ),
      );
      
    });
    _controller.clear();
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
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadMessages(); // ✅ بعد الإرسال نحدث الرسائل
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
              text: newMsg['body'] ?? text,
              type: 'text',
              time: newMsg['created_at'] != null
                  ? DateTime.parse(newMsg['created_at'])
                  : DateTime.now(),
              isMe: true,
              productData: isProduct ? productData : null, // ✅ بيانات المنتج
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
                        if (msg.text != null && msg.text!.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(msg.text ?? ""),
                          ),

                        if (msg.productData != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    msg.productData!['productImage'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.productData!['productName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Text(
                                      //   '\$${msg.productData!['productPrice']}',
                                      //   style: const TextStyle(
                                      //     color: Colors.green,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
