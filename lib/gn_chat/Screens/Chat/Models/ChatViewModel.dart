import 'package:flutter/material.dart';

final class ChatViewModel {
  final Widget chatBox;

  static ChatViewModel empty = ChatViewModel(
    chatBox: Container(),
  );

  ChatViewModel({
    required this.chatBox,
  });
}