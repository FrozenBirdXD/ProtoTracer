import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/ble_connection_screen.dart';
import '../screens/protogen_settings_screen.dart';
import '../screens/fun_screen.dart';
import '../screens/app_settings_screen.dart';
import '../screens/debug_console_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String bleConnection = '/ble-connection';
  static const String protoSettings = '/protogen-settings';
  static const String fun = '/fun';
  static const String appSettings = '/app-settings';
  static const String debugConsole = '/debug-console';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    bleConnection: (context) => const BleConnectionScreen(),
    protoSettings: (context) => const ProtoSettingsScreen(),
    fun: (context) => const FunScreen(),
    appSettings: (context) => const AppSettingsScreen(),
    debugConsole: (context) => const DebugConsoleScreen(),
  };
}