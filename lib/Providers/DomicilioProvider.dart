import 'dart:convert';

import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/Providers/VinculacionAlbaran_Provider.dart';
import 'package:flutter_application_1/models/ActividadPartes.dart';
import 'package:flutter_application_1/models/Domicilio.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Domicilioprovider with ChangeNotifier {
  List<ActividadParte> actividad = [];
  List<ActividadParte> filteredActividades = []; // Lista filtrada
  List<Domicilio> domicilio = []; // Lista filtrada

  int codigoEmpresa = 0;
  String? selectedActividad;
  final config = GlobalConfig.instance.serverConfig;

  // 🟢 Modificar constructor para recibir el Provider de artículos
  Domicilioprovider();
  void reset() {
    selectedActividad = null;
    notifyListeners();
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

  Future<void> fetchDomiciliosPorCliente(
      String codigoCliente, int codigoEmpresa) async {
    final url = Uri.http(
        config.server, 'api/Domicilios/Cliente/$codigoCliente/$codigoEmpresa');

    final resp = await http.get(url, headers: {
      "Content-type": "application/json",
      "Accept": "application/json"
    });

    if (resp.statusCode == 200) {
      final response = domicilioFromJson(resp.body);

      // Filtrar duplicados usando un Set
      final Set<int> seenNumbers = {};
      domicilio = response
          .where((d) => seenNumbers.add(d.numeroDomicilio ?? 0))
          .toList();

      notifyListeners();
    } else {
      domicilio = [];
      notifyListeners();
    }
  }

  Future<bool> addDomicilio(Domicilio domicilios, String codigoCliente) async {
    final url = Uri.http(
        config.server, 'api/Domicilios', {'codigoCliente': codigoCliente});

    try {
      // ✅ Imprimir los datos que se enviarán a la API
      print("📤 Enviando a la API: ${json.encode(domicilios.toJson())}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(domicilios.toJson()),
      );

      // ✅ Verificar la respuesta de la API
      if (response.statusCode == 201) {
        print("✅ Domicilio creado correctamente: ${response.body}");

        // 🔄 Actualizar la lista automáticamente
        domicilio.add(domicilios);
        notifyListeners();

        return true;
      } else {
        print("⚠️ Error en la respuesta: Código ${response.statusCode}");
        print("⚠️ Mensaje de error: ${response.body}");
      }
    } catch (e) {
      print("❌ Error al conectar con el servidor: $e");
    }

    return false;
  }
}
