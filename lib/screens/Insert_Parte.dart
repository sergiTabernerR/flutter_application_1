import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/input_decoration.dart';
import 'package:flutter_application_1/Providers/parte_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ParteScreen extends StatefulWidget {
  ParteScreen({super.key});

  @override
  _ParteScreenState createState() => _ParteScreenState();
}

class _ParteScreenState extends State<ParteScreen> {
  // Controladores de texto
  final _codigoEmpresaController = TextEditingController();
  final _codigoTipoParteLcController = TextEditingController();
  final _ejercicioParteLCController = TextEditingController();
  final _serieParteLcController = TextEditingController();
  final _numeroParteLCController = TextEditingController();
  final _codigoClienteController = TextEditingController();
  final _codigoArticuloController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _statusParteLcController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario
  DateTime _selectedDate =
      DateTime.now(); // Variable para la fecha seleccionada

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              cajaVerde(size),
              formSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget formSection(BuildContext context) {
    final parteProvider = Provider.of<Parte_Provider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey, // Asociar el Form con la clave global
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Crear Parte",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    ..._buildFormFields(),
                    const SizedBox(height: 20),
                    // Calendario para seleccionar la fecha de imputación
                    TableCalendar(
                      focusedDay: _selectedDate,
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2025),
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDate),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledColor: Colors.grey,
                      color: const Color.fromARGB(90, 70, 178, 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 15),
                        child: const Text(
                          "Guardar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final parteProvider = Provider.of<Parte_Provider>(
                              context,
                              listen: false);
                          /* final success = await parteProvider.createPartes(
                            codigoEmpresa:
                                int.tryParse(_codigoEmpresaController.text) ?? 0,
                            codigoTipoParteLC:
                                _codigoTipoParteLcController.text,
                            ejercicioParteLC: int.tryParse(
                                    _ejercicioParteLCController.text) ??
                                0,
                            serieParteLc: _serieParteLcController.text,
                            numeroParteLC:
                                int.tryParse(_numeroParteLCController.text) ?? 0,
                            codigoCliente: _codigoClienteController.text,
                            codigoArticulo: _codigoArticuloController.text,
                            observaciones: _observacionesController.text,
                            statusParteLc: _statusParteLcController.text,
                            fechaImputacion: _selectedDate, // Usamos la fecha seleccionada
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Parte creado con éxito')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al crear el parte')),
                            );
                          }**/
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // Agregar los campos del formulario aquí
      _buildTextField(
        controller: _codigoEmpresaController,
        label: 'Código Empresa',
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        controller: _codigoTipoParteLcController,
        label: 'Código Tipo Parte LC',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        controller: _ejercicioParteLCController,
        label: 'Ejercicio Parte LC',
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        controller: _serieParteLcController,
        label: 'Serie Parte LC',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        controller: _numeroParteLCController,
        label: 'Número Parte LC',
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        controller: _codigoClienteController,
        label: 'Código Cliente',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        controller: _codigoArticuloController,
        label: 'Código Artículo',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
      _buildTextField(
        controller: _observacionesController,
        label: 'Observaciones',
      ),
      _buildTextField(
        controller: _statusParteLcController,
        label: 'Status Parte LC',
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Container cajaVerde(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(63, 63, 156, 1),
            Color.fromARGB(90, 70, 178, 1),
          ],
        ),
      ),
      width: double.infinity,
      height: size.height * 0.10,
      child: Stack(
        children: [
          Positioned(top: 90, left: 30, child: burbuja()),
          Positioned(top: -40, left: -30, child: burbuja()),
          Positioned(top: -50, right: -20, child: burbuja()),
          Positioned(bottom: -50, left: 20, child: burbuja()),
          Positioned(bottom: 120, right: 20, child: burbuja()),
        ],
      ),
    );
  }

  Container burbuja() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: const Color.fromRGBO(0, 0, 0, 0.047),
      ),
    );
  }
}
