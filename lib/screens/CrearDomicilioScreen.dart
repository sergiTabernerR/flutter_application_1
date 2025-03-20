import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/DomicilioProvider.dart';
import 'package:flutter_application_1/models/Domicilio.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CrearDomicilioScreen extends StatefulWidget {
  final String codigoCliente;
  final int codigoEmpresa;

  CrearDomicilioScreen(
      {required this.codigoCliente, required this.codigoEmpresa});

  @override
  _CrearDomicilioScreenState createState() => _CrearDomicilioScreenState();
}

class _CrearDomicilioScreenState extends State<CrearDomicilioScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controladores para los campos de texto
  final TextEditingController codigoTransportistaController =
      TextEditingController();
  final TextEditingController tipoPortesController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController razonSocialController = TextEditingController();
  final TextEditingController razonSocial2Controller = TextEditingController();
  final TextEditingController codigoSiglaController = TextEditingController();
  final TextEditingController viaPublicaController = TextEditingController();
  final TextEditingController numero1Controller = TextEditingController();
  final TextEditingController numero2Controller = TextEditingController();
  final TextEditingController escaleraController = TextEditingController();
  final TextEditingController pisoController = TextEditingController();
  final TextEditingController puertaController = TextEditingController();
  final TextEditingController letraController = TextEditingController();
  final TextEditingController domicilioController = TextEditingController();
  final TextEditingController domicilio2Controller = TextEditingController();
  final TextEditingController codigoPostalController = TextEditingController();
  final TextEditingController codigoMunicipioController =
      TextEditingController();
  final TextEditingController municipioController = TextEditingController();
  final TextEditingController colaMunicipioController = TextEditingController();
  final TextEditingController codigoProvinciaController =
      TextEditingController();
  final TextEditingController provinciaController = TextEditingController();
  final TextEditingController codigoNacionController = TextEditingController();
  final TextEditingController nacionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController telefono2Controller = TextEditingController();
  final TextEditingController telefono3Controller = TextEditingController();
  final TextEditingController faxController = TextEditingController();
  final TextEditingController horarioDomicilioLcController =
      TextEditingController();
  final TextEditingController personaClienteLcController =
      TextEditingController();
  final TextEditingController referenciaEdiController = TextEditingController();

  void _guardarDomicilio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    var uuid = Uuid();

    Domicilio nuevoDomicilio = Domicilio(
        codigoEmpresa: widget.codigoEmpresa,
        codigoCliente: widget.codigoCliente,
        nombre: nombreController.text,
        razonSocial: razonSocialController.text,
        domicilio: domicilioController.text,
        domicilio2: "",
        codigoPostal: codigoPostalController.text,
        codigoMunicipio: "",
        municipio: municipioController.text,
        codigoProvincia: "",
        codigoSigla: "ES",
        provincia: provinciaController.text,
        codigoTransportista: 0,
        nacion: nacionController.text,
        codigoNacion: 108,
        colaMunicipio: "",
        telefono: telefonoController.text,
        fax: faxController.text,
        escalera: escaleraController.text,
        horarioDomicilioLc: horarioDomicilioLcController.text,
        puerta: puertaController.text,
        tipoPortes: tipoPortesController.text,
        razonSocial2: razonSocial2Controller.text,
        telefono2: telefono2Controller.text,
        telefono3: telefono3Controller.text,
        letra: letraController.text,
        numero1: numero1Controller.text,
        numero2: numero2Controller.text,
        personaClienteLc: personaClienteLcController.text,
        piso: pisoController.text,
        viaPublica: viaPublicaController.text,
        idDomicilio: uuid.v4());

    bool resultado =
        await Provider.of<Domicilioprovider>(context, listen: false)
            .addDomicilio(nuevoDomicilio, widget.codigoCliente);

    setState(() => _isSaving = false);

    if (resultado) {
      Navigator.pop(context, nuevoDomicilio);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear domicilio")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Domicilio")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Nombre", nombreController),
              _buildTextField("Razón Social", razonSocialController),
              _buildTextField("Domicilio", domicilioController),
              _buildTextField("Código Postal", codigoPostalController),
              _buildTextField("Municipio", municipioController),
              _buildTextField("Provincia", provinciaController),
              _buildTextField("Nación", nacionController),
              _buildTextField("Teléfono", telefonoController),
              _buildTextField("Fax", faxController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _guardarDomicilio,
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Guardar"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Campo obligatorio" : null,
      ),
    );
  }
}
