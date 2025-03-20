import 'dart:convert';

List<ActividadParte> actividadParteFromJson(String str) =>
    List<ActividadParte>.from(
        json.decode(str).map((x) => ActividadParte.fromJson(x)));

String actividadParteToJson(List<ActividadParte> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActividadParte {
  int? codigoEmpresa;
  String? codigoActividadParteLc;
  String? actividadParteLc;
  int? imputableLc;
  String? codigoArticulo;
  String? codigoGrupoActividadParteLc;
  int? esVisibleEnMovil;

  ActividadParte(
      {required this.codigoEmpresa,
      required this.codigoActividadParteLc,
      required this.actividadParteLc,
      required this.imputableLc,
      required this.codigoArticulo,
      required this.codigoGrupoActividadParteLc,
      required this.esVisibleEnMovil});

  factory ActividadParte.fromJson(Map<String, dynamic> json) => ActividadParte(
        codigoEmpresa: json["codigoEmpresa"],
        codigoActividadParteLc: json["codigoActividadParteLc"],
        actividadParteLc: json["actividadParteLc"],
        imputableLc: json["imputableLc"],
        codigoArticulo: json["codigoArticulo"],
        codigoGrupoActividadParteLc: json["codigoGrupoActividadParteLc"],
        esVisibleEnMovil: json["esVisibleEnMovil"],
      );

  Map<String, dynamic> toJson() => {
        "codigoEmpresa": codigoEmpresa,
        "codigoActividadParteLc": codigoActividadParteLc,
        "actividadParteLc": actividadParteLc,
        "imputableLc": imputableLc,
        "codigoArticulo": codigoArticulo,
        "codigoGrupoActividadParteLc": codigoGrupoActividadParteLc,
        "esVisibleEnMovil": esVisibleEnMovil
      };
}
