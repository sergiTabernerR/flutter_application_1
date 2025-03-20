import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/DomicilioProvider.dart';
import 'package:flutter_application_1/models/Domicilio.dart';
import 'package:flutter_application_1/screens/CrearDomicilioScreen.dart';
import 'package:provider/provider.dart';

class DomicilioScreen extends StatelessWidget {
  final String codigoCliente;
  final int codigoEmpresa;

  DomicilioScreen({required this.codigoCliente, required this.codigoEmpresa});

  @override
  Widget build(BuildContext context) {
    final domicilioProvider =
        Provider.of<Domicilioprovider>(context, listen: false);

    // Cargar domicilios al entrar a la pantalla
    domicilioProvider.fetchDomiciliosPorCliente(codigoCliente, codigoEmpresa);

    return Scaffold(
      appBar: AppBar(
        title: Text("Domicilios"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: Consumer<Domicilioprovider>(
        builder: (context, domicilioProvider, child) {
          if (domicilioProvider.domicilio.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 10),
                  Text(
                    "Cargando domicilios...",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: domicilioProvider.domicilio.length,
            itemBuilder: (context, index) {
              final domicilio = domicilioProvider.domicilio[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.home, color: Colors.blueAccent, size: 30),
                  title: Text(
                    domicilio.nombre ?? "Sin nombre",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    domicilio.domicilio ?? "Sin dirección",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context, domicilio);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nuevoDomicilio = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrearDomicilioScreen(
                codigoCliente: codigoCliente,
                codigoEmpresa: codigoEmpresa,
              ),
            ),
          );

          if (nuevoDomicilio != null) {
            domicilioProvider.fetchDomiciliosPorCliente(codigoCliente, codigoEmpresa);
          }
        },
        icon: Icon(Icons.add),
        label: Text("Añadir domicilio"),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
