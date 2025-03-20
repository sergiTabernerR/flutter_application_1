import 'dart:convert';

import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/Articulos.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Articulos_provider with ChangeNotifier {
  List<Articulos> articulo = [];
  List<Articulos> filteredArticulos = []; // Lista filtrada
  String? selectedArticulo;

  int codigoEmpresa = 0;
  String tipoParte = "";

  Articulos_provider() {
    getArticulos();
  }
  final config = GlobalConfig.instance.serverConfig;
  void reset() {
    selectedArticulo = "";
    notifyListeners();
  }

  getArticulos() async {
    final url = Uri.http(config.server, 'api/Articles');
    final resp = await http.get(url, headers: {
      "Content-type": "application/json",
      "Accept": "application/json"
    });

    final response = articulosFromJson(resp.body);
    articulo = response;

    final sampleData = articulo
        .map((h) => {
              "codigoEmpresa": h.codigoEmpresa,
              "codigoArticulo": h.codigoArticulo,
              "descripcionArticulo": h.descripcionArticulo
            })
        .toList();

    List<Map<String, dynamic>> filteredList = sampleData
        .where((map) => map['codigoEmpresa'] == codigoEmpresa)
        .toList();

    String jsonString = jsonEncode(filteredList);

    final response2 = articulosFromJson(jsonString);

    filteredArticulos = response2;
    notifyListeners();
  }

  Future<List<Articulos>> getTodosArticulos() async {
    return Future.value(articulo);
  }

  Future<void> saveArticulosLocal(List<Articulos> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('Articulos') ?? [];

    // Convertir la lista de objetos en JSON a objetos de Dart para comparar
    final existingLines = jsonLines.map((e) => jsonDecode(e)).toList();

    for (var newParte in line) {
      // Convertir el nuevo parte a JSON
      final newParteJson = jsonEncode(newParte);

      // Verificar si ya existe en los datos guardados
      if (!jsonLines.contains(newParteJson)) {
        jsonLines.add(newParteJson); // Agregar solo si no es un duplicado
      }
    }

    await prefs.setStringList('Articulos', jsonLines);
  }

  Future<void> getArticulosLocales({required int codigoEmpresa}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('Articulos') ?? [];

    // Convertir los datos JSON a objetos `Fases`
    final List<Articulos> allActividades = jsonLines
        .map((line) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(line);

            // Transformar claves a camelCase o el formato que tu modelo espera
            final normalizedJson = jsonData.map((key, value) {
              final newKey = _toCamelCase(key.toString());
              return MapEntry(newKey, value);
            });

            return Articulos.fromJson(normalizedJson);
          } catch (e) {
            print("Error al decodificar JSON: $line. Error: $e");
            return null; // Retorna null si el JSON no es válido
          }
        })
        .whereType<Articulos>()
        .toList();

    // Imprimir datos para depuración

    var articulosFiltrados = allActividades
        .where((articulos) {
          return articulos.codigoEmpresa == codigoEmpresa;
        })
        .toSet()
        .toList();
    filteredArticulos = articulosFiltrados;
  }

// Método para convertir PascalCase a camelCase
  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }
}
