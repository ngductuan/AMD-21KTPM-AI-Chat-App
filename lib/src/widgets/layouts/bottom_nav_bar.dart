import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class AppBottomNavBar extends StatefulWidget {
  final void Function(int) onTabChanged;

  const AppBottomNavBar({super.key, required this.onTabChanged});

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  BottomNavigationBarItem _bottomNavItem(
      String label, String icoBefore, String icoAfter, Color? color) {
    return BottomNavigationBarItem(
        icon: ImageHelper.loadFromAsset(
          icoBefore,
          width: iconBottomNav26,
          height: iconBottomNav26,
          tintColor: ColorConst.textBlackColor,
        ),
        activeIcon: ImageHelper.loadFromAsset(
          icoAfter,
          width: iconBottomNav26,
          height: iconBottomNav26,
          tintColor: color,
        ),
        label: label);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Platform.isAndroid ? bottomNavHeightAndroid : bottomNavHeightIOS,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            // color: colorsByTheme(context).hintTextColor ?? Colors.black,
            color: ColorConst.textGrayColor,
            blurRadius: 2,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, // Remove splash color
          highlightColor: Colors.transparent, // Remove highlight color
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 30,
          // selected label
          fixedColor: ColorConst.textHighlightColor,
          type: BottomNavigationBarType.fixed,
          // unselected label
          unselectedItemColor: ColorConst.textGrayColor,
          unselectedFontSize: fontSize12,
          selectedFontSize: fontSize14,
          backgroundColor: ColorConst.backgroundWhiteColor,
          // selectedItemColor: Colors.red,
          // selectedItemColor: const Color(0xFF42A5F5),
          onTap: (index) {
            // Update the index when a bottom navigation item is tapped.
            _currentIndex = index;
            widget.onTabChanged(_currentIndex);
            // AppToast(
            //   context: context,
            //   message: TextDoc.txtAddFavoriteSuccess,
            //   mode: AppToastMode.warning,
            // ).show(context);
          },
          items: [
            _bottomNavItem('Chat', AssetPath.chatBeforeNavIcon,
                AssetPath.chatAfterNavIcon, ColorConst.textHighlightColor),
            _bottomNavItem('Explore', AssetPath.searchBeforeNavIcon,
                AssetPath.searchAfterNavIcon, ColorConst.textHighlightColor),
            _bottomNavItem(
              'Data',
              AssetPath.dataBeforeNavIcon,
              AssetPath.dataAfterNavIcon,
              ColorConst.textHighlightColor,
            ),
            _bottomNavItem('Add', AssetPath.addBeforeNavIcon,
                AssetPath.addAfterNavIcon, ColorConst.textHighlightColor),
            _bottomNavItem('Message', AssetPath.bellBeforeNavIcon,
                AssetPath.bellAfterNavIcon, ColorConst.textHighlightColor),
            _bottomNavItem('Me', AssetPath.meBeforeNavIcon,
                AssetPath.meAfterNavIcon, ColorConst.textHighlightColor),
          ],
        ),
      ),
    );
  }
}
