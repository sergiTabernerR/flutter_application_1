import 'dart:convert';

// Función para deserializar el JSON en una lista de objetos Equipo
List<Equipo> equipoFromJson(String str) =>
    List<Equipo>.from(json.decode(str).map((x) => Equipo.fromJson(x)));

// Función para serializar la lista de objetos Equipo a JSON
String equipoToJson(List<Equipo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Equipo {
  String codigoEquipo;
  int codigoEmpresa;
  String codigoResponsable;
  String tecnicoAsignado;

  // Constructor de la clase Equipo
  Equipo({
    required this.codigoEquipo,
    required this.codigoEmpresa,
    required this.codigoResponsable,
    required this.tecnicoAsignado,
  });

  // Método para crear un objeto Equipo desde un mapa (JSON)
  factory Equipo.fromJson(Map<String, dynamic> json) => Equipo(
        codigoEquipo: json["codigoEquipo"],
        codigoEmpresa: json["codigoEmpresa"],
        codigoResponsable: json["codigoResponsable"],
        tecnicoAsignado:
            json["tecnicoAsignado"].trim(), // Trim para eliminar espacios
      );

  // Método para convertir un objeto Equipo en un mapa (JSON)
  Map<String, dynamic> toJson() => {
        "codigoEquipo": codigoEquipo,
        "codigoEmpresa": codigoEmpresa,
        "codigoResponsable": codigoResponsable,
        "tecnicoAsignado": tecnicoAsignado,
      };
}
