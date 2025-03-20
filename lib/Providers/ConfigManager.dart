import 'dart:convert';
import 'package:flutter_application_1/models/ServerConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  static const String _configKey = "serverConfig";

  // Guardar configuración
  static Future<void> saveConfig(ServerConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonConfig = jsonEncode(config.toJson());

    await prefs.setString(_configKey, jsonConfig);

  }

  // Cargar configuración
  static Future<ServerConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonConfig = prefs.getString(_configKey);

    if (jsonConfig == null) {
      return null; // No hay configuración guardada
    }

    return ServerConfig.fromJson(jsonDecode(jsonConfig));
  }
}
