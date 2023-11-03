import 'package:flutter/material.dart';
import '../Models/ChatViewModel.dart';
import 'package:flutter/services.dart';

abstract class ChatViewInterface implements StatefulWidget {
  void setup(ChatViewDelegate delegate);
  void render(ChatViewModel viewModel);
}

abstract class ChatViewDelegate {
}

final class ChatView extends StatefulWidget implements ChatViewInterface {
  ChatViewModel _chatViewModel = ChatViewModel.empty;

  late ChatViewDelegate? _delegate;
  late Function _reloadLayout;

  ChatView({
    Key? key,
    Function? reloadLayout
  }) : super(key: key) {
    _reloadLayout = reloadLayout ?? () {};
  }

  @override void setup(ChatViewDelegate delegate) {
    _delegate = delegate;
  }

  @override void render(ChatViewModel viewModel) {
    _chatViewModel = viewModel;
    _reloadLayout();
  }

  @override ChatViewState createState() => ChatViewState();
}

final class ChatViewState extends State<ChatView> {
  @override void dispose() {
    widget._delegate = null;
    widget._reloadLayout = () {};
    super.dispose();
  }

  void _reloadLayout() {
    setState(() {});
  }

  @override Widget build(BuildContext context) {
    widget._reloadLayout = _reloadLayout;

    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Chat"),
          ),
          body: widget._chatViewModel.chatBox,
        )
    );
  }
}