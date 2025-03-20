import 'dart:convert';

import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/Providers/VinculacionAlbaran_Provider.dart';
import 'package:flutter_application_1/models/ActividadPartes.dart';
import 'package:flutter_application_1/models/VinculacionAlbaran.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActividadProvider with ChangeNotifier {
  List<ActividadParte> actividad = [];
  List<ActividadParte> filteredActividades = []; // Lista filtrada
  int codigoEmpresa = 0;
  String? selectedActividad;
  final config = GlobalConfig.instance.serverConfig;
  final VinculacionAlbaran_Provider
      articulosProvider; // 💡 Añadir referencia al Provider de artículos

  // 🟢 Modificar constructor para recibir el Provider de artículos
  ActividadProvider(this.articulosProvider);
  void reset() {
    selectedActividad = null;
    notifyListeners();
  }

  // 🟢 Método para seleccionar una actividad y actualizar el artículo automáticamente
  void selectActividad(String codigoActividad, BuildContext context) {
    selectedActividad = codigoActividad;

    final actividadSeleccionada = filteredActividades.firstWhere(
      (actividad) =>
          actividad.codigoActividadParteLc?.trim() == codigoActividad.trim(),
      orElse: () => ActividadParte(
        codigoEmpresa: 0,
        codigoActividadParteLc: "",
        actividadParteLc: "",
        imputableLc: 0,
        codigoArticulo: "",
        codigoGrupoActividadParteLc: "",
        esVisibleEnMovil: 0,
      ),
    );

    if (actividadSeleccionada.codigoArticulo != null &&
        actividadSeleccionada.codigoArticulo!.isNotEmpty) {
      final articulosProvider =
          Provider.of<VinculacionAlbaran_Provider>(context, listen: false);

      // Verificar si el código de artículo ya existe en la lista
      bool articuloExiste = articulosProvider.filteredArticulos.any(
          (art) => art.codigoArticulo == actividadSeleccionada.codigoArticulo);

      if (!articuloExiste) {
        // Si no existe, agregar el artículo a la lista de `filteredArticulos`
        articulosProvider.filteredArticulos.add(
          VinculacionAlbaran(
              codigoEmpresa: actividadSeleccionada.codigoEmpresa!,
              codigoTipoParteLc: "", // Ajustar según necesidad
              eJercicioParteLc: 0, // Ajustar según necesidad
              serieParteLc: "", // Ajustar según necesidad
              numeroParteLc: 0, // Ajustar según necesidad
              ejercicioAlbaran: 0, // Ajustar según necesidad
              serieAlbaran: "", // Ajustar según necesidad
              numeroAlbaran: 0, // Ajustar según necesidad
              codigoArticulo: actividadSeleccionada.codigoArticulo!,
              descripcionArticulo: "",
              unidades: 0,
              unidadesReales: 0,
              precio: 0,
              importeNeto: 0,
              importeLiquido: 0,
              lineasPosicion: ""),
        );

        print("🆕 Artículo agregado: ${actividadSeleccionada.codigoArticulo}");
        articulosProvider.notifyListeners();
      } else {
        print("⚠️ El artículo ya existe en la lista.");
      }

      // ✅ Actualiza directamente el artículo en el Provider de artículos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        articulosProvider
            .setSelectedArticulo(actividadSeleccionada.codigoArticulo!);
      });
    } else {
      print(
          "⚠️ No se encontró un código de artículo para la actividad seleccionada.");
    }

    notifyListeners(); // 🔥 Asegura que el cambio se refleje en la UI
  }

  Future<void> getActividad() async {
    final url = Uri.http(config.server, 'api/ActividadParte');
    final resp = await http.get(url, headers: {
      "Content-type": "application/json",
      "Accept": "application/json"
    });

    final response = actividadParteFromJson(resp.body);
    actividad = response;

    final sampleData = actividad
        .map((h) => {
              "codigoEmpresa": h.codigoEmpresa,
              "codigoActividadParteLc": h.codigoActividadParteLc,
              "actividadParteLc": h.actividadParteLc,
              "imputableLc": h.imputableLc,
              "codigoArticulo": h.codigoArticulo,
              "codigoGrupoActividadParteLc": h.codigoGrupoActividadParteLc
            })
        .toList();

    List<Map<String, dynamic>> filteredList = sampleData
        .where((map) => map['codigoEmpresa'] == codigoEmpresa)
        .toList();

    String jsonString = jsonEncode(filteredList);

    final response2 = actividadParteFromJson(jsonString);
    filteredActividades = response2;

    notifyListeners();
  }

  Future<List<ActividadParte>> getTodasActividades() async {
    return Future.value(actividad);
  }

  Future<void> saveActividadLocal(List<ActividadParte> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('Actividades') ?? [];

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

    await prefs.setStringList('Actividades', jsonLines);
  }

  Future<void> getActividadLocales({required int codigoEmpresa}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('Actividades') ?? [];

    // Convertir los datos JSON a objetos `Fases`
    final List<ActividadParte> allActividades = jsonLines
        .map((line) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(line);

            // Transformar claves a camelCase o el formato que tu modelo espera
            final normalizedJson = jsonData.map((key, value) {
              final newKey = _toCamelCase(key.toString());
              return MapEntry(newKey, value);
            });

            return ActividadParte.fromJson(normalizedJson);
          } catch (e) {
            print("Error al decodificar JSON: $line. Error: $e");
            return null; // Retorna null si el JSON no es válido
          }
        })
        .whereType<ActividadParte>()
        .toList();

    // Imprimir datos para depuración

    var ActividadFiltradas = allActividades
        .where((actividad) {
          return actividad.codigoEmpresa == codigoEmpresa;
        })
        .toSet()
        .toList();
    filteredActividades = ActividadFiltradas;
  }

// Método para convertir PascalCase a camelCase
  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }
}
