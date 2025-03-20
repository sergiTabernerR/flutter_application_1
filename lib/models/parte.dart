// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<parte_> parteFromJson(String str) =>
    List<parte_>.from(json.decode(str).map((x) => parte_.fromJson(x)));

String parteToJson(List<parte_> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class parte_ {
  String idParte;
  int codigoEmpresa;
  String codigoTipoParteLC;
  int ejercicioParteLC;
  String serieParteLc;
  int numeroParteLC;
  String codigoCliente;
  String codigoArticulo;
  String observaciones;
  DateTime fecha;
  String responsableParteLc;
  int statusParteLc;
  String? mM_HorasC;
  double? mM_HorasG;
  String? mm_fechafinGarantia;
  String? mM_HorasPR;
  String? mM_ResponsableParte;
  String? mM_OBSERVACIONESPARTE;
  String? observacionesInternas;
  String municipio;
  String razonSocial;
  int numeroDomicilio;
  String domicilio;
  String telefono;

  parte_(
      {required this.idParte,
      required this.codigoEmpresa,
      required this.codigoTipoParteLC,
      required this.ejercicioParteLC,
      required this.serieParteLc,
      required this.numeroParteLC,
      required this.codigoCliente,
      required this.codigoArticulo,
      required this.observaciones,
      required this.fecha,
      required this.responsableParteLc,
      required this.statusParteLc,
      this.mM_HorasC,
      this.mM_HorasG,
      this.mm_fechafinGarantia,
      this.mM_HorasPR,
      this.mM_ResponsableParte,
      this.mM_OBSERVACIONESPARTE,
      required this.municipio,
      required this.razonSocial,
      required this.numeroDomicilio,
      required this.domicilio,
      required this.telefono,
      required this.observacionesInternas});

  factory parte_.fromJson(Map<String, dynamic> json) {
    return parte_(
      idParte: json['idParte'],
      codigoEmpresa: json['codigoEmpresa'],
      codigoTipoParteLC: json['codigoTipoParteLC'],
      ejercicioParteLC: json['ejercicioParteLC'],
      serieParteLc: json['serieParteLc'],
      numeroParteLC: json['numeroParteLC'],
      codigoCliente: json['codigoCliente'],
      codigoArticulo: json['codigoArticulo'],
      observaciones: json['observaciones'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      responsableParteLc: json['responsableParteLc'],
      statusParteLc: json['statusParteLc'],
      mM_HorasC: json['mM_HorasC'],
      mM_HorasG: json['mM_HorasG']?.toDouble(),
      mm_fechafinGarantia: json['mm_fechafinGarantia'],
      mM_HorasPR: json['mM_HorasPR'],
      mM_ResponsableParte: json['mM_ResponsableParte'],
      mM_OBSERVACIONESPARTE: json['mM_OBSERVACIONESPARTE'],
      municipio: json['municipio'],
      razonSocial: json['razonSocial'],
      numeroDomicilio: json['numeroDomicilio'] ?? 0,
      domicilio: json['domicilio'],
      telefono: json['telefono'],
      observacionesInternas: json['observacionesInternas'],
    );
  }

  parte_ copyWith(Map<String, dynamic> cambios) {
    return parte_(
      idParte: idParte, // No modificamos la clave primaria
      codigoEmpresa: cambios.containsKey("codigoEmpresa")
          ? cambios["codigoEmpresa"] as int? ?? codigoEmpresa
          : codigoEmpresa,
      codigoTipoParteLC: cambios.containsKey("codigoTipoParteLC")
          ? cambios["codigoTipoParteLC"] as String? ?? codigoTipoParteLC
          : codigoTipoParteLC,
      ejercicioParteLC: cambios.containsKey("ejercicioParteLC")
          ? cambios["ejercicioParteLC"] as int? ?? ejercicioParteLC
          : ejercicioParteLC,
      serieParteLc: cambios.containsKey("serieParteLc")
          ? cambios["serieParteLc"] as String? ?? serieParteLc
          : serieParteLc,
      numeroParteLC: cambios.containsKey("numeroParteLC")
          ? cambios["numeroParteLC"] as int? ?? numeroParteLC
          : numeroParteLC,
      codigoCliente: cambios.containsKey("codigoCliente")
          ? cambios["codigoCliente"] as String? ?? codigoCliente
          : codigoCliente,
      codigoArticulo: cambios.containsKey("codigoArticulo")
          ? cambios["codigoArticulo"] as String? ?? codigoArticulo
          : codigoArticulo,
      observaciones: cambios.containsKey("observaciones")
          ? cambios["observaciones"] as String? ?? observaciones
          : observaciones,
      fecha: cambios.containsKey("fecha")
          ? DateTime.tryParse(cambios["fecha"]) ?? fecha
          : fecha,
      responsableParteLc: cambios.containsKey("responsableParteLc")
          ? cambios["responsableParteLc"] as String? ?? responsableParteLc
          : responsableParteLc,
      statusParteLc: cambios.containsKey("statusParteLc")
          ? cambios["statusParteLc"] as int? ?? statusParteLc
          : statusParteLc,
      mM_HorasC: cambios.containsKey("mM_HorasC")
          ? cambios["mM_HorasC"] as String? ?? mM_HorasC
          : mM_HorasC,
      mM_HorasG: cambios.containsKey("mM_HorasG")
          ? (cambios["mM_HorasG"] as num?)?.toDouble() ?? mM_HorasG
          : mM_HorasG,
      mm_fechafinGarantia: cambios.containsKey("mm_fechafinGarantia")
          ? cambios["mm_fechafinGarantia"] as String? ?? mm_fechafinGarantia
          : mm_fechafinGarantia,
      mM_HorasPR: cambios.containsKey("mM_HorasPR")
          ? cambios["mM_HorasPR"] as String? ?? mM_HorasPR
          : mM_HorasPR,
      mM_ResponsableParte: cambios.containsKey("mM_ResponsableParte")
          ? cambios["mM_ResponsableParte"] as String? ?? mM_ResponsableParte
          : mM_ResponsableParte,
      mM_OBSERVACIONESPARTE: cambios.containsKey("mM_OBSERVACIONESPARTE")
          ? cambios["mM_OBSERVACIONESPARTE"] as String? ?? mM_OBSERVACIONESPARTE
          : mM_OBSERVACIONESPARTE,
      observacionesInternas: cambios.containsKey("observacionesInternas")
          ? cambios["observacionesInternas"] as String? ?? observacionesInternas
          : observacionesInternas,
      municipio: cambios.containsKey("municipio")
          ? cambios["municipio"] as String? ?? municipio
          : municipio,
      razonSocial: cambios.containsKey("razonSocial")
          ? cambios["razonSocial"] as String? ?? razonSocial
          : razonSocial,
      numeroDomicilio: cambios.containsKey("numeroDomicilio")
          ? cambios["numeroDomicilio"] as int? ?? numeroDomicilio
          : numeroDomicilio,
      domicilio: cambios.containsKey("domicilio")
          ? cambios["domicilio"] as String? ?? domicilio
          : domicilio,
      telefono: cambios.containsKey("telefono")
          ? cambios["telefono"] as String? ?? telefono
          : telefono,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idParte': idParte,
      'codigoEmpresa': codigoEmpresa,
      'codigoTipoParteLC': codigoTipoParteLC,
      'ejercicioParteLC': ejercicioParteLC,
      'serieParteLc': serieParteLc,
      'numeroParteLC': numeroParteLC,
      'codigoCliente': codigoCliente,
      'codigoArticulo': codigoArticulo,
      'observaciones': observaciones,
      'fecha': fecha.toIso8601String(),
      'responsableParteLc': responsableParteLc,
      'statusParteLc': statusParteLc,
      'mM_HorasC': mM_HorasC,
      'mM_HorasG': mM_HorasG,
      'mm_fechafinGarantia': mm_fechafinGarantia,
      'mM_HorasPR': mM_HorasPR,
      'mM_ResponsableParte': mM_ResponsableParte,
      'mM_OBSERVACIONESPARTE': mM_OBSERVACIONESPARTE,
      'municipio': municipio,
      'razonSocial': razonSocial,
      'numeroDomicilio': numeroDomicilio,
      'domicilio': domicilio,
      'telefono': telefono,
      'observacionesInternas': observacionesInternas
    };
  }
}
