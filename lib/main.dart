import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'AppBuilder.dart';

final AppBuilder appBuilder = AppBuilder();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final initialRoute = "/empty";

  @override Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        // final modelString = '/chat,{"recipient":{"email":"Sebastian@example.com","id":"654321","photoUrl":"https://talkjs.com/images/avatar-5.jpg","name":"Sebastian"},"sender":{"email":"alice@example.com","id":"123456","photoUrl":"https://talkjs.com/images/avatar-1.jpg","name":"Alice"}}';
        final modelString = settings.name;
        if (modelString != null && modelString != '/') {
          final route = getRouteFrom(modelString);
          final parameters = getParametersFrom(modelString);

          return getInitialView(route, parameters);
        } else {
          return getInitialView(initialRoute, '');
        }
      },
    );
  }

  String getRouteFrom(String modelString) {
    int commaIndex = modelString.indexOf(",");

    if (commaIndex != -1) {
      return modelString.substring(0, commaIndex);
    } else {
      return modelString;
    }
  }

  String getParametersFrom(String modelString) {
    int commaIndex = modelString.indexOf(",");

    if (commaIndex != -1) {
      return modelString.substring(commaIndex + 1);
    } else {
      return '';
    }
  }

  MaterialPageRoute getInitialView(String route, String parametersString) {
    switch (route) {
      case "/chat":
        return MaterialPageRoute(builder: (context) => appBuilder.chatView(parametersString));
      case "/empty":
        return MaterialPageRoute(builder: (context) => appBuilder.emptyView());
      default:
        return MaterialPageRoute(builder: (context) => appBuilder.onboardingView(parametersString));
    }
  }
}