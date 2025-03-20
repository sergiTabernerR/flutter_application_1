import 'dart:convert';

List<CabeceraAlbaran> cabeceraAlbaranFromJson(String str) =>
    List<CabeceraAlbaran>.from(
        json.decode(str).map((x) => CabeceraAlbaran.fromJson(x)));

String cabeceraAlbaranToJson(List<CabeceraAlbaran> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CabeceraAlbaran {
  int codigoEmpresa;
  int ejercicioAlbaran;
  String? serieAlbaran;
  int numeroAlbaran;
  String codigoTipoParteLc;
  int ejercicioParteLc;
  String serieParteLc;
  int numeroParteLc;

  CabeceraAlbaran(
      {required this.codigoEmpresa,
      required this.ejercicioAlbaran,
      required this.serieAlbaran,
      required this.numeroAlbaran,
      required this.codigoTipoParteLc,
      required this.ejercicioParteLc,
      required this.serieParteLc,
      required this.numeroParteLc});

  factory CabeceraAlbaran.fromJson(Map<String, dynamic> json) =>
      CabeceraAlbaran(
        codigoEmpresa: json["codigoEmpresa"] ?? 0,
        ejercicioAlbaran: json["ejercicioAlbaran"] ?? 0,
        serieAlbaran: json["serieAlbaran"] ?? "",
        numeroAlbaran: json["numeroAlbaran"] ?? 0,
        codigoTipoParteLc: json["codigoTipoParteLc"] ?? 0,
        ejercicioParteLc: json["ejercicioParteLc"] ?? 0,
        serieParteLc: json["serieParteLc"] ?? "",
        numeroParteLc: (json["numeroParteLc"] ?? 0),
      );

  Map<String, dynamic> toJson() => {
        "codigoEmpresa": codigoEmpresa,
        "ejercicioAlbaran": ejercicioAlbaran,
        "serieAlbaran": serieAlbaran,
        "numeroAlbaran": numeroAlbaran,
        "codigoTipoParteLc": codigoTipoParteLc,
        "ejercicioParteLc": ejercicioParteLc,
        "serieParteLc": serieParteLc,
        "numeroParteLc": numeroParteLc,
      };
}
