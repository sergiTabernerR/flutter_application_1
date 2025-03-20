import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/partePost.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LineasParte_provider with ChangeNotifier {
  List<LineasParte> partes = [];
  List<LineasParte> filteredpartes = [];
  List<LineasParte> filtroLineaParte = [];
  List<LineasParte> todasLineasPartes = [];
  int? codigoEmpresa;
  int? ejercicioPedido;
  String? seriePedido;
  int? numeroPedido;
  String? codigoTipoParte;
  List<Map<String, dynamic>> pendingLines = [];

  final config = GlobalConfig.instance.serverConfig;

  Future<void> getLineasPartes() async {
    try {
      // Verificar que los valores no sean nulos antes de construir la URL
      final queryParams = {
        'codigoEmpresa': codigoEmpresa?.toString(),
        'codigoTipoParteLc': codigoTipoParte?.toString(),
        'ejercicioParteLc': ejercicioPedido?.toString(),
        'serieParteLc': seriePedido?.toString(),
        'numeroParteLc': numeroPedido?.toString(),
      };

      // 🔹 Eliminar parámetros nulos
      queryParams.removeWhere((key, value) => value == null || value.isEmpty);

      // Construir la URL con parámetros filtrados
      final url = Uri.http(
          config.server, '/api/LineasPartes/GetLineasPartes', queryParams);

      print("🔍 URL de solicitud: $url");

      final resp =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (resp.statusCode == 200) {
        print("✅ Datos recibidos: ${resp.body}");
        filtroLineaParte = LineasParteFromJson(resp.body);
      } else {
        print("❌ Error: ${resp.statusCode}, ${resp.body}");
        filtroLineaParte = [];
      }
    } catch (e) {
      print('🚨 Error al obtener líneas de partes: $e');
      filtroLineaParte = [];
    }
  }

  Future<void> getTodasLineasPartes() async {
    try {
      // Realiza la solicitud HTTP
      final url = Uri.http(config.server, '/api/LineasPartes');

      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        // Decodificar la respuesta
        partes = LineasParteFromJson(resp.body);

        // Filtrar los datos relevantes
        todasLineasPartes = partes.toList();
        // Notificar a los consumidores
        notifyListeners();
      } else {
        print('Error en la solicitud: ${resp.statusCode}');
      }
    } catch (e) {
      print('Error al obtener líneas de partes: $e');
    }
  }

  Future<void> savePartesTodosLocal(List<LineasParte> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('lineasPartesTodas') ?? [];

    // Convertir la lista de objetos en JSON para comparar
    final existingLines = jsonLines.map((e) => jsonDecode(e)).toList();

    for (var newParte in line) {
      // Convertir el nuevo parte a JSON
      final newParteJson = jsonEncode(newParte.toJson());

      // Verificar si ya existe en los datos guardados
      if (!jsonLines.contains(newParteJson)) {
        jsonLines.add(newParteJson); // Agregar solo si no es un duplicado
      }
    }

    await prefs.setStringList('lineasPartesTodas', jsonLines);
  }

  Future<void> getPartesLineasLocales({
    required int? codigoEmpresa,
    required String? codigoTipoParte,
    required int? ejercicioParte,
    required String? serieParte,
    required int? numeroParte,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperar los datos como una lista de cadenas JSON
    final jsonLines = prefs.getStringList('lineasPartesTodas') ?? [];

    // Convertir cada elemento JSON a un objeto `LineasParte`
    final allLines = jsonLines
        .map((line) =>
            LineasParte.fromJson(jsonDecode(line) as Map<String, dynamic>))
        .toList();

    // Filtrar las líneas que coincidan con los parámetros
    final filteredLines = allLines.where((line) {
      return (line.codigoEmpresa == codigoEmpresa) &&
          (line.codigoTipoParteLc?.trim() == codigoTipoParte?.trim()) &&
          (line.ejercicioParteLc == ejercicioParte) &&
          (line.serieParteLc?.trim() == serieParte?.trim()) &&
          (line.numeroParteLc == numeroParte);
    }).toList();

    // Actualiza la lista `filteredpartes`
    filteredpartes = filteredLines;

    // Notifica a los listeners para que actualicen la interfaz
    notifyListeners();
  }

  Future<List<LineasParte>> getPendingLineasPartes() async {
    return todasLineasPartes;
  }

  Future<bool> createPartes(
    int codigoEmpresa,
    String codigoTipoParteLc,
    int ejercicioParteLc,
    String serieParteLc,
    int numeroParteLc,
    String codigoTipoFaseLc,
    String CodigoAtividadParteLc,
    String tecnicoAsignadoLc,
    String codigoGastoComercialLc,
    int facturable,
    String codigoArticulo,
    double Unidades,
    double horaEntradaLc,
    int liquidableLc,
    String observaciones,
  ) async {
    if (config.server.isEmpty) {
      print("Error: Servidor no configurado");
      return false;
    }
    print("ssssssssssssssssssss");
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
    print("aaaaaaaaaaaaaaaaaaaaaaaaa");

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);
    print("bbbbbbbbbbbbbbbbbbbbbbbbbb");

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      return false;
    }
    print("cccccccccccccccccccccccccccccc");

    final url = Uri.http(server, '/api/LineasPartes');
    print(url);
    try {
      print("Intentando conectarse a: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'codigoEmpresa': codigoEmpresa,
          'codigoTipoParteLc': codigoTipoParteLc,
          'ejercicioParteLc': ejercicioParteLc,
          'serieParteLc': serieParteLc,
          'numeroParteLc': numeroParteLc,
          'codigoTipoFaseLc': codigoTipoFaseLc,
          'codigoActividadParteLc': CodigoAtividadParteLc,
          'tecnicoAsignadoLc': tecnicoAsignadoLc,
          'codigoGastoComercialLc': codigoGastoComercialLc,
          'facturableLc': facturable,
          'codigoArticulo': codigoArticulo,
          'codigoAlmacen': "BCN",
          'numeroSerieLc': "",
          'unidades': Unidades,
          'horaEntradaLc': horaEntradaLc,
          'liquidableLc': liquidableLc,
          'observaciones': observaciones
        }),
      );
      print("=============================================");
      print(response.body);

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Error al crear parte: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error en la solicitud HTTP: $error");

      // Si falla la conexión, guarda las líneas localmente
      await saveLineLocally({
        'codigoEmpresa': codigoEmpresa,
        'codigoTipoParteLc': codigoTipoParteLc,
        'ejercicioParteLc': ejercicioParteLc,
        'serieParteLc': serieParteLc,
        'numeroParteLc': numeroParteLc,
        'codigoTipoFaseLc': codigoTipoFaseLc,
        'codigoActividadParteLc': CodigoAtividadParteLc,
        'tecnicoAsignadoLc': tecnicoAsignadoLc,
        'codigoGastoComercialLc': codigoGastoComercialLc,
        'facturableLc': facturable,
        'codigoArticulo': codigoArticulo,
        'codigoAlmacen': "BCN",
        'numeroSerieLc': "",
        'unidades': Unidades,
        'horaEntradaLc': horaEntradaLc,
        'liquidableLc': liquidableLc,
        'observaciones': observaciones,
      });
      return false;
    }
  }

