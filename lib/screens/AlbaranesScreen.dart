import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/VinculacionAlbaran_Provider.dart';
import 'package:provider/provider.dart';

class AlbaranesScreen extends StatefulWidget {
  final int codigoEmpresa;
  final String codigoTipoParteLC;
  final int ejercicioParteLC;
  final String serieParteLc;
  final int numeroParteLC;

  const AlbaranesScreen({
    Key? key,
    required this.codigoEmpresa,
    required this.codigoTipoParteLC,
    required this.ejercicioParteLC,
    required this.serieParteLc,
    required this.numeroParteLC,
  }) : super(key: key);

  @override
  _AlbaranesScreenState createState() => _AlbaranesScreenState();
}

class _AlbaranesScreenState extends State<AlbaranesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<VinculacionAlbaran_Provider>(context, listen: false)
          .getArticulos(
        codigoEmpresa: widget.codigoEmpresa,
        codigoTipoParte: widget.codigoTipoParteLC,
        ejercicioParte: widget.ejercicioParteLC,
        serieParte: widget.serieParteLc,
        numeroParte: widget.numeroParteLC,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Detalle del Parte: ${widget.numeroParteLC}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green[700],
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 📌 Tarjeta con detalles del parte
            Card(
              elevation: 4,
              margin: EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Código Empresa:', widget.codigoEmpresa),
                    _buildDetailRow(
                        'Código Tipo Parte:', widget.codigoTipoParteLC),
                    _buildDetailRow(
                        'Ejercicio Parte:', widget.ejercicioParteLC),
                    _buildDetailRow('Serie Parte:', widget.serieParteLc),
                    _buildDetailRow('Número Parte:', widget.numeroParteLC),
                  ],
                ),
              ),
            ),

            // 📌 Tabla de Albaranes
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Consumer<VinculacionAlbaran_Provider>(
                  builder: (context, provider, child) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTableTheme(
                            data: DataTableThemeData(
                              headingRowColor:
                                  MaterialStateProperty.all(Colors.green[100]),
                              dataRowColor:
                                  MaterialStateProperty.all(Colors.white),
                              headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800]),
                            ),
                            child: DataTable(
                              columnSpacing: 25,
                              columns: const [
                                DataColumn(label: Text('Descripción Artículo')),
                                DataColumn(label: Text('Unidades')),
                                DataColumn(label: Text('Unidades Reales')),
                                DataColumn(label: Text('Ejercicio Albaran')),
                                DataColumn(label: Text('Serie Albaran')),
                                DataColumn(label: Text('Número Albaran')),
                              ],
                              rows: provider.filteredArticulos.map((albaran) {
                                return DataRow(cells: [
                                  DataCell(Text(albaran.descripcionArticulo)),
                                  DataCell(Text(albaran.unidades.toString())),
                                  DataCell(
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        initialValue:
                                            albaran.unidadesReales.toString(),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          double? newValue =
                                              double.tryParse(value);
                                          if (newValue != null) {
                                            final provider = Provider.of<
                                                    VinculacionAlbaran_Provider>(
                                                context,
                                                listen: false);

                                            provider
                                                .updateUnidadesPorLineaPosicion(
                                              lineasPosicion:
                                                  albaran.lineasPosicion,
                                              unidades: newValue,
                                            );

                                            setState(() {
                                              albaran.unidadesReales = newValue;
                                            });

                                            provider.notifyListeners();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                      Text(widget.ejercicioParteLC.toString())),
                                  DataCell(Text(albaran.serieParteLc)),
                                  DataCell(
                                      Text(albaran.numeroAlbaran.toString())),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Método para crear filas de detalles con estilo
  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green[800]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
