// app/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );
}