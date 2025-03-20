import 'dart:convert';

List<VinculacionAlbaran> vinculacionAlbaranFromJson(String str) =>
    List<VinculacionAlbaran>.from(
        json.decode(str).map((x) => VinculacionAlbaran.fromJson(x)));

String vinculacionAlbaranToJson(List<VinculacionAlbaran> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VinculacionAlbaran {
  int codigoEmpresa;
  String codigoTipoParteLc;
  int eJercicioParteLc;
  String serieParteLc;
  int numeroParteLc;
  int ejercicioAlbaran;
  String? serieAlbaran;
  int numeroAlbaran;
  String codigoArticulo;
  String descripcionArticulo;
  double unidades;
  double unidadesReales;
  double precio;
  double importeNeto;
  double importeLiquido;
  String lineasPosicion;

  VinculacionAlbaran(
      {required this.codigoEmpresa,
      required this.codigoTipoParteLc,
      required this.eJercicioParteLc,
      required this.serieParteLc,
      required this.numeroParteLc,
      required this.ejercicioAlbaran,
      required this.serieAlbaran,
      required this.numeroAlbaran,
      required this.codigoArticulo,
      required this.descripcionArticulo,
      required this.unidades,
      required this.unidadesReales,
      required this.precio,
      required this.importeNeto,
      required this.importeLiquido,
      required this.lineasPosicion});

  factory VinculacionAlbaran.fromJson(Map<String, dynamic> json) =>
      VinculacionAlbaran(
        codigoEmpresa: json["codigoEmpresa"] ?? 0,
        codigoTipoParteLc: json["codigoTipoParteLc"] ?? "",
        eJercicioParteLc: json["eJercicioParteLc"] ?? 0,
        serieParteLc: json["serieParteLc"] ?? "",
        numeroParteLc: json["numeroParteLc"] ?? 0,
        ejercicioAlbaran: json["ejercicioAlbaran"] ?? 0,
        serieAlbaran: json["serieAlbaran"] ?? "", // ✅ Manejo de null
        numeroAlbaran: json["numeroAlbaran"] ?? 0,
        codigoArticulo: json["codigoArticulo"] ?? "",
        descripcionArticulo: json["descripcionArticulo"] ?? "",
        unidades: (json["unidades"] ?? 0).toDouble(),
        unidadesReales: (json["unidadesReales"] ?? 0).toDouble(),
        precio: (json["precio"] ?? 0).toDouble(),
        importeNeto: (json["importeNeto"] ?? 0).toDouble(),
        importeLiquido: (json["importeLiquido"] ?? 0).toDouble(),
        lineasPosicion: json["lineasPosicion"] ?? "", // ✅ Manejo de null
      );

  Map<String, dynamic> toJson() => {
        "codigoEmpresa": codigoEmpresa,
        "codigoTipoParteLc": codigoTipoParteLc,
        "eJercicioParteLc": eJercicioParteLc,
        "serieParteLc": serieParteLc,
        "numeroParteLc": numeroParteLc,
        "ejercicioAlbaran": ejercicioAlbaran,
        "serieAlbaran": serieAlbaran,
        "numeroAlbaran": numeroAlbaran,
        "codigoArticulo": codigoArticulo,
        "descripcionArticulo": descripcionArticulo,
        "unidades": unidades,
        "unidadesReales": unidadesReales,
        "precio": precio,
        "importeNeto": importeNeto,
        "importeLiquido": importeLiquido,
        "lineasPosicion": lineasPosicion
      };
}
