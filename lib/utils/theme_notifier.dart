import 'package:flutter/material.dart';

// Global Singleton sederhana untuk Theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);