import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chats_bloc.dart';
import '../views/contacts_view.dart';

class NewChatSelectionScreen extends StatelessWidget {
  const NewChatSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<ChatsBloc>().add(const ChatsContactsScreenPopped());
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Select contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: const ContactsView(),
    );
  }
}
