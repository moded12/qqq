// 📄 lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFecf0f1),
  fontFamily: 'Cairo',
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Colors.deepOrange, // اللون الموحد للأيقونات
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF34495e),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Color(0xFF34495e)),
      foregroundColor: MaterialStatePropertyAll(Colors.white),
      padding: MaterialStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textStyle: MaterialStatePropertyAll(
        TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),
  ),
  textTheme: GoogleFonts.cairoTextTheme(),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF2c3e50),
  fontFamily: 'Cairo',
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(
    secondary: Colors.deepOrange, // اللون البرتقالي للأيقونات
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF34495e),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cairo',
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF34495e),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  ),
  tabBarTheme: TabBarThemeData(
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
      padding: MaterialStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textStyle: MaterialStatePropertyAll(
        TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    ),
  ),
  textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
);
