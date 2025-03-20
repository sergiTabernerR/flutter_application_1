class ActualizarStatusParteRequest {
  int codigoEmpresa;
  String codigoTipoParteLC;
  int ejercicioParteLC;
  String serieParteLc;
  int numeroParteLC;
  int nuevoStatusParteLc;

  ActualizarStatusParteRequest({
    required this.codigoEmpresa,
    required this.codigoTipoParteLC,
    required this.ejercicioParteLC,
    required this.serieParteLc,
    required this.numeroParteLC,
    required this.nuevoStatusParteLc,
  });

  // Convertir el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      "CodigoEmpresa": codigoEmpresa,
      "CodigoTipoParteLC": codigoTipoParteLC,
      "EjercicioParteLC": ejercicioParteLC,
      "SerieParteLc": serieParteLc,
      "NumeroParteLC": numeroParteLC,
      "NuevoStatusParteLc": nuevoStatusParteLc,
    };
  }
}
