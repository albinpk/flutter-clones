import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dummy_data/app_user.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/extensions/platform_type.dart';
import '../../../../utils/themes/custom_colors.dart';
import '../widgets/friends_list_app_bar_desktop.dart';
import '../widgets/friends_list_tile.dart';

class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform.isMobile
        ? const _FriendsViewMobile()
        : const _FriendsViewDesktop();
  }
}

class _FriendsViewMobile extends StatelessWidget {
  const _FriendsViewMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey('chats-view-key'),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          if (context.select((AppUser user) => user.friends.isEmpty))
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _NoFriendsFound(),
            )
          else
            const SliverPadding(
              padding: EdgeInsets.only(top: 6, bottom: 83),
              sliver: _FriendsListView(),
            ),
        ],
      ),
    );
  }
}

class _FriendsViewDesktop extends StatelessWidget {
  const _FriendsViewDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FriendsListAppBarDesktop(),
      body: context.select((AppUser user) => user.friends.isEmpty)
          ? const _NoFriendsFound()
          : const _FriendsListView(),
    );
  }
}

class _FriendsListView extends StatelessWidget {
  const _FriendsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final friendsLength = context.select<AppUser, int>(
      (user) => user.friends.length,
    );
    return Theme.of(context).platform.isMobile
        ? SliverFixedExtentList(
            itemExtent: 76,
            delegate: SliverChildBuilderDelegate(
              _itemBuilder,
              childCount: friendsLength,
            ),
          )
        : ListView.builder(
            itemCount: friendsLength,
            itemExtent: 76,
            itemBuilder: _itemBuilder,
          );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final currentFriendId = context.read<AppUser>().friends[index];
    final user = context
        .read<List<User>>()
        .singleWhere((user) => user.id == currentFriendId);
    return RepositoryProvider.value(
      value: user,
      child: const FriendsListTile(),
    );
  }
}

class _NoFriendsFound extends StatelessWidget {
  const _NoFriendsFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Start new chat',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: CustomColors.of(context).onBackgroundMuted,
            ),
      ),
    );
  }
}