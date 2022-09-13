import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../models/user_model.dart';
import '../../../../bloc/chats_bloc.dart';
import '../widgets/chat_room_app_bar.dart';
import '../widgets/chat_input_area.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<ChatsBloc>().add(const ChatsScreenCloseButtonPressed());
        return false;
      },
      child: Scaffold(
        appBar: const ChatRoomAppBar(),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Messages with ${context.select((User user) => user.name)}',
                ),
              ),
            ),
            const ChatInputArea(),
          ],
        ),
      ),
    );
  }
}