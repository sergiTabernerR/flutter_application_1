import 'dart:convert';

import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/Articulos.dart';
import 'package:flutter_application_1/models/CabeceraAlbaran.dart';
import 'package:flutter_application_1/models/VinculacionAlbaran.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VinculacionAlbaran_Provider with ChangeNotifier {
  List<VinculacionAlbaran> articulo = [];
  List<VinculacionAlbaran> filteredArticulos = []; // Lista filtrada
  String? selectedArticulo;
  List<CabeceraAlbaran> albaran = [];

  int codigoEmpresa = 0;
  String tipoParte = "";

  final config = GlobalConfig.instance.serverConfig;

  void setSelectedArticulo(String? codigoArticulo) {
    if (selectedArticulo != codigoArticulo) {
      selectedArticulo = codigoArticulo;
      notifyListeners(); // 🔥 Notifica cambios a los widgets
    }
  }

  getArticulos({
    required int? codigoEmpresa,
    required String? codigoTipoParte,
    required int? ejercicioParte,
    required String? serieParte,
    required int? numeroParte,
  }) async {
    final url = Uri.http(config.server, 'api/VinculacionAlbaran');
    final resp = await http.get(url, headers: {
      "Content-type": "application/json",
      "Accept": "application/json"
    });

    final response = vinculacionAlbaranFromJson(resp.body);
    articulo = response;

    final sampleData = articulo
        .map((h) => {
              "codigoEmpresa": h.codigoEmpresa,
              "codigoTipoParteLc": h.codigoTipoParteLc,
              "eJercicioParteLc": h.eJercicioParteLc,
              "serieParteLc": h.serieParteLc,
              "numeroParteLc": h.numeroParteLc,
              "serieAlbaran": h.serieAlbaran,
              "numeroAlbaran": h.numeroAlbaran,
              "codigoArticulo": h.codigoArticulo,
              "descripcionArticulo": h.descripcionArticulo,
              "unidades": h.unidades,
              "unidadesReales": h.unidadesReales,
              "precio": h.precio,
              "importeNeto": h.importeNeto,
              "importeLiquido": h.importeLiquido,
              "lineasPosicion": h.lineasPosicion

              //  "descripcionArticulo": h.descripcionArticulo
            })
        .toList();

    List<Map<String, dynamic>> filteredList = sampleData
        .where((map) =>
            map['codigoEmpresa'] == codigoEmpresa &&
            map['codigoTipoParteLc'] == codigoTipoParte &&
            map['eJercicioParteLc'] == ejercicioParte &&
            map['serieParteLc'] == serieParte &&
            map['numeroParteLc'] == numeroParte)
        .toList();

    String jsonString = jsonEncode(filteredList);
    print(jsonString);
    final response2 = vinculacionAlbaranFromJson(jsonString);
    filteredArticulos = response2;

    notifyListeners();
  }

  Future<void> updateUnidadesPorLineaPosicion({
    required String lineasPosicion,
    required double unidades,
  }) async {
    final url = Uri.http(
        config.server, 'api/VinculacionAlbaran/UpdateUnidadesPorLineaPosicion');

    try {
      print("📡 Enviando solicitud a: $url");
      print(
          "📨 Datos enviados: lineasPosicion=$lineasPosicion, unidades=$unidades");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(
            {"lineasPosicion": lineasPosicion, "unidades": unidades}),
      );

      print(lineasPosicion);

      print("📡 Código de estado: ${response.statusCode}");
      print("📨 Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Unidades actualizadas correctamente");
      } else {
        print("❌ Error al actualizar unidades: ${response.body}");
      }
    } catch (e) {
      print("🚨 Error en la solicitud: $e");
    }
  }

  Future<void> getAlbaran({
    required int? codigoEmpresa,
    required String? codigoTipoParte,
    required int? ejercicioParte,
    required String? serieParte,
    required int? numeroParte,
  }) async {
    // Construir la URL con los parámetros recibidos
    final url = Uri.http(
      config.server,
      'api/VinculacionAlbaran/conseguirAlbaran',
      {
        'codigoEmpresa': codigoEmpresa.toString(),
        'codigoTipoParteLc': codigoTipoParte ?? '',
        'ejercicioParteLc': ejercicioParte.toString(),
        'serieParteLc': serieParte ?? '',
        'numeroParteLc': numeroParte.toString(),
      },
    );

    // Mostrar la URL generada para depuración
    print("URL construida: $url");

    print("Intentando realizar la solicitud GET...");

    try {
      // Realizar la solicitud GET
      final resp = await http.get(
        url,
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
        },
      );

      // Imprimir el código de estado y encabezados
      print("Código de estado: ${resp.statusCode}");
      print("Encabezados de la respuesta: ${resp.headers}");

      // Verificar el contenido de la respuesta
      if (resp.statusCode == 200) {
        print("Respuesta exitosa.");
        print("Cuerpo de la respuesta: ${resp.body}");
        // Procesar el cuerpo JSON
        final response = cabeceraAlbaranFromJson(resp.body);
        albaran = response;
      } else {
        print("Error: Código de estado ${resp.statusCode}");
        print("Cuerpo de la respuesta: ${resp.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  Future<List<VinculacionAlbaran>> getTodosArticulos() async {
    return Future.value(articulo);
  }

  Future<void> saveArticulosLocal(List<VinculacionAlbaran> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('ArticulosAlbaran') ?? [];

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

    await prefs.setStringList('ArticulosAlbaran', jsonLines);
    print("Articulos guardadas localmente: $line");
  }

  Future<void> getArticulosLocales(
      {required int? codigoEmpresa,
      required String? codigoTipoParte,
      required int? ejercicioParte,
      required String? serieParte,
      required int? numeroParte}) async {
    print("Inicio de getArticulosLocales");

    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('ArticulosAlbaran') ?? [];
    print("Datos recuperados de SharedPreferences: $jsonLines");

    // Convertir los datos JSON a objetos `Fases`
    final List<VinculacionAlbaran> allActividades = jsonLines
        .map((line) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(line);

            // Transformar claves a camelCase o el formato que tu modelo espera
            final normalizedJson = jsonData.map((key, value) {
              final newKey = _toCamelCase(key.toString());
              return MapEntry(newKey, value);
            });

            return VinculacionAlbaran.fromJson(normalizedJson);
          } catch (e) {
            print("Error al decodificar JSON: $line. Error: $e");
            return null; // Retorna null si el JSON no es válido
          }
        })
        .whereType<VinculacionAlbaran>()
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

