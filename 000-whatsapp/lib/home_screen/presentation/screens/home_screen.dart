import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/whats_app_user_model.dart';
import '../../../utils/extensions/platform_type.dart';
import '../../../utils/themes/custom_colors.dart';
import '../../../features/chat/chat.dart';
import '../views/default_chat_view.dart';
import '../widgets/app_bar_mobile.dart';
import '../widgets/both_axis_scroll_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform.isMobile
        ? const _HomeScreenMobile()
        : const _HomeScreenDesktop();
  }
}

class _HomeScreenMobile extends StatelessWidget {
  const _HomeScreenMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: _chatBlocListener,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: const AppBarMobile(),
              ),
            ],
            body: const TabBarView(
              children: [
                RecentChatsView(),
                Center(child: Text('STATUS')),
                Center(child: Text('CALLS')),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.message),
            onPressed: () {
              // context
              //     .read<ChatsBloc>()
              //     .add(const ChatsNewChatButtonPressed());
            },
          ),
        ),
      ),
    );
  }

  void _chatBlocListener(BuildContext context, ChatState state) {
    if (state is ChatRoomOpenState) {
      final user = context.read<List<WhatsAppUser>>().singleWhere(
            (user) => user == state.user,
          );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RepositoryProvider.value(
            value: user,
            child: const ChatRoomScreen(),
          ),
        ),
      );
    }
  }
}

class _HomeScreenDesktop extends StatelessWidget {
  const _HomeScreenDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const padding = 20.0;
    final mainView = Center(
      child: BothAxisScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: max(min(screenSize.width, 1600), 750),
            maxHeight: max(screenSize.height, 510),
          ),
          child: Padding(
            padding: screenSize.width > 1440
                ? const EdgeInsets.all(padding).copyWith(
                    bottom: screenSize.height > 510 ? padding : 0,
                  )
                : EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, constrains) => Row(
                children: [
                  SizedBox(
                    width: _calculateWidth(constrains.maxWidth),
                    child: BlocBuilder<ChatBloc, ChatState>(
                      // buildWhen: (previous, current) {
                      //   return current is ChatsContactListOpened ||
                      //       current is ChatsContactListClosed;
                      // },
                      builder: (context, state) {
                        // if (state is ChatsContactListOpened) {
                        //   return const UsersScreen();
                        // }
                        return const RecentChatsView();
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      // buildWhen: (previous, current) {
                      //   return (current is ChatsRoomOpened ||
                      //           current is ChatsRoomClosed) &&
                      //       current != previous;
                      // },
                      builder: (context, state) {
                        if (state is ChatRoomOpenState) {
                          final user =
                              context.read<List<WhatsAppUser>>().singleWhere(
                                    (user) => user == state.user,
                                  );
                          return RepositoryProvider.value(
                            value: user,
                            child: const ChatRoomScreen(),
                          );
                        }
                        return const DefaultChatView();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (Theme.of(context).brightness == Brightness.light &&
        screenSize.width > 1440) {
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: min(screenSize.height, kToolbarHeight * 2 + padding),
                child: ColoredBox(
                  color: CustomColors.of(context).primary!,
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
          mainView,
        ],
      );
    } else {
      return ColoredBox(
        color: CustomColors.of(context).background!,
        child: mainView,
      );
    }
  }

  double _calculateWidth(double maxWidth) {
    final double widthFactor;
    if (maxWidth > 1200) {
      widthFactor = 0.3;
    } else if (maxWidth > 1000) {
      widthFactor = 0.35;
    } else {
      widthFactor = 0.4;
    }
    return maxWidth * widthFactor;
  }
}