import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom(
      {super.key,
      this.isReminder = true,
      this.isSearch = true,
      this.isNotification = true,
      this.bottomAppbar,
      required this.appBarHeight});

  final TabBar? bottomAppbar;
  final bool isReminder;
  final bool isSearch;
  final bool isNotification;
  final double appBarHeight;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorsByTheme(context).backgroundTheme,
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: appBarHeight,
      title: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: spacing8,
          ),
          Text('eco_chat_bot'),
        ],
      ),
      titleTextStyle: AppTextStyle(context).getDefaultStyle().fontLeading1.bold,
      centerTitle: false,
      actions: [
        if (isReminder)
          IconButton(
            icon: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColor.mainColor1,
            ),
            onPressed: () {},
          ),
        if (isSearch)
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppColor.mainColor1,
            ),
            onPressed: () {
              // Navigator.pushNamed(context, SearchTopicView.routeName);
            },
          ),
        if (isNotification)
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColor.mainColor1,
            ),
            onPressed: () {},
          ),
      ],
      bottom: bottomAppbar != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(appBarHeight),
              child: bottomAppbar!)
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
