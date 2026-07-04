import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'api_service.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;

  PusherService._internal();

  final PusherChannelsFlutter _pusher =
      PusherChannelsFlutter.getInstance();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _pusher.init(
      apiKey: "b68b2768ec261def64e1",
      cluster: "eu",

      onConnectionStateChange: (current, previous) {
        print("Pusher: $previous -> $current");
      },

      onError: (message, code, error) {
        print("Pusher Error: $message");
      },

      onAuthorizer: (channelName, socketId, options) async {
       final response = await http.post(
  Uri.parse(
    'https://medconnect-one-pi.vercel.app/broadcasting/auth',
  ),
  headers: {
    "Authorization": "Bearer ${ApiService.token}",
    "Accept": "application/json",
    "Content-Type": "application/x-www-form-urlencoded",
  },
  body: {
    "socket_id": socketId,
    "channel_name": channelName,
  },
);

print(response.statusCode);
print(response.body);

        return jsonDecode(response.body);
      },
    );

    await _pusher.connect();

    _initialized = true;
  }

  Future<void> subscribe(
      int conversationId,
      Function(Map<String, dynamic>) onMessage) async {

    await _pusher.subscribe(
      channelName:
          "private-conversation.$conversationId",

      onEvent: (event) {

        if (event.eventName == "NewMessageSent") {
          onMessage(jsonDecode(event.data));
        }
      },
    );
  }

  Future<void> unsubscribe(int conversationId) async {
    await _pusher.unsubscribe(
      channelName:
          "private-conversation.$conversationId",
    );
  }
}