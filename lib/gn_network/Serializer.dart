mixin Serializer<T> {
  T serialize(Map<String, dynamic> json);
  List<T> serializeList(List<dynamic> jsonList) {
    return jsonList.map((json) => serialize(json)).toList();
  }
}