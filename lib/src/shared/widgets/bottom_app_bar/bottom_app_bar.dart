import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/shared/widgets/tab_indicator/tab_indicator.dart';
import 'package:flutter/material.dart';

class BottomAppBarCustom extends StatelessWidget {
  const BottomAppBarCustom(
      {super.key, required this.tabController, required this.tabNames});

  final TabController tabController;
  final List tabNames;

  TabBar buildTabBar(BuildContext context) {
    return TabBar(
      indicator: LineTabIndicator(
        color: AppColor.secondary,
        height: spacing2,
      ),
      dividerColor: AppColor.shadow,
      indicatorColor: AppColor.secondary,
      labelColor: AppColor.secondary,
      unselectedLabelColor: colorsByTheme(context).tabTitleColor,
      controller: tabController,
      isScrollable: tabNames.length > 3 ? true : false,
      tabs: tabNames
          .map((name) => Tab(
                child:
                    Text(name, style: AppTextStyle(context).getDefaultStyle()),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
