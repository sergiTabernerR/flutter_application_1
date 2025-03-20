import 'dart:convert';

List<Domicilio> domicilioFromJson(String str) =>
    List<Domicilio>.from(json.decode(str).map((x) => Domicilio.fromJson(x)));

String domicilioToJson(List<Domicilio> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Domicilio {
  int? codigoEmpresa;
  String? tipoDomicilio;
  String? codigoCliente;
  int? numeroDomicilio;
  int? codigoTransportista;
  String? tipoPortes;
  String? nombre;
  String? razonSocial;
  String? razonSocial2;
  String? codigoSigla;
  String? viaPublica;
  String? numero1;
  String? numero2;
  String? escalera;
  String? piso;
  String? puerta;
  String? letra;
  String? domicilio;
  String? domicilio2;
  String? codigoPostal;
  String? codigoMunicipio;
  String? municipio;
  String? colaMunicipio;
  String? codigoProvincia;
  String? provincia;
  int? codigoNacion;
  String? nacion;
  String? telefono;
  String? telefono2;
  String? telefono3;
  String? fax;
  String? horarioDomicilioLc;
  String? personaClienteLc;
  String? referenciaEdi;
  String? idDomicilio;

  Domicilio({
    this.codigoEmpresa,
    this.tipoDomicilio,
    this.codigoCliente,
    this.numeroDomicilio,
    this.codigoTransportista,
    this.tipoPortes,
    this.nombre,
    this.razonSocial,
    this.razonSocial2,
    this.codigoSigla,
    this.viaPublica,
    this.numero1,
    this.numero2,
    this.escalera,
    this.piso,
    this.puerta,
    this.letra,
    this.domicilio,
    this.domicilio2,
    this.codigoPostal,
    this.codigoMunicipio,
    this.municipio,
    this.colaMunicipio,
    this.codigoProvincia,
    this.provincia,
    this.codigoNacion,
    this.nacion,
    this.telefono,
    this.telefono2,
    this.telefono3,
    this.fax,
    this.horarioDomicilioLc,
    this.personaClienteLc,
    this.referenciaEdi,
    this.idDomicilio,
  });

  factory Domicilio.fromJson(Map<String, dynamic> json) => Domicilio(
        codigoEmpresa: json["codigoEmpresa"],
        tipoDomicilio: json["tipoDomicilio"],
        codigoCliente: json["codigoCliente"],
        numeroDomicilio: json["numeroDomicilio"],
        codigoTransportista: json["codigoTransportista"],
        tipoPortes: json["tipoPortes"],
        nombre: json["nombre"],
        razonSocial: json["razonSocial"],
        razonSocial2: json["razonSocial2"],
        codigoSigla: json["codigoSigla"],
        viaPublica: json["viaPublica"],
        numero1: json["numero1"],
        numero2: json["numero2"],
        escalera: json["escalera"],
        piso: json["piso"],
        puerta: json["puerta"],
        letra: json["letra"],
        domicilio: json["domicilio"],
        domicilio2: json["domicilio2"],
        codigoPostal: json["codigoPostal"],
        codigoMunicipio: json["codigoMunicipio"],
        municipio: json["municipio"],
        colaMunicipio: json["colaMunicipio"],
        codigoProvincia: json["codigoProvincia"],
        provincia: json["provincia"],
        codigoNacion: json["codigoNacion"],
        nacion: json["nacion"],
        telefono: json["telefono"],
        telefono2: json["telefono2"],
        telefono3: json["telefono3"],
        fax: json["fax"],
        horarioDomicilioLc: json["horarioDomicilioLc"],
        personaClienteLc: json["personaClienteLc"],
        referenciaEdi: json["referenciaEdi"],
        idDomicilio: json["idDomicilio"],
      );

  Map<String, dynamic> toJson() => {
        "codigoEmpresa": codigoEmpresa,
        "tipoDomicilio": tipoDomicilio,
        "codigoCliente": codigoCliente,
        "numeroDomicilio": numeroDomicilio,
        "codigoTransportista": codigoTransportista,
        "tipoPortes": tipoPortes,
        "nombre": nombre,
        "razonSocial": razonSocial,
        "razonSocial2": razonSocial2,
        "codigoSigla": codigoSigla,
        "viaPublica": viaPublica,
        "numero1": numero1,
        "numero2": numero2,
        "escalera": escalera,
        "piso": piso,
        "puerta": puerta,
        "letra": letra,
        "domicilio": domicilio,
        "domicilio2": domicilio2,
        "codigoPostal": codigoPostal,
        "codigoMunicipio": codigoMunicipio,
        "municipio": municipio,
        "colaMunicipio": colaMunicipio,
        "codigoProvincia": codigoProvincia,
        "provincia": provincia,
        "codigoNacion": codigoNacion,
        "nacion": nacion,
        "telefono": telefono,
        "telefono2": telefono2,
        "telefono3": telefono3,
        "fax": fax,
        "horarioDomicilioLc": horarioDomicilioLc,
        "personaClienteLc": personaClienteLc,
        "referenciaEdi": referenciaEdi,
        "idDomicilio": idDomicilio,
      };
}
