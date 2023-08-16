import 'package:flutter/material.dart';

final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.amber,
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.amber,
    disabledColor: Colors.grey,
  ),
);

final ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blue,
    disabledColor: Colors.grey,
  ),
);
