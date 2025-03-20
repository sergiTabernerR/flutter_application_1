import 'dart:convert';

import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/FasesPartes.dart';
import 'package:flutter_application_1/models/parte.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FasesProvider with ChangeNotifier {
  List<Fases> fases = [];
  List<Fases> filteredFase = []; // Lista filtrada
  String? selectedFase;
  String codigoTipoFaseLc = "";
  int? codigoEmpresa;
  int? ejercicioParteLC;
  String serieParteLc = "";
  int? numeroParteLc;
  final config = GlobalConfig.instance.serverConfig;

  FasesProvider() {
    getFases();
  }
  void reset() {
    selectedFase = null;
    notifyListeners();
  }
  Future<void> getFases() async {
    final url = Uri.http(config.server, 'api/FasesPartes');
    final resp = await http.get(url, headers: {
      "Content-type": "application/json",
      "Accept": "application/json"
    });

    final response = FasesparteFromJson(resp.body);
    fases = response;
    final sampleData = fases
        .map((h) => {
              "codigoTipoParteLc": h.codigoTipoParteLc,
              "codigoEmpresa": h.codigoEmpresa,
              "ejercicioParteLC": h.ejercicioParteLC,
              "serieParteLc": h.serieParteLc,
              "numeroParteLc": h.numeroParteLc,
              "codigoTipoFaseLc": h.codigoTipoFaseLc,
              "fechaInicialLc": h.fechaInicialLc
                  ?.toIso8601String(), // Convertir a formato ISO
              "fechaPrevistaLc": h.fechaPrevistaLc
                  ?.toIso8601String(), // Convertir a formato ISO
              "statusFaseLc": h.statusFaseLc,
            })
        .toList();

    List<Map<String, dynamic>> filteredList = sampleData
        .where((map) =>
            map['codigoTipoParteLc'].toString().contains(codigoTipoFaseLc) &&
            map['codigoEmpresa'] == codigoEmpresa &&
            map['ejercicioParteLC'] == ejercicioParteLC &&
            map['serieParteLc'].toString().contains(serieParteLc) &&
            map['numeroParteLc'] == numeroParteLc)
        .toList();

    String jsonString = jsonEncode(filteredList);

    final response2 = FasesparteFromJson(jsonString);

    filteredFase = response2;

    notifyListeners();
  }

  Future<List<Fases>> getTodasFases() async {
    return Future.value(fases);
  }

  Future<void> saveFasesLocal(List<Fases> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('fases') ?? [];

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

    await prefs.setStringList('fases', jsonLines);
  }

  Future<void> getFasesLocales({
    required String codigoTipoFaseLc,
    required int codigoEmpresa,
    required int ejercicioParteLC,
    required String serieParteLc,
    required int numeroParteLc,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('fases') ?? [];

    // Convertir los datos JSON a objetos `Fases`
    final List<Fases> allFases = jsonLines
        .map((line) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(line);

            // Transformar claves a camelCase o el formato que tu modelo espera
            final normalizedJson = jsonData.map((key, value) {
              final newKey = _toCamelCase(key.toString());
              return MapEntry(newKey, value);
            });

            return Fases.fromJson(normalizedJson);
          } catch (e) {
            print("Error al decodificar JSON: $line. Error: $e");
            return null; // Retorna null si el JSON no es válido
          }
        })
        .whereType<Fases>()
        .toList();

    // Imprimir datos para depuración

    var fasesFiltradas = allFases
        .where((fase) {
          return fase.codigoEmpresa == codigoEmpresa &&
              fase.ejercicioParteLC == ejercicioParteLC &&
              fase.serieParteLc.toString().contains(serieParteLc) &&
              fase.numeroParteLc == numeroParteLc;
        })
        .toSet()
        .toList();

    final fasesUnicas = fasesFiltradas
        .fold<Map<String, Fases>>({}, (map, fase) {
          map[fase.codigoTipoFaseLc ?? ""] = fase;
          return map;
        })
        .values
        .toList();

    filteredFase = fasesUnicas;
  }

// Método para convertir PascalCase a camelCase
  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }
}
