import 'ChatView.dart' show ChatViewInterface;
import '../Models/ChatViewModel.dart';
import '../Models/ChatModel.dart';
import 'package:talkjs_flutter/talkjs_flutter.dart';

abstract class ChatPresenterInterface {
  void present(ChatModel chatModel);
}

final class ChatPresenter implements ChatPresenterInterface {
  final ChatViewInterface _view;

  ChatPresenter({
    required ChatViewInterface view
  }) : _view = view;

  @override void present(ChatModel chatModel) {
    ChatViewModel viewModel = ChatViewModel(chatBox: _createChatBox(chatModel));
    _view.render(viewModel);
  }

  ChatBox _createChatBox(ChatModel chatModel) {
    final session = Session(appId: 'tJ0nS7zd');

    final sender = createChatUser(
        session,
        chatModel.sender
    );

    final recipient = createChatUser(
        session,
        chatModel.recipient
    );

    session.me = sender;

    final conversation = session.getConversation(
      id: Talk.oneOnOneId(sender.id, recipient.id),
      participants: {Participant(sender), Participant(recipient)},
    );

    return ChatBox(
      session: session,
      conversation: conversation,
    );
  }

  User createChatUser(Session session, ChatUserModel model) {
    return session.getUser(
      id: model.id,
      name: model.name,
      email: [model.email],
      photoUrl: model.photoUrl,
      role: 'default',
    );
  }
}