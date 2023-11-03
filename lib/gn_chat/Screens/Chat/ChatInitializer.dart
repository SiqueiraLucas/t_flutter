import 'package:flutter/material.dart';
import '../../Module/Dependencies.dart';
import 'VIP/ChatInteractor.dart';
import 'VIP/ChatPresenter.dart';
import 'VIP/ChatDataStore.dart';
import 'VIP/ChatView.dart';

final class ChatInitializer {
  static Widget createView(Dependencies dependencies, String parameters) {
    final view = ChatView();
    final presenter = ChatPresenter(view: view);
    final dataStore = ChatDataStore(parameters: parameters);
    final interactor = ChatInteractor(
        presenter: presenter,
        dataStore: dataStore
    );

    view.setup(interactor);

    return view;
  }
}