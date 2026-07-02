import 'dart:convert';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;

  PusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  bool _initialized = false;

  Future<void> init(String token) async {
    if (_initialized) return;

    await _pusher.init(
      apiKey: "YOUR_PUSHER_KEY",
      cluster: "YOUR_CLUSTER",

      onConnectionStateChange: (current, previous) {
        print("Pusher: $previous -> $current");
      },

      onError: (message, code, error) {
        print("Pusher Error: $message");
      },

      onAuthorizer: (channelName, socketId, options) async {
        return {
          "headers": {
            "Authorization": "Bearer $token"
          }
        };
      },
    );

    await _pusher.connect();

    _initialized = true;
  }

  Future<void> subscribeToConversation(
      int conversationId,
      Function(Map<String, dynamic>) onMessage) async {

    await _pusher.subscribe(
      channelName: "private-conversation.$conversationId",

      onEvent: (event) {
        if (event.eventName == "message.sent") {
          final data = jsonDecode(event.data);

          onMessage(data);
        }
      },
    );
  }

  Future<void> unsubscribeFromConversation(int conversationId) async {
    await _pusher.unsubscribe(
      channelName: "private-conversation.$conversationId",
    );
  }
}