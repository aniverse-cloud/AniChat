import 'package:flutter/cupertino.dart';

class AnChatTheme {
  static const Color primaryBlue = CupertinoColors.activeBlue;
  static const Color backgroundLight = CupertinoColors.systemGroupedBackground;
  static const Color backgroundDark = CupertinoColors.black;

  static CupertinoThemeData lightTheme = const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundLight,
    barBackgroundColor: Color(0xCCFFFFFF), // Translucent for blur effect
    textTheme: CupertinoTextThemeData(
      navTitleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        color: CupertinoColors.black,
      ),
    ),
  );

  static CupertinoThemeData darkTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundDark,
    barBackgroundColor: Color(0xCC1C1C1E), // Translucent for blur effect
    textTheme: CupertinoTextThemeData(
      navTitleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        color: CupertinoColors.white,
      ),
    ),
  );
}
