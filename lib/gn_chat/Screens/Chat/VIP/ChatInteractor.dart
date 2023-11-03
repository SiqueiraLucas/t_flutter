import 'dart:convert';
import 'ChatView.dart' show ChatViewDelegate;
import 'ChatPresenter.dart' show ChatPresenterInterface;
import 'ChatDataStore.dart' show ChatDataStoreInterface;
import '../Models/ChatModel.dart';

final class ChatInteractor implements ChatViewDelegate {
  final ChatPresenterInterface _presenter;
  final ChatDataStoreInterface _dataStore;

  ChatInteractor({
    required ChatPresenterInterface presenter,
    required ChatDataStoreInterface dataStore,
  }) : _presenter = presenter,
        _dataStore = dataStore
  {
    build();
  }

  void build() {
    try {
      final ChatModelSerializer serializer = ChatModelSerializer();
      Map<String, dynamic> jsonMap = json.decode(_dataStore.parameters);
      final chatModel = serializer.serialize(jsonMap);

      print(chatModel.sender.email);

      _presenter.present(chatModel);
    } catch (_) {
      print("Error");
    }
  }
}