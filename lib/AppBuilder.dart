import 'package:flutter/material.dart';
import '../gn_chat/Module/Dependencies.dart' as chat;
import '../gn_chat/Module/Feature.dart' as chat;
import 'package:flutter/services.dart';

final class AppBuilder {
  late chat.Dependencies chatDependencies = chat.Dependencies();

  late chat.Feature chatFeature = chat.Feature(dependencies: chatDependencies);

  Widget chatView(String parametersString) {
    return chatFeature.initialView(parametersString);
  }

  Widget onboardingView(String displayText) {
    return OnboardingView(displayText);
  }

  Widget emptyView() {
    return Container();
  }
}

class OnboardingView extends StatefulWidget {
  String _displayText;

  final MethodChannel _channel = MethodChannel('com.example/my_channel');

  OnboardingView(String displayText) : _displayText = displayText;

  @override OnboardingViewState createState() => OnboardingViewState();
}

class OnboardingViewState extends State<OnboardingView> {
  void sendMessage() {
    widget._channel.invokeMethod('enviarInformacoes', {"chave": "valor"});
    SystemNavigator.pop();
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget._displayText),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendMessage();
              },
              child: Text('Executar Função'),
            ),
          ],
        ),
      ),
    );
  }
}

