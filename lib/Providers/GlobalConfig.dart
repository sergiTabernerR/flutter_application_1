import 'package:flutter_application_1/models/ServerConfig.dart';
import 'package:flutter_application_1/Providers/ConfigManager.dart';

class GlobalConfig {
  static final GlobalConfig _instance = GlobalConfig._internal();
  late ServerConfig _serverConfig;

  GlobalConfig._internal();

  static GlobalConfig get instance => _instance;

  Future<void> initialize() async {
    _serverConfig = (await ConfigManager.loadConfig()) ??
        ServerConfig(server: 'default-url.ngrok-free.app');
  }

  ServerConfig get serverConfig => _serverConfig;

  Future<void> updateConfig(ServerConfig newConfig) async {
    _serverConfig = newConfig;
    await ConfigManager.saveConfig(newConfig);
  }
}
