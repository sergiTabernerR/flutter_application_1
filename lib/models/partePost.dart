// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<LineasParte> LineasParteFromJson(String str) => List<LineasParte>.from(
    json.decode(str).map((x) => LineasParte.fromJson(x)));

class LineasParte {
  int? codigoEmpresa;
  String? codigoTipoParteLc;
  int? ejercicioParteLc;
  String? serieParteLc;
  int? numeroParteLc;
  String? codigoTipoFaseLc;
  String? codigoActividadParteLc;
  String? tecnicoAsignadoLc;
  String? codigoGastoComercialLc;
  int? facturableLc;
  String? codigoArticulo;
  String? descripcionArticulo;
  String? codigoAlmacen;
  String? numeroSerieLc;
  double? unidades;
  double? precio;
  double? importe;
  double? precioCoste;
  double? horaEntradaLc;
  int? liquidableLc;
  String? observaciones;

  LineasParte({
    this.codigoEmpresa,
    this.codigoTipoParteLc,
    this.ejercicioParteLc,
    this.serieParteLc,
    this.numeroParteLc,
    this.codigoTipoFaseLc,
    this.codigoActividadParteLc,
    this.tecnicoAsignadoLc,
    this.codigoGastoComercialLc,
    this.facturableLc,
    this.codigoArticulo,
    this.descripcionArticulo,
    this.codigoAlmacen,
    this.numeroSerieLc,
    this.unidades,
    this.precio,
    this.importe,
    this.precioCoste,
    this.horaEntradaLc,
    this.liquidableLc,
    this.observaciones,
  });

  factory LineasParte.fromJson(Map<String, dynamic> json) {
    return LineasParte(
      codigoEmpresa: json['codigoEmpresa'],
      codigoTipoParteLc: json['codigoTipoParteLc'] ?? '',
      ejercicioParteLc: json['ejercicioParteLc'],
      serieParteLc: json['serieParteLc'] ?? '',
      numeroParteLc: json['numeroParteLc'],
      codigoTipoFaseLc: json['codigoTipoFaseLc'] ?? '',
      codigoActividadParteLc: json['codigoActividadParteLc'] ?? '',
      tecnicoAsignadoLc: json['tecnicoAsignadoLc'] ?? '',
      codigoGastoComercialLc: json['codigoGastoComercialLc'] ?? '',
      facturableLc: json['facturableLc'] ?? 0,
      codigoArticulo: json['codigoArticulo'] ?? '',
      descripcionArticulo: json['descripcionArticulo'] ?? '',
      codigoAlmacen: json['codigoAlmacen'] ?? '',
      numeroSerieLc: json['numeroSerieLc'] ?? '',
      unidades: (json['unidades'] ?? 0).toDouble(),
      precio: (json['precio'] ?? 0).toDouble(),
      importe: (json['importe'] ?? 0).toDouble(),
      precioCoste: (json['precioCoste'] ?? 0).toDouble(),
      horaEntradaLc: (json['horaEntradaLc'] ?? 0).toDouble(),
      liquidableLc: json['liquidableLc'] ?? 0,
      observaciones: json['observaciones'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'codigoEmpresa': codigoEmpresa,
      'codigoTipoParteLc': codigoTipoParteLc,
      'ejercicioParteLc': ejercicioParteLc,
      'serieParteLc': serieParteLc,
      'numeroParteLc': numeroParteLc,
      'codigoTipoFaseLc': codigoTipoFaseLc,
      'codigoActividadParteLc': codigoActividadParteLc,
      'tecnicoAsignadoLc': tecnicoAsignadoLc,
      'codigoGastoComercialLc': codigoGastoComercialLc,
      'facturableLc': facturableLc,
      'codigoArticulo': codigoArticulo,
      'descripcionArticulo': descripcionArticulo,
      'codigoAlmacen': codigoAlmacen,
      'numeroSerieLc': numeroSerieLc,
      'unidades': unidades,
      'precio': precio,
      'importe': importe,
      'precioCoste': precioCoste,
      'horaEntradaLc': horaEntradaLc,
      'liquidableLc': liquidableLc,
      'observaciones': observaciones,
    };
  }
}
