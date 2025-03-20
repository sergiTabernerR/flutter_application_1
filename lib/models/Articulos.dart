// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Articulos> articulosFromJson(String str) =>
    List<Articulos>.from(json.decode(str).map((x) => Articulos.fromJson(x)));

String articulosToJson(List<Articulos> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Articulos {
  int codigoEmpresa;
  String codigoArticulo;
  String descripcionArticulo;

  Articulos({
    required this.codigoEmpresa,
    required this.codigoArticulo,
    required this.descripcionArticulo,
  });

  factory Articulos.fromJson(Map<String, dynamic> json) => Articulos(
        codigoEmpresa: json["codigoEmpresa"],
        codigoArticulo: json["codigoArticulo"],
        descripcionArticulo: json["descripcionArticulo"],
      );

  Map<String, dynamic> toJson() => {
        "codigoEmpresa": codigoEmpresa,
        "codigoArticulo": codigoArticulo,
        "descripcionArticulo": descripcionArticulo,
      };
}
