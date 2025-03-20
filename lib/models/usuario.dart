// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Usuarios> usuarioFromJson(String str) =>
    List<Usuarios>.from(json.decode(str).map((x) => Usuarios.fromJson(x)));

String usuarioToJson(List<Usuarios> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Usuarios {
  String codigoCliente;
  String usuarioLogicNet;
  String contraseaLogicNet;
  String codigoCategoriaEmpleadoLc;

  Usuarios({
    required this.codigoCliente,
    required this.usuarioLogicNet,
    required this.contraseaLogicNet,
    required this.codigoCategoriaEmpleadoLc,
  });

  factory Usuarios.fromJson(Map<String, dynamic> json) => Usuarios(
        codigoCliente: json["codigoCliente"],
        usuarioLogicNet: json["usuarioLogicNet"],
        contraseaLogicNet: json["contraseñaLogicNet"],
        codigoCategoriaEmpleadoLc: json["codigoCategoriaEmpleadoLc"],
      );

  Map<String, dynamic> toJson() => {
        "codigoCliente": codigoCliente,
        "usuarioLogicNet": usuarioLogicNet,
        "contraseñaLogicNet": contraseaLogicNet,
        "codigoCategoriaEmpleadoLc": codigoCategoriaEmpleadoLc,
      };
}

enum ContraseaLogicNet { CONTRASEA1, EMPTY }

final contraseaLogicNetValues = EnumValues(
    {"Contraseña1": ContraseaLogicNet.CONTRASEA1, "": ContraseaLogicNet.EMPTY});

enum UsuarioLogicNet { EMPTY, MERCEDES }

final usuarioLogicNetValues = EnumValues(
    {"": UsuarioLogicNet.EMPTY, "Mercedes": UsuarioLogicNet.MERCEDES});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
