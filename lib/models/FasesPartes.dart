// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Fases> FasesparteFromJson(String str) =>
    List<Fases>.from(json.decode(str).map((x) => Fases.fromJson(x)));

String FasesparteToJson(List<Fases> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Fases {
  String? codigoTipoParteLc;
  int? codigoEmpresa;
  int? ejercicioParteLC;
  String? serieParteLc;
  int? numeroParteLc;
  String? codigoTipoFaseLc;
  DateTime? fechaInicialLc;
  DateTime? fechaPrevistaLc;
  int? statusFaseLc;

  Fases({
    required this.codigoTipoParteLc,
    required this.codigoEmpresa,
    required this.ejercicioParteLC,
    required this.serieParteLc,
    required this.numeroParteLc,
    required this.codigoTipoFaseLc,
    required this.fechaInicialLc,
    required this.fechaPrevistaLc,
    required this.statusFaseLc,
  });

  factory Fases.fromJson(Map<String, dynamic> json) {
    try {
      return Fases(
        codigoTipoParteLc:
            json["codigoTipoParteLc"] ?? "", // Valor predeterminado
        codigoEmpresa: json["codigoEmpresa"] ?? 0,
        ejercicioParteLC: json["ejercicioParteLC"] ?? 0,
        serieParteLc: json["serieParteLc"] ?? "", // Valor predeterminado
        numeroParteLc: json["numeroParteLc"] ?? 0,
        codigoTipoFaseLc:
            json["codigoTipoFaseLc"] ?? "", // Valor predeterminado
        fechaInicialLc: json["fechaInicialLc"] != null
            ? DateTime.parse(json["fechaInicialLc"])
            : null,
        fechaPrevistaLc: json["fechaPrevistaLc"] != null
            ? DateTime.parse(json["fechaPrevistaLc"])
            : null,
        statusFaseLc: json["statusFaseLc"] ?? 0,
      );
    } catch (e) {
      throw FormatException(
          "Error al convertir JSON en Fases. Detalle: $e, JSON: $json");
    }
  }

  Map<String, dynamic> toJson() => {
        "codigoTipoParteLc": codigoTipoParteLc,
        "codigoEmpresa": codigoEmpresa,
        "ejercicioParteLC": ejercicioParteLC,
        "serieParteLc": serieParteLc,
        "numeroParteLc": numeroParteLc,
        "codigoTipoFaseLc": codigoTipoFaseLc,
        "fechaInicialLc": fechaInicialLc?.toIso8601String(),
        "fechaPrevistaLc": fechaPrevistaLc?.toIso8601String(),
        "statusFaseLc": statusFaseLc,
      };
  // 🚀 Sobrescribimos `==` y `hashCode` para evitar duplicados en `Set`
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fases && other.codigoTipoFaseLc == codigoTipoFaseLc);

  @override
  int get hashCode => codigoTipoFaseLc.hashCode;
}
