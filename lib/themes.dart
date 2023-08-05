import 'package:flutter/material.dart';

final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: Colors.amber,
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.amber,
    disabledColor: Colors.grey,
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
  ),
);

final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blue,
    disabledColor: Colors.grey,
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.black),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
  ),
);
