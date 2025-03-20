import 'package:flutter_application_1/Providers/ConfigManager.dart';

Future<String> getDynamicUrl() async {
  final config = await ConfigManager.loadConfig();
  if (config != null) {
    // Nueva expresión regular para admitir dominios de ngrok y otros subdominios
    final isValidServer = RegExp(
      r'^([a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z]{2,})|(([0-9]{1,3}\.){3}[0-9]{1,3})$',
    ).hasMatch(config.server);

    if (isValidServer) {
      return config.server;
    } else {
      print("Error: Configuración de servidor no válida.");
    }
  }

  return 'serveo.net:8080'; // URL por defecto si no hay configuración válida
}
