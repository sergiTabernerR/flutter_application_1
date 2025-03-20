import 'dart:convert';

List<LineasAlbaran> lineasAlbaranFromJson(String str) =>
    List<LineasAlbaran>.from(
        json.decode(str).map((x) => LineasAlbaran.fromJson(x)));

String lineasAlbaranToJson(List<LineasAlbaran> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LineasAlbaran {
  int codigoEmpresa;
  int ejercicioAlbaran;
  String? serieAlbaran;
  int numeroAlbaran;
  int orden;
  String codigoArticulo;
  String descripcionArticulo;
  double unidades;
  double unidades2;
  double precio;
  double importeNeto;
  double importeLiquido;
  String lineasPosicion;

  LineasAlbaran({
    required this.codigoEmpresa,
    required this.ejercicioAlbaran,
    required this.serieAlbaran,
    required this.numeroAlbaran,
    required this.orden,
    required this.codigoArticulo,
    required this.descripcionArticulo,
    required this.unidades,
    required this.unidades2,
    required this.precio,
    required this.importeNeto,
    required this.importeLiquido,
    required this.lineasPosicion,
  });

  factory LineasAlbaran.fromJson(Map<String, dynamic> json) => LineasAlbaran(
        codigoEmpresa: json["codigoEmpresa"] ?? 0,
        ejercicioAlbaran: json["ejercicioAlbaran"] ?? 0,
        serieAlbaran: json["serieAlbaran"] ?? "",
        numeroAlbaran: json["numeroAlbaran"] ?? 0,
        orden: json["orden"] ?? 0,
        codigoArticulo: json["codigoArticulo"] ?? "",
        descripcionArticulo: json["descripcionArticulo"] ?? "",
        unidades: (json["unidades"] ?? 0).toDouble(),
        unidades2: (json["unidades2"] ?? 0).toDouble(),
        precio: (json["precio"] ?? 0).toDouble(),
        importeNeto: (json["importeNeto"] ?? 0).toDouble(),
        importeLiquido: (json["importeLiquido"] ?? 0).toDouble(),
        lineasPosicion: json["lineasPosicion"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "codigoEmpresa": codigoEmpresa,
        "ejercicioAlbaran": ejercicioAlbaran,
        "serieAlbaran": serieAlbaran,
        "numeroAlbaran": numeroAlbaran,
        "orden": orden,
        "codigoArticulo": codigoArticulo,
        "descripcionArticulo": descripcionArticulo,
        "unidades": unidades,
        "unidades2": unidades2,
        "precio": precio,
        "importeNeto": importeNeto,
        "importeLiquido": importeLiquido,
        "lineasPosicion": lineasPosicion,
      };
}
