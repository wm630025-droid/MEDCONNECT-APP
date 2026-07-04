import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'api_service.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  bool _initialized = false;

  // FIX 4: reset() so init() can re-run after logout with a fresh token
  void reset() {
    _initialized = false;
  }

  Future<void> init() async {
    if (_initialized) return;

    // FIX 4: guard — don't init if token isn't ready yet
    if (ApiService.token == null || ApiService.token!.isEmpty) {
      print('⚠️ PusherService.init() skipped — token not ready yet');
      return;
    }

    await _pusher.init(
      apiKey: 'b68b2768ec261def64e1', // replace with your key
      cluster: 'eu',
      onConnectionStateChange: (current, previous) {
        print('Pusher: $previous -> $current');
      },
      onError: (message, code, error) {
        print('Pusher Error: $message');
      },
      onAuthorizer: (channelName, socketId, options) async {
        final response = await http.post(
          Uri.parse(
            'https://medconnect-one-pi.vercel.app/broadcasting/auth',
          ),
          headers: {
            'Authorization': 'Bearer ${ApiService.token}',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'socket_id': socketId,
            'channel_name': channelName,
          },
        );

        print('Auth status: ${response.statusCode}');
        print('Auth body: ${response.body}');
        print('Channel: $channelName');

        return jsonDecode(response.body);
      },
    );

    await _pusher.connect();
    _initialized = true;
    print('✅ Pusher connected');
  }

  Future<void> subscribe(
    int conversationId,
    Function(Map<String, dynamic>) onMessage,
  ) async {
    // FIX 2: await subscribe properly
    await _pusher.subscribe(
      channelName: 'private-conversation.$conversationId',
      onEvent: (event) {
        if (event.eventName == 'NewMessageSent') {
          onMessage(jsonDecode(event.data));
        }
      },
    );
    print('✅ Subscribed to private-conversation.$conversationId');
  }

  Future<void> unsubscribe(int conversationId) async {
    await _pusher.unsubscribe(
      channelName: 'private-conversation.$conversationId',
    );
    print('🔕 Unsubscribed from private-conversation.$conversationId');
  }

  Future<void> disconnect() async {
    await _pusher.disconnect();
    _initialized = false;
  }
}
