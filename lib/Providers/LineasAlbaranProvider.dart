import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter_application_1/models/LineasAlbaran%20.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LineasAlbaranProvider with ChangeNotifier {
  List<LineasAlbaran> lineasAlbaran = [];

  final config = GlobalConfig.instance.serverConfig;

  Future<bool> insertLineasNegativas({
    required int codigoEmpresa,
    required int ejercicioAlbaran,
    required String? serieAlbaran,
    required int numeroAlbaran,
  }) async {
    print("Aqui entra");
    print(codigoEmpresa);
    print(ejercicioAlbaran);
    print(serieAlbaran);
    print(codigoEmpresa);
    final url = Uri.http(
        config.server, 'api/DevolucionAlbaran/InsertLineasNegativas', {
      "codigoEmpresa": codigoEmpresa.toString(),
      "ejercicioAlbaran": ejercicioAlbaran.toString(),
      "serieAlbaran": serieAlbaran,
      "numeroAlbaran": numeroAlbaran.toString(),
    });
    print("Aqui entra2");

    try {
      print("Aqui entra3");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );
      print("Aqui entra4");

      if (response.statusCode == 200) {
        print("✅ Líneas negativas insertadas correctamente.");
        return true;
      } else {
        print(codigoEmpresa);
        print(ejercicioAlbaran);
        print(serieAlbaran);
        print(codigoEmpresa);

        print(response.statusCode);
        print("❌ Error al insertar líneas: ${response.body}");
        return false;
      }
    } catch (e) {
      print("🚨 Error en la solicitud: $e");
      return false;
    }
  }

  Future<void> saveLineasAlbaranLocal(List<LineasAlbaran> lineas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines =
        lineas.map((linea) => jsonEncode(linea.toJson())).toList();
    await prefs.setStringList('LineasAlbaran', jsonLines);
    print("💾 Líneas guardadas localmente.");
  }

  Future<void> loadLineasAlbaranLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('LineasAlbaran') ?? [];
    lineasAlbaran = jsonLines
        .map((json) => LineasAlbaran.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }
}
