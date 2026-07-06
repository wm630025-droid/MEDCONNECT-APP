import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medconnect_app/services/api_service.dart';

import 'chatScreen.dart';
import 'shimmerSkeleton.dart';

class ChatModel {
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unreadCount;
  final String? imageUrl;

  ChatModel({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.unreadCount,
    this.imageUrl,
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
   List<int> receiverIds = [];
  //Timer? _refreshTimer;
bool _isFirstLoad = true;
Timer? _pollTimer;
bool _isLoading = true;
  @override
  void initState()  {
    super.initState();
    _fetchConversations();
_startPolling();
    filteredChats = _chats;

    // _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
    //   if(mounted) _fetchConversations();
    // });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    //_refreshTimer?.cancel();
    super.dispose();
  }
  void _startPolling() {
  _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (mounted) {
      _fetchConversations(forceRefresh: true);
    }
  });
}

  Future<void> _fetchConversations({bool forceRefresh = false}) async {
     if (ApiService.cachedConversations != null &&
      !forceRefresh &&
      !_isFirstLoad) {
    setState(() {
      _chats = ApiService.cachedConversations!;
      filteredChats = _chats;
      _loading = false;
    });
    return;
  }
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final List<dynamic> convs = await _api.getConversations();

      final List<ChatModel> loaded = [];
      List<int> ids = [];

      for (var conv in convs) {
        if (!mounted) return; // ✅ أضف دي في أول الـ loop

        final int convId = conv['id'];
        final other = conv['other_user'];
        print('conversation ID added : $convId');
        String? imageUrl;
        if (other['supplier'] != null &&
            other['supplier']['company_image_url'] != null) {
          imageUrl = other['supplier']['company_image_url'];
        }

        final messages = await _api.getMessages(convId);

        if (!mounted) return; // ✅ وبعد كل await

        int unreadCount = 0;
        String lastMessage = '';
        String lastTime = '';

        for (var msg in messages) {
          final isMe = msg['sender']['role'] == 'doctor';
          final readAt = msg['read_at'];

          if (!isMe && readAt == null) {
            unreadCount++;
          }

          if (msg == messages.last) {
            lastMessage = msg['message']??'';
            lastTime = _formatTime(msg['created_at']);
          }
        }

        loaded.add(
          ChatModel(
            name: other['supplier']['company_name'],
            lastMessage: lastMessage,
            time: lastTime,
            isOnline: false,
            unreadCount: unreadCount,
            imageUrl: imageUrl,
          ),
        );
        ids.add(convId);
        receiverIds.add(other['id']);
      }
        ApiService.cachedConversations = loaded;
    ApiService.cachedConversationsTime = DateTime.now();
      if (mounted) {
        setState(() {
          _chats = loaded;
          filteredChats = loaded;
          _conversationIds = ids;
          receiverIds = receiverIds;
          _loading = false;
          _isFirstLoad = false;
        });
    //      print('📦 _chats length: ${_chats.length}');
    // print('📦 filteredChats length: ${filteredChats.length}');
    //   print('📦 conversationIds: $_conversationIds');
    //   print('📦 receiverIds: $receiverIds');
    //   print('loaded ${loaded.length} chats');
      }
     
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
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
  Widget _buildShimmer() {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
             ShimmerSkeleton(width: 50, height: 50, borderRadius: BorderRadius.circular(25)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(width: 120, height: 16, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 4),
                  ShimmerSkeleton(width: 200, height: 14, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ),
            ShimmerSkeleton(width: 40, height: 14, borderRadius: BorderRadius.circular(4)),
          ],
        ),
      );
    },
  );
}
  String _formatTime(String? timeStr) {
    // حولي التاريخ لـ "10:42 AM" أو "Yesterday"
    if (timeStr == null) return '';
    final t = DateTime.tryParse(timeStr);
    if (t == null) return '';
    return "${t.hour}:${t.minute}";
  }

  void searchChats(String query) {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          filteredChats = _chats;
        });
      }
      return;
    }

    final results = _chats.where((chat) {
      return chat.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    if (mounted) {
      setState(() {
        filteredChats = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 build: filteredChats length = ${filteredChats.length}');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Supplier Chats"),
        backgroundColor: Colors.white,
      ),
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
            child: _loading && _chats.isEmpty
              ? _buildShimmer() // ✅ Skeleton
              :  ListView.builder(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];

                return ListTile(
                  leading: Stack(
                    children: [
                       CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            chat.imageUrl != null && chat.imageUrl!.isNotEmpty
                            ? NetworkImage(chat.imageUrl!)
                            : null,
                        child: chat.imageUrl == null || chat.imageUrl!.isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
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
                  onTap: () async {
                    print('========== TAP ON CHAT ==========');
                    print('📦 Index: $index');
                    print('📦 conversationIds: $_conversationIds');
                    print('📦 receiverIds: $receiverIds');
                    final id = _conversationIds[index];
                    final receiverId = receiverIds[index];
                    //   if (id == null || receiverId == null) return;
                    print('📦 id: $id');
                    print('📦 receiverId: $receiverId');
                    final shouldRefrech = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatName: chat.name,
                          conversationId: id,
                          receiverId:
                              receiverId, // ممكن تحتاجي ID المورد مش المحادثة
                        ),
                      ),
                    );
                    if (shouldRefrech == true) {
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
