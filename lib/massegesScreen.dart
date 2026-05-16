import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medconnect_app/services/api_service.dart';

import 'chatScreen.dart';

class ChatModel {
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unreadCount;

  ChatModel({
    
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.unreadCount,

  });
}

class MessagesScreen extends StatefulWidget {
  MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController searchController = TextEditingController();
  List<ChatModel> filteredChats = [];

  final ApiService _api = ApiService();
  List<ChatModel> _chats = [];
  bool _loading = true;
  String? _error;
  List<int> _conversationIds = [];
 Timer? _refreshTimer; 

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    filteredChats = _chats;
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if(mounted) _fetchConversations();
    });
  }
  @override
  void dispose() {
    
    _refreshTimer?.cancel();
    super.dispose();
  }
  Future<void> _fetchConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<dynamic> convs = await _api.getConversations();

      final List<ChatModel> loaded = [];
      List<int> ids = [];

      for (var conv in convs) {
        final int convId = conv['id'];
        final other = conv['other_user'];

        // ✅ جلب آخر رسالة وعدد الغير مقروءة
        final messages = await _api.getMessages(convId);

        // ✅ حساب عدد الرسائل الغير مقروءة (read_at == null والمرسل مش أنا)
        int unreadCount = 0;
        String lastMessage = '';
        String lastTime = '';

        for (var msg in messages) {
          final isMe = msg['sender']['role'] == 'doctor';
          final readAt = msg['read_at'];

          // ✅ لو الرسالة مش أنا (جاية من الآخر) ولسه مقروءتش
          if (!isMe && readAt == null) {
            unreadCount++;
          }

          // ✅ آخر رسالة
          if (msg == messages.last) {
            lastMessage = msg['body'];
            lastTime = _formatTime(msg['created_at']);
          }
        }

        loaded.add(
          ChatModel(
            name: other['fullname'],
            lastMessage: lastMessage,
            time: lastTime,
            isOnline: false,
            unreadCount: unreadCount,
          ),
        );
        ids.add(convId);
      }

      setState(() {
        _chats = loaded;
        filteredChats = loaded;
        _conversationIds = ids;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }
  //  Future<void> _fetchConversations() async {
  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });

  //   try {
  //     final conversations = await _api.getConversations();
  //     List<ChatModel> loaded = [];
  //     List<int> ids = [];

  //     for (var conv in conversations) {
  //       final other = conv['other_user'];
  //       final lastMessage = conv['last_message'] ?? '';
  //       final lastMessageAt = conv['last_message_at'];

  //       // نحتاج نجيب الـ unread count (هتحتاجي API منفصل أو تحسبيه من messages)
  //       int unreadCount = 0;
  //       // ممكن تستخدمي getMessages وتحسبي unread

  //       loaded.add(ChatModel(
  //         name: other['fullname'],
  //         lastMessage: lastMessage,
  //         time: _formatTime(lastMessageAt),
  //         isOnline: false,
  //         unreadCount: unreadCount,
  //       ));
  //       ids.add(conv['id']);
  //     }

  //     setState(() {
  //       _chats = loaded;
  //       filteredChats = loaded;
  //       _conversationIds = ids;
  //       _loading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //       _loading = false;
  //     });
  //   }
  // }
  //  Future<void> _fetchConversations() async {
  //     setState(() {
  //       _loading = true;
  //       _error = null;
  //     });

  //     try {
  //       final List<dynamic> convs = await _api.getConversations();

  //       final List<ChatModel> loaded = convs.map((c) {
  //         final other = c['other_user'];
  //         return ChatModel(
  //           name: other['fullname'],
  //           lastMessage: c['last_message'] ?? '',
  //           time: _formatTime(c['last_message_at']),
  //           isOnline: false, // مفيش isOnline في الـ API دلوقتي
  //         );
  //       }).toList();
  //  setState(() {
  //         _chats = loaded;
  //         filteredChats = loaded;
  //         _loading = false;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         _error = e.toString();
  //         _loading = false;
  //       });
  //     }
  //   }
  String _formatTime(String? timeStr) {
    // حولي التاريخ لـ "10:42 AM" أو "Yesterday"
    if (timeStr == null) return '';
    final t = DateTime.tryParse(timeStr);
    if (t == null) return '';
    return "${t.hour}:${t.minute}";
  }

  void searchChats(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredChats = _chats;
      });
      return;
    }

    final results = _chats.where((chat) {
      return chat.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredChats = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Supplier Chats")),
      body: Column(
        children: [
          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                searchChats(value);
              },
              decoration: InputDecoration(
                hintText: "Search Chats",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📋 Chat List
          Expanded(
            child: ListView.builder(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];

                return ListTile(
                  leading: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color.fromARGB(255, 236, 232, 232),
                      ),

                      if (chat.isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // ✅ عرض عدد الرسائل غير المقروءة
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(chat.time),
                  onTap: () {
                    final id = _conversationIds[index];
                    if (id == null) return;
                    
                    final shouldRefrech = Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatName: chat.name,
                          conversationId: id,
                        ),
                      ),
                    );
                    if(shouldRefrech == true){
                      _fetchConversations();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
