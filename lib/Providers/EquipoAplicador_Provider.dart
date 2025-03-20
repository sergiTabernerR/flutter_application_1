import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Modelo para EquipoAplicador
class EquipoAplicador {
  final String codigoEquipo;
  final int codigoEmpresa;
  final String codigoResponsable;
  final String tecnicoAsignado;

  EquipoAplicador({
    required this.codigoEquipo,
    required this.codigoEmpresa,
    required this.codigoResponsable,
    required this.tecnicoAsignado,
  });

  factory EquipoAplicador.fromJson(Map<String, dynamic> json) =>
      EquipoAplicador(
        codigoEquipo: json["codigoEquipo"],
        codigoEmpresa: json["codigoEmpresa"],
        codigoResponsable: json["codigoResponsable"],
        tecnicoAsignado: json["tecnicoAsignado"].trim(),
      );

  Map<String, dynamic> toJson() => {
        "codigoEquipo": codigoEquipo,
        "codigoEmpresa": codigoEmpresa,
        "codigoResponsable": codigoResponsable,
        "tecnicoAsignado": tecnicoAsignado,
      };
}

class EquipoAplicadorProvider with ChangeNotifier {
  List<EquipoAplicador> equiposAplicadores = [];
  String? serverUrl;

  EquipoAplicadorProvider() {
    loadServerConfig();
    getEquiposAplicadores();
  }

  // Cargar configuración del servidor desde almacenamiento local
  Future<void> loadServerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    serverUrl = prefs.getString('serverUrl') ??
        'localhost:7118'; // Cambia el puerto según tu API
  }

  // Guardar configuración del servidor localmente
  Future<void> saveServerConfig(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverUrl', url);
    serverUrl = url;
  }

  // Cargar datos locales
  Future<void> loadEquiposAplicadoresLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonEquipos = prefs.getString('equiposAplicadores');

    if (jsonEquipos != null) {
      equiposAplicadores = (json.decode(jsonEquipos) as List)
          .map((e) => EquipoAplicador.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  // Guardar datos localmente
  Future<void> saveEquiposAplicadoresLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonEquipos =
        jsonEncode(equiposAplicadores.map((e) => e.toJson()).toList());
    await prefs.setString('equiposAplicadores', jsonEquipos);
  }

  // Obtener equipos aplicadores desde la API
  Future<void> getEquiposAplicadores() async {
    final config = GlobalConfig.instance.serverConfig;

    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '') // Eliminar el protocolo
        .replaceAll(RegExp(r'/$'), ''); // Eliminar barra final si existe

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadEquiposAplicadoresLocal();
      return;
    }
    if (serverUrl == null) {
      await loadEquiposAplicadoresLocal(); // Cargar desde local si no hay servidor configurado
      return;
    }

    final url = Uri.http(server, '/api/EquipoAplicador');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        equiposAplicadores =
            jsonResponse.map((e) => EquipoAplicador.fromJson(e)).toList();
        await saveEquiposAplicadoresLocal(); // Guardar localmente
        notifyListeners();
      } else {
        print("Error al obtener datos: ${response.statusCode}");
        await loadEquiposAplicadoresLocal();
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
      await loadEquiposAplicadoresLocal();
    }
  }

  // Agregar un equipo aplicador
  Future<void> addEquipoAplicador(EquipoAplicador nuevoEquipo) async {
    if (serverUrl == null) return;

    final url = Uri.http(serverUrl!, '/api/EquipoAplicador');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(nuevoEquipo.toJson()),
      );

      if (response.statusCode == 201) {
        equiposAplicadores.add(nuevoEquipo);
        await saveEquiposAplicadoresLocal();
        notifyListeners();
      } else {
        print("Error al agregar equipo: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }

  // Eliminar un equipo aplicador
  Future<void> deleteEquipoAplicador(String codigoEquipo) async {
    if (serverUrl == null) return;

    final url = Uri.http(serverUrl!, '/api/EquipoAplicador/$codigoEquipo');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        equiposAplicadores
            .removeWhere((equipo) => equipo.codigoEquipo == codigoEquipo);
        await saveEquiposAplicadoresLocal();
        notifyListeners();
      } else {
        print("Error al eliminar equipo: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }
}
