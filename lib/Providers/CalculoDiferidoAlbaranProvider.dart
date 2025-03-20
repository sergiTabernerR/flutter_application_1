import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/CalculoDiferidoAlbaranResult.dart'; // Importa el modelo que creaste

class CalculoDiferidoAlbaranProvider with ChangeNotifier {
  List<CalculoDiferidoAlbaranResult> resultados = [];
  final config = GlobalConfig.instance.serverConfig;

  Future<void> getCalculoDiferido({
    required String tipoDoc,
    required int ejercicio,
    required int codigoEmpresa,
    required String serieAlbaran,
    required int numeroAlbaran,
  }) async {
    final url = Uri.http(
      config.server,
      'api/CalculoDiferidoAlbaran', // Ruta de la API que recibiría los parámetros
      {
        'tipoDoc': tipoDoc,
        'ejercicio': ejercicio.toString(),
        'codigoEmpresa': codigoEmpresa.toString(),
        'serieAlbaran': serieAlbaran,
        'numeroAlbaran': numeroAlbaran.toString(),
      },
    );

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        notifyListeners(); // Notifica a los widgets interesados
      } else {
        print('Error: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error al hacer la solicitud: $e');
    }
  }

  List<CalculoDiferidoAlbaranResult> get getResultados => resultados;
}
