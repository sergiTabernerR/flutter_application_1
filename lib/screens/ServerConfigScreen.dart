import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/ConfigManager.dart';
import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter_application_1/models/ServerConfig.dart';

class ServerConfigScreen extends StatefulWidget {
  @override
  _ServerConfigScreenState createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  late TextEditingController _urlController; // Controlador para URL dinámica

  bool _isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(); // Inicializar controlador
    _loadCurrentConfig(); // Cargar configuración
  }

  Future<void> _loadCurrentConfig() async {
    try {
      final config = await ConfigManager.loadConfig();
      setState(() {
        _urlController.text = config?.server ?? ''; // Cargar solo URL dinámica
        _isLoading = false; // Detener indicador de carga
      });
    } catch (e) {
      print("Error al cargar configuración: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    final newUrl = _urlController.text.trim().replaceAll(RegExp(r'^https?://'), '').replaceAll(RegExp(r'/$'), '');

    final newConfig = ServerConfig(server: newUrl);

    await GlobalConfig.instance.updateConfig(newConfig);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configuración guardada con éxito")),
    );

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurar Servidor"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Configuración del Servidor",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        "URL del Servidor",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: "URL",
                          hintText: "Ejemplo: example.com",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveConfig,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 30,
                          ),
                        ),
                        child: const Text(
                          "Guardar Configuración",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose(); // Liberar controlador
    super.dispose();
  }
}
