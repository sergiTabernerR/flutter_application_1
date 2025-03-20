import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/Providers/ConfigManager.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Usuario_provider with ChangeNotifier {
  List<Usuarios> usuarios = [];
  String? codigoClienteConectado;
  String? codigoResponsableEquipo;
  String? usuarioAdministrador;
  Usuario_provider() {
    getUsuarios();
  }

  // Cargar datos locales
  Future<void> loadUsuariosLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonUsuarios = prefs.getString('usuarios');

    if (jsonUsuarios != null) {
      List<Usuarios> tempUsuarios = usuarioFromJson(jsonUsuarios);

      // 🔹 Verificar si el campo `codigoCategoriaEmpleadoLc` existe en los datos locales
      bool necesitaActualizar =
          tempUsuarios.any((u) => u.codigoCategoriaEmpleadoLc == null);

      if (necesitaActualizar) {
        print(
            "⚠️ Datos locales desactualizados. Eliminando caché y actualizando desde API...");
        await prefs.remove('usuarios'); // Eliminar usuarios desactualizados
        await getUsuarios(); // Obtener desde la API
        return;
      }

      usuarios = tempUsuarios;
      notifyListeners();
    }
  }

  // Guardar datos localmente
  Future<void> saveUsuariosLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonUsuarios = jsonEncode(usuarios.map((u) => u.toJson()).toList());
    await prefs.setString('usuarios', jsonUsuarios);
  }

  Future<void> getUsuarios() async {
    final config = await ConfigManager.loadConfig();
    if (config == null) {
      print("Aqui");
      await loadUsuariosLocal(); // Cargar usuarios locales si no hay configuración
      return;
    }

    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '') // Eliminar el protocolo
        .replaceAll(RegExp(r'/$'), ''); // Eliminar barra final si existe

    // Verifica si el servidor es válido
    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadUsuariosLocal();
      return;
    }
    print("hola");
    print("hey");

    // Construcción de la URL con HTTPS
    final url = Uri.http(server, '/api/Usuarios');
    print(url);
    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print("hola1");

      print(resp.body);
      if (resp.statusCode == 200) {
        usuarios = usuarioFromJson(resp.body);
        await saveUsuariosLocal(); // Guardar usuarios en almacenamiento local
        notifyListeners();
      } else {
        print("Error al obtener usuarios: ${resp.statusCode}");
        if (usuarios.isEmpty) {
          await loadUsuariosLocal(); // Cargar usuarios locales si falla la conexión
        }
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
      if (usuarios.isEmpty) {
        await loadUsuariosLocal(); // Cargar usuarios locales si falla la conexión
      }
    }
  }
}
