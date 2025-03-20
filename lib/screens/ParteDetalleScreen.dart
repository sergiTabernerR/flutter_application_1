import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/DomicilioProvider.dart';
import 'package:flutter_application_1/Providers/parte_provider.dart';
import 'package:flutter_application_1/models/Domicilio.dart';
import 'package:flutter_application_1/screens/DomicilioScreen.dart';
import 'package:provider/provider.dart';
import '../models/parte.dart';
import 'package:intl/intl.dart';

class ParteDetalleScreen extends StatefulWidget {
  final parte_ parte;

  ParteDetalleScreen({required this.parte});

  @override
  _ParteDetalleScreenState createState() => _ParteDetalleScreenState();
}

class _ParteDetalleScreenState extends State<ParteDetalleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController numeroDomicilioController;
  late TextEditingController domicilioController;

  late TextEditingController codigoArticuloController;
  late TextEditingController observacionesController;
  late TextEditingController fechaController;
  late TextEditingController responsableParteLcController;
  late TextEditingController tecnicoPartLcController;

  late TextEditingController statusParteLcController;
  late TextEditingController horasMaquinaController;
  late TextEditingController horasReparacionController;
  late TextEditingController horasPreviasReparacionController;
  late TextEditingController fechaFinGarantiaController;
  late TextEditingController supervisorAsignadoLcController;
  late TextEditingController observacionesInternasController;
  late TextEditingController observacionesEstadoController;

  int? numeroDomicilio;
  String? domicilio;

  @override
  void initState() {
    super.initState();
    codigoArticuloController =
        TextEditingController(text: widget.parte.codigoArticulo);
    observacionesController =
        TextEditingController(text: widget.parte.observaciones);
    fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.parte.fecha),
    );
    responsableParteLcController =
        TextEditingController(text: widget.parte.responsableParteLc);
    statusParteLcController =
        TextEditingController(text: widget.parte.statusParteLc.toString());
    horasMaquinaController =
        TextEditingController(text: widget.parte.mM_HorasC?.toString() ?? "");
    horasReparacionController =
        TextEditingController(text: widget.parte.mM_HorasG?.toString() ?? "");
    horasPreviasReparacionController =
        TextEditingController(text: widget.parte.mM_HorasPR?.toString() ?? "");
    fechaFinGarantiaController =
        TextEditingController(text: widget.parte.mm_fechafinGarantia ?? "");
    supervisorAsignadoLcController =
        TextEditingController(text: widget.parte.mM_ResponsableParte ?? "");
    observacionesInternasController =
        TextEditingController(text: widget.parte.observacionesInternas ?? "");
    observacionesEstadoController =
        TextEditingController(text: widget.parte.mM_OBSERVACIONESPARTE ?? "");
    numeroDomicilioController = TextEditingController(
        text: widget.parte.numeroDomicilio?.toString() ?? "");
    domicilioController =
        TextEditingController(text: widget.parte.domicilio ?? "");
    tecnicoPartLcController =
        TextEditingController(text: widget.parte.mM_ResponsableParte ?? "");

    // Inicializar número de domicilio y domicilio
    numeroDomicilio = widget.parte.numeroDomicilio;
    domicilio = widget.parte.domicilio;
  }

  @override
  void dispose() {
    codigoArticuloController.dispose();
    observacionesController.dispose();
    fechaController.dispose();
    responsableParteLcController.dispose();
    statusParteLcController.dispose();
    horasMaquinaController.dispose();
    horasReparacionController.dispose();
    horasPreviasReparacionController.dispose();
    fechaFinGarantiaController.dispose();
    supervisorAsignadoLcController.dispose();
    observacionesInternasController.dispose();
    observacionesEstadoController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Construir el mapa con los cambios que se desean actualizar
    Map<String, dynamic> cambios = {};

    if (codigoArticuloController.text.isNotEmpty &&
        codigoArticuloController.text != widget.parte.codigoArticulo) {
      cambios["codigoArticulo"] = codigoArticuloController.text;
    }
    if (observacionesController.text.isNotEmpty &&
        observacionesController.text != widget.parte.observaciones) {
      cambios["observaciones"] = observacionesController.text;
    }
    if (fechaController.text.isNotEmpty) {
      cambios["fecha"] = fechaController.text;
    }
    if (responsableParteLcController.text.isNotEmpty &&
        responsableParteLcController.text != widget.parte.responsableParteLc) {
      cambios["responsableParteLc"] = responsableParteLcController.text;
    }
    if (statusParteLcController.text.isNotEmpty) {
      int? nuevoStatus = int.tryParse(statusParteLcController.text);
      if (nuevoStatus != null && nuevoStatus != widget.parte.statusParteLc) {
        cambios["statusParteLc"] = nuevoStatus;
      }
    }
    if (horasMaquinaController.text.isNotEmpty &&
        horasMaquinaController.text != widget.parte.mM_HorasC) {
      cambios["mM_HorasC"] = horasMaquinaController.text;
    }
    if (horasReparacionController.text.isNotEmpty) {
      double? horasReparacion = double.tryParse(horasReparacionController.text);
      if (horasReparacion != null &&
          horasReparacion != widget.parte.mM_HorasG) {
        cambios["mM_HorasG"] = horasReparacion;
      }
    }
    if (horasPreviasReparacionController.text.isNotEmpty &&
        horasPreviasReparacionController.text != widget.parte.mM_HorasPR) {
      cambios["mM_HorasPR"] = horasPreviasReparacionController.text;
    }
    if (fechaFinGarantiaController.text.isNotEmpty) {
      cambios["mm_fechafinGarantia"] = fechaFinGarantiaController.text;
    }
    if (supervisorAsignadoLcController.text.isNotEmpty &&
        supervisorAsignadoLcController.text !=
            widget.parte.mM_ResponsableParte) {
      cambios["mM_ResponsableParte"] = supervisorAsignadoLcController.text;
    }
    if (observacionesInternasController.text.isNotEmpty &&
        observacionesInternasController.text !=
            widget.parte.observacionesInternas) {
      cambios["observacionesInternas"] = observacionesInternasController.text;
    }
    if (observacionesEstadoController.text.isNotEmpty &&
        observacionesEstadoController.text !=
            widget.parte.mM_OBSERVACIONESPARTE) {
      cambios["mM_OBSERVACIONESPARTE"] = observacionesEstadoController.text;
    }
    if (numeroDomicilio != null &&
        numeroDomicilio != widget.parte.numeroDomicilio) {
      cambios["numeroDomicilio"] = numeroDomicilio;
    }
    if (domicilio != null && domicilio != widget.parte.domicilio) {
      cambios["domicilio"] = domicilio;
    }

    // Si no hay cambios, no se hace la petición
    if (cambios.isEmpty) {
      print("⚠️ No hay cambios para actualizar.");
      setState(() => _isLoading = false);
      return;
    }

    print("🔹 Datos a actualizar: $cambios");

    bool actualizado = await Provider.of<Parte_Provider>(context, listen: false)
        .actualizarParte(
            widget.parte.idParte, cambios); // 🟢 Ahora enviamos ID y cambios

    setState(() => _isLoading = false);

    if (actualizado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Parte actualizado correctamente")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar el parte")),
      );
    }
  }

  void _seleccionarDomicilio() async {
    final selectedDomicilio = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DomicilioScreen(
          codigoCliente: widget.parte.codigoCliente!,
          codigoEmpresa: widget.parte.codigoEmpresa!,
        ),
      ),
    );

    if (selectedDomicilio != null && selectedDomicilio is Domicilio) {
      setState(() {
        numeroDomicilio =
            selectedDomicilio.numeroDomicilio; // Actualizar variable
        domicilio = selectedDomicilio.domicilio; // Actualizar variable
        numeroDomicilioController.text = numeroDomicilio.toString();
        domicilioController.text = domicilio ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle del Parte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader("Datos Generales"),
              _buildTextField(
                  label: "Código Cliente",
                  controller:
                      TextEditingController(text: widget.parte.codigoCliente),
                  enabled: false),
              _buildTextField(
                  label: "Código Artículo",
                  controller: codigoArticuloController),
              _buildDomicilioRow(),
              _buildDatePicker(context,
                  label: "Fecha", controller: fechaController),
              _buildSectionHeader("Responsable y Tecnicos"),
              _buildTextField(
                  label: "Supervisor",
                  controller: responsableParteLcController),
              _buildTextField(
                  label: "Tecnico", controller: tecnicoPartLcController),
              const SizedBox(height: 20),

// 🔹 Sección de Horas en dos filas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Horas"),

                  // 🔹 Primera fila: Horas de Máquina y Horas de Reparación
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: "Horas de Máquina",
                          controller: horasMaquinaController,
                        ),
                      ),
                      const SizedBox(width: 10), // Espacio entre campos
                      Expanded(
                        child: _buildTextField(
                          label: "Horas de Reparación",
                          controller: horasReparacionController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10), // Espacio entre filas

                  // 🔹 Segunda fila: Horas Previas de Reparación (Ocupa toda la fila)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: "Horas Previstas de Reparación",
                          controller: horasPreviasReparacionController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _buildSectionHeader("Observaciones"),
              _buildTextFieldMemo(
                  label: "Observaciones", controller: observacionesController),
              _buildTextFieldMemo(
                  label: "Observaciones Estado",
                  controller: observacionesEstadoController),
              _buildTextFieldMemo(
                  label: "Observaciones Internas",
                  controller: observacionesInternasController),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _guardarCambios,
                icon:
                    _isLoading ? CircularProgressIndicator() : Icon(Icons.save),
                label: Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true, // No permite edición manual
        onTap: () async {
          DateTime? fechaSeleccionada = await showDatePicker(
            context: context, // Aquí usamos el contexto correcto
            locale: const Locale('es', 'ES'), // Español
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  primaryColor: Colors.blueAccent,
                  colorScheme: ColorScheme.light(primary: Colors.blueAccent),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                child: child!,
              );
            },
          );

          if (fechaSeleccionada != null) {
            controller.text =
                DateFormat('dd/MM/yyyy').format(fechaSeleccionada);
          }
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTextFieldMemo(
      {required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: null, // Permite múltiples líneas
        keyboardType: TextInputType
            .multiline, // Habilita entrada de texto en múltiples líneas
        decoration: InputDecoration(
          labelText: label,
          border:
              OutlineInputBorder(), // Agrega bordes alrededor del campo de texto
          contentPadding: EdgeInsets.symmetric(
              vertical: 10, horizontal: 12), // Espaciado adecuado
          alignLabelWithHint:
              true, // Asegura que la etiqueta se alinee correctamente
        ),
      ),
    );
  }

  Widget _buildDomicilioRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _seleccionarDomicilio,
            child: AbsorbPointer(
              child: _buildTextField(
                label: "Número Domicilio",
                controller: numeroDomicilioController,
                enabled: true, // Se mantiene habilitado solo para tap
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            label: "Domicilio",
            controller: domicilioController,
            enabled: false, // Deshabilitado, solo se actualiza con la selección
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent),
      ),
    );
  }
}

Widget _buildTextField(
    {required String label,
    required TextEditingController controller,
    bool enabled = true,
    void Function()? onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? "Este campo es obligatorio" : null,
    ),
  );
}

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
    ),
  );
}
