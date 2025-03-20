import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter_application_1/models/parte.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Parte_Provider with ChangeNotifier {
  List<parte_> partes = [];
  List<parte_> partesPendientes = [];
  List<parte_> todosPartes = [];
  List<String> responsablesPartes = [];
  List<parte_> filteredPartes = [];
  List<parte_> pendingSync = []; // Cambios pendientes para sincronizar
  bool _isPartesLoaded = false;

  String responsableParteLc = "";
  String tipoParte = "";

  bool get isPartesLoaded => _isPartesLoaded;

  final config = GlobalConfig.instance.serverConfig;

  Parte_Provider() {
    getPartes(); // Intentar obtener partes desde el servidor
  }
  Future<bool> actualizarParte(
      String idParte, Map<String, dynamic> cambios) async {
    print("🔹 Iniciando actualización del parte...");

    // Construcción de la nueva URL
    final url =
        Uri.http(config.server, '/api/Partes/ActualizarParte/$idParte');
    print("🌍 URL de solicitud: $url");
    print("📋 Datos antes de enviar: $cambios");

    // ✅ Convertir la fecha si existe en el mapa de cambios
    if (cambios.containsKey("fecha") && cambios["fecha"] is String) {
      try {
        DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(cambios["fecha"]);
        cambios["fecha"] = parsedDate.toIso8601String(); // ➡ Formato ISO 8601
        print("✅ Fecha convertida correctamente: ${cambios["fecha"]}");
      } catch (e) {
        print("❌ Error al parsear la fecha: $e");
      }
    }

    // ✅ Convertir mm_fechafinGarantia si también necesita conversión
    if (cambios.containsKey("mm_fechafinGarantia") &&
        cambios["mm_fechafinGarantia"] is String) {
      try {
        DateTime parsedDate = DateTime.parse(cambios["mm_fechafinGarantia"]);
        cambios["mm_fechafinGarantia"] =
            parsedDate.toIso8601String(); // ➡ Formato ISO 8601
        print(
            "✅ mm_fechafinGarantia convertida correctamente: ${cambios["mm_fechafinGarantia"]}");
      } catch (e) {
        print("❌ Error al parsear mm_fechafinGarantia: $e");
      }
    }

    // Convertir los cambios a JSON antes de enviarlos
    final bodyData = jsonEncode(cambios);
    print("📤 Datos enviados: $bodyData");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: bodyData,
      );

      print("==========================================");
      print(
          "📥 Respuesta del servidor: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Parte actualizado correctamente.");

        // Buscar y actualizar el parte en la lista local si existe
        final index = partes.indexWhere((p) => p.idParte == idParte);
        if (index != -1) {
          partes[index] = partes[index].copyWith(cambios);
          notifyListeners();
        }
        return true;
      } else {
        print("❌ Error al actualizar el parte: ${response.body}");
        return false;
      }
    } catch (e) {
      print("🚨 Excepción durante la solicitud: $e");
      return false;
    }
  }

  Future<void> savePartesActivosLocal(List<parte_> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('partesActivos') ?? [];

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

    await prefs.setStringList('partesActivos', jsonLines);
  }

  Future<void> removeParteActivosLocally(List<parte_> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('partesActivos') ?? [];
    jsonLines.remove(jsonEncode(line));
    await prefs.setStringList('partesActivos', jsonLines);
  }

  Future<List<parte_>> getPartesActivosLocales() async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperar los datos como una lista de cadenas JSON
    final jsonLines = prefs.getStringList('partesActivos') ?? [];

    // Convertir cada elemento JSON a un objeto `parte_` usando `fromJson`
    return jsonLines
        .map(
            (line) => parte_.fromJson(jsonDecode(line) as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePartesPendientesLocal(List<parte_> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('partesPendientes') ?? [];

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

    await prefs.setStringList('partesPendientes', jsonLines);
  }

  Future<List<parte_>> getPartesPendientesLocales() async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperar los datos como una lista de cadenas JSON
    final jsonLines = prefs.getStringList('partesPendientes') ?? [];

    // Convertir cada elemento JSON a un objeto `parte_` usando `fromJson`
    return jsonLines
        .map(
            (line) => parte_.fromJson(jsonDecode(line) as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePartesTodosLocal(List<parte_> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('partesTodos') ?? [];

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

    await prefs.setStringList('partesTodos', jsonLines);
  }

  Future<List<parte_>> getPartesTodosLocales() async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperar los datos como una lista de cadenas JSON
    final jsonLines = prefs.getStringList('partesTodos') ?? [];

    // Convertir cada elemento JSON a un objeto `parte_` usando `fromJson`
    return jsonLines
        .map(
            (line) => parte_.fromJson(jsonDecode(line) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCerrarParteLocal(Map<String, dynamic> line) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('Cerrarparte') ?? [];
    jsonLines.add(jsonEncode(line));
    await prefs.setStringList('Cerrarparte', jsonLines);
  }

  Future<List<Map<String, dynamic>>> getPendingPartesCerrados() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonLines = prefs.getStringList('Cerrarparte') ?? [];
    return jsonLines
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();
  }

  /// Cargar partes desde almacenamiento local
  Future<void> loadPartesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonPartes = prefs.getString('partes');

    if (jsonPartes != null) {
      partes = parteFromJson(jsonPartes);
      // Aplicar filtro por responsableParteLc
      applyFilter();
    }
  }

  Future<void> loadPartesLocalPendiente() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonPartes = prefs.getString('partes');

    if (jsonPartes != null) {
      partes = parteFromJson(jsonPartes);
      // Aplicar filtro por responsableParteLc
      applyFilterPendiente();
    }
  }

  void applyFilter() {
    if (responsableParteLc.isNotEmpty) {
      filteredPartes = partes
          .where((parte) => parte.responsableParteLc == responsableParteLc)
          .toList();
    } else {
      filteredPartes = partes; // Mostrar todos si no hay filtro
    }
    notifyListeners(); // Notificar cambios
  }

  /// Aplicar filtro por responsable
  void applyFilterPendiente() {
    if (responsableParteLc.isNotEmpty) {
      filteredPartes = partes
          .where((parte) =>
              parte.responsableParteLc == responsableParteLc &&
              parte.statusParteLc == 0)
          .toList();
    } else {
      filteredPartes = partes; // Mostrar todos si no hay filtro
    }
    notifyListeners(); // Notificar cambios
  }

  /// Sincronizar cambios pendientes con el servidor
  Future<void> syncPendingChanges() async {
    for (var parte in List.from(pendingSync)) {
      try {
        final url = Uri.http(config.server, '/api/partes');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(parte.toJson()),
        );

        if (response.statusCode == 201) {
          pendingSync.remove(parte); // Eliminar de pendientes si se sincronizó
        }
      } catch (e) {
        print('Error al sincronizar parte: $e');
      }
    }
    notifyListeners();
  }

  /// Obtener partes desde el servidor
  Future<void> getPartes() async {
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '') // Eliminar el protocolo
        .replaceAll(RegExp(r'/$'), ''); // Eliminar barra final si existe

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    final url = Uri.http(server, '/api/partes', {
      'StatusParteLc': "1",
      'responsableParteLc': responsableParteLc,
    });

    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        partes = parteFromJson(resp.body);
        applyFilter(); // Aplicar filtro después de obtener datos
      } else {
        print("Error al obtener partes: ${resp.statusCode}");
        if (partes.isEmpty) {
          await loadPartesLocal(); // Cargar datos locales si falla la conexión
        }
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
      if (partes.isEmpty) {
        await loadPartesLocal();
      }
    }
  }

  Future<void> getPartesPorVariosResponsablesActivos(
      List<String> responsables) async {
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '') // Eliminar el protocolo
        .replaceAll(RegExp(r'/$'), ''); // Eliminar barra final si existe

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    // Construir parámetros para múltiples responsables
    Map<String, String> queryParams = {
      'StatusParteLc': "1",
    };

    // Agregar múltiples responsables a los parámetros de la URL
    for (int i = 0; i < responsables.length; i++) {
      queryParams['ResponsableParteLc[$i]'] = responsables[i];
    }

    // Construir la URL con los parámetros de consulta
    final url =
        Uri.http(server, '/api/partes/PorVariosResponsables', queryParams);

    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        partes = parteFromJson(resp.body);
        applyFilter(); // Aplicar filtro después de obtener datos
      } else {
        print("Error al obtener partes: ${resp.statusCode}");
        if (partes.isEmpty) {
          await loadPartesLocal(); // Cargar datos locales si falla la conexión
        }
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
      if (partes.isEmpty) {
        await loadPartesLocal();
      }
    }
  }

  Future<void> getPartesPorVariosResponsablesPendientes(
      List<String> responsables) async {
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '') // Eliminar el protocolo
        .replaceAll(RegExp(r'/$'), ''); // Eliminar barra final si existe

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    // Construir parámetros para múltiples responsables
    Map<String, String> queryParams = {
      'StatusParteLc': "0",
    };

    // Agregar múltiples responsables a los parámetros de la URL
    for (int i = 0; i < responsables.length; i++) {
      queryParams['ResponsableParteLc[$i]'] = responsables[i];
    }

    // Construir la URL con los parámetros de consulta
    final url =
        Uri.http(server, '/api/partes/PorVariosResponsables', queryParams);

    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        partesPendientes = parteFromJson(resp.body);
        applyFilter(); // Aplicar filtro después de obtener datos
      } else {
        print("Error al obtener partes: ${resp.statusCode}");
        if (partes.isEmpty) {
          await loadPartesLocal(); // Cargar datos locales si falla la conexión
        }
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
      if (partes.isEmpty) {
        await loadPartesLocal();
      }
    }
  }

  Future<void> getPartesPorVariosResponsablesTodos(
      List<String> responsables) async {
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    List<parte_> partesStatus1 = [];
    List<parte_> partesStatus0 = [];

    try {
      // Construir los parámetros para múltiples responsables para los activos
      Map<String, String> queryParams1 = {
        'StatusParteLc': "1",
      };
      for (int i = 0; i < responsables.length; i++) {
        queryParams1['ResponsableParteLc[$i]'] = responsables[i];
      }

      // Construir los parámetros para múltiples responsables para los pendientes
      Map<String, String> queryParams0 = {
        'StatusParteLc': "0",
      };
      for (int i = 0; i < responsables.length; i++) {
        queryParams0['ResponsableParteLc[$i]'] = responsables[i];
      }

      // URLs para activos y pendientes
      final url1 =
          Uri.http(server, '/api/partes/PorVariosResponsables', queryParams1);
      final url0 =
          Uri.http(server, '/api/partes/PorVariosResponsables', queryParams0);

      final resp1 = await http.get(
        url1,
        headers: {'Content-Type': 'application/json'},
      );
      final resp0 = await http.get(
        url0,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp1.statusCode == 200) {
        partesStatus1 = parteFromJson(resp1.body);
      } else {
        print("Error al obtener partes activos: ${resp1.statusCode}");
      }

      if (resp0.statusCode == 200) {
        partesStatus0 = parteFromJson(resp0.body);
      } else {
        print("Error al obtener partes pendientes: ${resp0.statusCode}");
      }

      todosPartes = [...partesStatus1, ...partesStatus0];
      partes = [...partesStatus1, ...partesStatus0];

      notifyListeners();
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }

  Future<void> getPartesActivos() async {
    if (config.server.isEmpty) {
      await loadPartesLocal();
      return;
    }

    print("1");
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
    print("2");

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);
    print("3");

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }
    print("4");

    final url = Uri.http(server, '/api/partes', {
      'StatusParteLc': "1",
      'responsableParteLc': responsableParteLc,
    });
    print("5");

    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(resp.body);

      if (resp.statusCode == 200) {
        partes = parteFromJson(resp.body); // ✅ Actualizar lista principal
        filteredPartes = List.from(
            partes); // 🔥 Asegurar que filteredPartes también se actualiza
        notifyListeners(); // 🔥 Notificar cambios a la UI
      } else {
        print("Error al obtener partes activos: ${resp.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }

  Future<void> getPartesActivosAdministrador() async {
    if (config.server.isEmpty) {
      await loadPartesLocal();
      return;
    }

    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    final url = Uri.http(server, '/api/partes/Todos',
        {'StatusParteLc': '1'}); // Asegurar que se envía correctamente
    print("✅ URL generada: $url");

    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("📢 Código de respuesta: ${resp.statusCode}");
      print("📢 Respuesta del servidor: ${resp.body}");

      if (resp.statusCode == 200) {
        partes = parteFromJson(resp.body);
        notifyListeners();
      } else {
        print("❌ Error al obtener partes activos: ${resp.statusCode}");
      }
    } catch (e) {
      print("❌ Error en la solicitud HTTP: $e");
    }
  }

  Future<void> getPartesPendientesAdministrador() async {
    if (config.server.isEmpty) {
      await loadPartesLocal();
      return;
    }

    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    final url = Uri.http(server, '/api/partes/Todos', {'StatusParteLc': "0"});
    print(url);
    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        print("Entra en 200");
        partesPendientes = parteFromJson(resp.body);
        notifyListeners();
      } else {
        print("Error al obtener partes activos: ${resp.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }

  Future<void> getPartesTodosAdministrador() async {
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    List<parte_> partesStatus1 = [];
    List<parte_> partesStatus0 = [];

    try {
      final url1 =
          Uri.http(server, '/api/partes/Todos', {'StatusParteLc': "1"});
      final url0 =
          Uri.http(server, '/api/partes/Todos', {'StatusParteLc': "0"});

      print(url1);
      print(url0);

      final resp1 = await http.get(
        url1,
        headers: {'Content-Type': 'application/json'},
      );
      final resp0 = await http.get(
        url0,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp1.statusCode == 200) {
        partesStatus1 = parteFromJson(resp1.body);
      } else {
        print("Error al obtener partes activos: ${resp1.statusCode}");
      }

      if (resp0.statusCode == 200) {
        partesStatus0 = parteFromJson(resp0.body);
      } else {
        print("Error al obtener partes pendientes: ${resp0.statusCode}");
      }
      todosPartes = [...partesStatus1, ...partesStatus0];
      partes = [...partesStatus1, ...partesStatus0];

      notifyListeners();
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }

  Future<List<parte_>> getPendingPartesActivos() async {
    return partes;
  }

  Future<List<parte_>> getPendingPartesPendientes() async {
    return partesPendientes;
  }

  Future<List<parte_>> getPendingPartesTodos() async {
    return todosPartes;
  }

  Future<void> getPartesPendientes() async {
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    final url = Uri.http(server, '/api/partes', {
      'StatusParteLc': "0",
      'responsableParteLc': responsableParteLc,
    });

    try {
      final resp = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (resp.statusCode == 200) {
        partesPendientes = parteFromJson(resp.body);
        notifyListeners();
      } else {
        print("Error al obtener partes pendientes: ${resp.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }

  Future<void> getPartesTodos() async {
    final server = config.server
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');

    final isValidServer =
        RegExp(r'^([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,}(:[0-9]{1,5})?$')
            .hasMatch(server);

    if (!isValidServer) {
      print("Error: Servidor no válido: $server");
      await loadPartesLocal();
      return;
    }

    List<parte_> partesStatus1 = [];
    List<parte_> partesStatus0 = [];

    try {
      final url1 = Uri.http(server, '/api/partes', {
        'StatusParteLc': "1",
        'responsableParteLc': responsableParteLc,
      });
      final url0 = Uri.http(server, '/api/partes', {
        'StatusParteLc': "0",
        'responsableParteLc': responsableParteLc,
      });

      print("Intentando conectarse a: $url1 y $url0");
      print("hey");

      final resp1 = await http.get(
        url1,
        headers: {'Content-Type': 'application/json'},
      );
      final resp0 = await http.get(
        url0,
        headers: {'Content-Type': 'application/json'},
      );
      print(resp1.body);

      if (resp1.statusCode == 200) {
        partesStatus1 = parteFromJson(resp1.body);
      } else {
        print("Error al obtener partes activos: ${resp1.statusCode}");
      }

      if (resp0.statusCode == 200) {
        partesStatus0 = parteFromJson(resp0.body);
      } else {
        print("Error al obtener partes pendientes: ${resp0.statusCode}");
      }
      todosPartes = [...partesStatus1, ...partesStatus0];
      partes = [...partesStatus1, ...partesStatus0];

      notifyListeners();
    } catch (e) {
      print("Error en la solicitud HTTP: $e");
    }
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<void> removeParteCerradoLocally(
      Map<String, dynamic> partesCerrados) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLines = prefs.getStringList('Cerrarparte') ?? [];
    jsonLines.remove(jsonEncode(partesCerrados));
    await prefs.setStringList('Cerrarparte', jsonLines);
    print("Parte Cerrado Eliminado $partesCerrados");
  }

  /// Actualizar el estado de un parte
  Future<bool> actualizarStatusParte({
    required int codigoEmpresa,
    required String codigoTipoParteLC,
    required int ejercicioParteLC,
    required String serieParteLc,
    required int numeroParteLC,
    required int nuevoStatusParteLc,
  }) async {
    final url = Uri.http(config.server, 'api/Partes/ActualizarStatus', {
      "codigoEmpresa": "$codigoEmpresa",
      "codigoTipoParteLC": codigoTipoParteLC,
      "ejercicioParteLC": "$ejercicioParteLC",
      "serieParteLc": serieParteLc,
      "numeroParteLC": "$numeroParteLC",
    });

    final body = jsonEncode(nuevoStatusParteLc);
    print("=================");

    try {
      final resp = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: body,
      );
      print(resp.body);

      if (resp.statusCode == 200) {
        print("Estado actualizado correctamente: ${resp.body}");
        return true; // Operación exitosa
      } else {
        print("Error al actualizar el estado: ${resp.statusCode}");
        return false; // Error en la operación
      }
    } catch (e) {
      bool estadoInternet = await _checkInternetAccess();
      if (estadoInternet == false) {
        await saveCerrarParteLocal({
          'codigoEmpresa': codigoEmpresa,
          'codigoTipoParteLC': codigoTipoParteLC,
          'ejercicioParteLC': ejercicioParteLC,
          'serieParteLc': serieParteLc,
          'numeroParteLC': numeroParteLC
        });

        return false; // Error en la operación
      } else {
        print("Error al actualizar parte: $e");
        return false; // Error en la operación
      }
    }
  }
}
