import 'package:flutter/cupertino.dart';
import 'Dependencies.dart';
import '../Screens/Chat/ChatInitializer.dart';

final class Feature {
  final Dependencies _dependencies;

  Feature({
    required Dependencies dependencies
  }): _dependencies = dependencies;

  @override Widget initialView(String parameters) {
    return ChatInitializer.createView(_dependencies, parameters);
  }
}