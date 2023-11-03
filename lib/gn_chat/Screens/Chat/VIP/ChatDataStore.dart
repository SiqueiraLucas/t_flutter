abstract class ChatDataStoreInterface {
  String get parameters;
}

class ChatDataStore implements ChatDataStoreInterface {
  @override String parameters;

  ChatDataStore({required this.parameters});
}