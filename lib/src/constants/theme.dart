import 'package:flutter/material.dart';

import 'colors.dart';

// Use this function to get color
AppColor colorsByTheme(context) => Theme.of(context).extension<AppColor>()!;

bool isDarkThemeHold = false;

// Only use theme to config
ThemeData getThemeData(
  BuildContext context, {
  bool isDarkTheme = false,
}) {
  // isDarkThemeHold
  isDarkThemeHold = isDarkTheme;

  return ThemeData(
    extensions: <AppColor>[
      AppColor(
        defaultFont:
            isDarkTheme ? AppColor.defaultFontDark : AppColor.defaultFontLight,
        refectDefaultFont:
            isDarkTheme ? AppColor.defaultFontLight : AppColor.defaultFontDark,
        icon: isDarkTheme
            ? AppColor.secondary
            : const Color.fromARGB(255, 229, 188, 188),
        iconBackground: isDarkTheme ? AppColor.background : AppColor.secondary,
        backgroundTheme:
            isDarkTheme ? AppColor.backgroundDark : AppColor.backgroundLight,
        backgroundCardHistoryWallet:
            isDarkTheme ? AppColor.backgroundLogo : AppColor.mainColor2Surface,
        backgroundAvatar:
            isDarkTheme ? AppColor.backgroundLogo : AppColor.mainColor2,
        hintTextColor:
            isDarkTheme ? AppColor.defaultFontContainer : AppColor.shadow,
        tabTitleColor:
            isDarkTheme ? AppColor.container : AppColor.defaultFontContainer,
        backgroundCardsChip:
            isDarkTheme ? AppColor.darkModeContainer : AppColor.white,
        expansionIcon: isDarkTheme ? AppColor.background : AppColor.shadow,
        selectableChipBg:
            isDarkTheme ? AppColor.backgroundDark : Colors.transparent,
        rippleColor: isDarkTheme
            ? const Color.fromARGB(50, 98, 95, 95)
            : const Color.fromARGB(21, 98, 95, 95),
      ),
    ],
    scaffoldBackgroundColor:
        isDarkTheme ? AppColor.backgroundDark : AppColor.backgroundLight,
    textTheme: Theme.of(context)
        .textTheme
        .copyWith(
          titleSmall:
              Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 11),
        )
        .apply(
          fontFamily: 'NotoSans', //NotoSans
          bodyColor: isDarkTheme
              ? AppColor.defaultFontDark
              : AppColor.defaultFontLight,
          displayColor: isDarkTheme
              ? AppColor.defaultFontDark
              : AppColor.defaultFontLight,
        ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(
          isDarkTheme ? Colors.orange : Colors.purple),
    ),
    listTileTheme: ListTileThemeData(
        iconColor: isDarkTheme ? Colors.orange : Colors.purple),
    appBarTheme: AppBarTheme(
        backgroundColor:
            isDarkTheme ? AppColor.backgroundDark : AppColor.backgroundLight,
        iconTheme:
            IconThemeData(color: isDarkTheme ? Colors.white : Colors.black54)),
    useMaterial3: true,
    fontFamily: 'NotoSans', //Dongle
    unselectedWidgetColor:
        isDarkTheme ? AppColor.shadow : AppColor.backgroundDark,
  );
}