// Método para guardar una línea localmente en SharedPreferences
  Future<void> saveLineLocally(Map<String, dynamic> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('pendingLines') ?? [];
    jsonLines.add(jsonEncode(line));
    await prefs.setStringList('pendingLines', jsonLines);
  }

// Método para cargar todas las líneas pendientes al iniciar
  Future<List<Map<String, dynamic>>> loadPendingLines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('pendingLines') ?? [];
    return jsonLines
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();
  }

// Método para eliminar una línea pendiente después de enviarla con éxito
  Future<void> removeLineLocally(Map<String, dynamic> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('pendingLines') ?? [];
    jsonLines.remove(jsonEncode(line));
    await prefs.setStringList('pendingLines', jsonLines);
  }

// Método para enviar todas las líneas pendientes al servidor
  Future<void> submitPendingLines() async {
    final pendingLines = await loadPendingLines();
    for (final line in pendingLines) {
      final success = await createPartes(
        line['codigoEmpresa'],
        line['codigoTipoParteLc'],
        line['ejercicioParteLc'],
        line['serieParteLc'],
        line['numeroParteLc'],
        line['codigoTipoFaseLc'],
        line['codigoActividadParteLc'],
        line['tecnicoAsignadoLc'],
        line['codigoGastoComercialLc'],
        line['facturableLc'],
        line['codigoArticulo'],
        line['unidades'],
        line['horaEntradaLc'],
        line['liquidableLc'],
        line['observaciones'],
      );
      if (success) {
        await removeLineLocally(line);
      }
    }
  }

// Método para cargar y mostrar las líneas pendientes
  Future<List<Map<String, dynamic>>> getPendingLines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('pendingLines') ?? [];
    return jsonLines
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();
  }
}
