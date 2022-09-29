import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/themes/custom_colors.dart';
import '../../../../chat.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<ChatRoomBloc>().add(const ChatRoomClose());
        return true;
      },
      child: Scaffold(
        backgroundColor: CustomColors.of(context).chatRoomBackground,
        appBar: const ChatRoomAppBar(),
        body: Column(
          children: const [
            Expanded(
              child: ChatRoomMessagesView(),
            ),
            ChatInputArea(),
          ],
        ),
      ),
    );
  }
}
