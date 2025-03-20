import 'dart:convert';

// Este modelo representará la estructura de la respuesta que esperamos de la API.
class CalculoDiferidoAlbaranResult {
  final int codigoEmpresa;
  final String tipoDoc;
  final int ejercicio;
  final String serieAlbaran;
  final int numeroAlbaran;
  final double
      calculoDiferido; // Ejemplo de un campo adicional que puede devolver la API

  CalculoDiferidoAlbaranResult({
    required this.codigoEmpresa,
    required this.tipoDoc,
    required this.ejercicio,
    required this.serieAlbaran,
    required this.numeroAlbaran,
    required this.calculoDiferido,
  });

  factory CalculoDiferidoAlbaranResult.fromJson(Map<String, dynamic> json) {
    return CalculoDiferidoAlbaranResult(
      codigoEmpresa: json["codigoEmpresa"],
      tipoDoc: json["tipoDoc"],
      ejercicio: json["ejercicio"],
      serieAlbaran: json["serieAlbaran"],
      numeroAlbaran: json["numeroAlbaran"],
      calculoDiferido:
          json["calculoDiferido"].toDouble(), // Suponiendo que es un número
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codigoEmpresa": codigoEmpresa,
      "tipoDoc": tipoDoc,
      "ejercicio": ejercicio,
      "serieAlbaran": serieAlbaran,
      "numeroAlbaran": numeroAlbaran,
      "calculoDiferido": calculoDiferido,
    };
  }
}

// Para convertir JSON a lista de resultados
List<CalculoDiferidoAlbaranResult> calculoDiferidoAlbaranResultFromJson(
    String str) {
  final jsonData = json.decode(str);
  return List<CalculoDiferidoAlbaranResult>.from(
      jsonData.map((x) => CalculoDiferidoAlbaranResult.fromJson(x)));
}

String calculoDiferidoAlbaranResultToJson(
    List<CalculoDiferidoAlbaranResult> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}
