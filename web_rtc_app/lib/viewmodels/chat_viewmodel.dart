import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/webrtc_service.dart';
import '../models/chat_message.dart';
import 'webrtc_viewmodel.dart';

/// ViewModel for chat functionality
class ChatViewModel extends StateNotifier<ChatState> {
  final WebRTCService _webrtcService;

  ChatViewModel(this._webrtcService) : super(ChatState.initial()) {
    _setupListeners();
  }

  void _setupListeners() {
    _webrtcService.messageStream.listen((message) {
      final messages = List<ChatMessage>.from(state.messages)..add(message);
      state = state.copyWith(messages: messages);
    });
  }

  /// Sends a chat message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final message = ChatMessage.create(text.trim());
      
      // Add to local messages immediately
      final messages = List<ChatMessage>.from(state.messages)..add(message);
      state = state.copyWith(messages: messages);

      // Send over data channel
      await _webrtcService.sendMessage(message);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clears error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clears all messages
  void clearMessages() {
    state = ChatState.initial();
  }
}

/// State class for Chat ViewModel
class ChatState {
  final List<ChatMessage> messages;
  final String? error;

  ChatState({
    required this.messages,
    this.error,
  });

  factory ChatState.initial() {
    return ChatState(messages: []);
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

/// Provider for ChatViewModel
final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final webrtcService = ref.watch(webrtcServiceProvider);
  return ChatViewModel(webrtcService);
});

