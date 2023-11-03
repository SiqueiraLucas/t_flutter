import '../../../../gn_network/Serializer.dart';

class ChatModel {
  final ChatUserModel sender;
  final ChatUserModel recipient;

  ChatModel({
    required this.sender,
    required this.recipient
  });
}

class ChatModelSerializer with Serializer<ChatModel> {
  @override ChatModel serialize(Map<String, dynamic> json) {
    return ChatModel(
      sender: ChatUserModelSerializer().serialize(json["sender"]),
      recipient: ChatUserModelSerializer().serialize(json["recipient"]),
    );
  }
}

final class ChatUserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;

  static ChatUserModel empty = ChatUserModel(
    id: "",
    name: "",
    email: "",
    photoUrl: "",
  );

  ChatUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
  });
}

class ChatUserModelSerializer with Serializer<ChatUserModel> {
  @override ChatUserModel serialize(Map<String, dynamic> json) {
    return ChatUserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        photoUrl: json["photoUrl"]
    );
  }
}