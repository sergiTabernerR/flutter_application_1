import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_application_1/Providers/Actividad_Provider.dart';
import 'package:flutter_application_1/Providers/Articulos_Provider.dart';
import 'package:flutter_application_1/Providers/CalculoDiferidoAlbaranProvider.dart';
import 'package:flutter_application_1/Providers/LineasAlbaranProvider.dart';
import 'package:flutter_application_1/Providers/VinculacionAlbaran_Provider.dart';
import 'package:flutter_application_1/Providers/lineasParte_provider.dart';
import 'package:flutter_application_1/Providers/parte_provider.dart';
import 'package:flutter_application_1/Providers/usuario_provider.dart';
import 'package:flutter_application_1/models/ActividadPartes.dart';
import 'package:flutter_application_1/models/parte.dart';
import 'package:flutter_application_1/models/partePost.dart';
import 'package:flutter_application_1/screens/AlbaranesScreen.dart';
import 'package:flutter_application_1/screens/ParteDetalleScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

int CodigoEmpresa = 0;
bool connection = true;
String _pantallaActual = "Activos";
String? _selectedMunicipio;
List<String> _municipiosDisponibles = [];
Future<List<LineasParte>>? _lineasPartesFuture;

ActividadParte actividadSeleccionada = new ActividadParte(
    codigoEmpresa: 0,
    codigoActividadParteLc: "",
    actividadParteLc: "",
    imputableLc: 0,
    codigoArticulo: "",
    codigoGrupoActividadParteLc: "",
    esVisibleEnMovil: 0);

String codigoDescripcionActividad = "";

class PantallaParte extends StatefulWidget {
  const PantallaParte({super.key});

  @override
  _PantallaParteState createState() => _PantallaParteState();
}

class _PantallaParteState extends State<PantallaParte> {
  void _abrirCerrarParte(parte_ parte) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CerrarParteScreen(parte: parte),
      ),
    );

    if (result == true) {
      _recargarPartes(); // 🔥 Llamamos a la función que refresca la lista de partes
    }
  }

  void _recargarPartes() async {
    final usuario = Provider.of<Usuario_provider>(context, listen: false);
    final partesProvider = Provider.of<Parte_Provider>(context, listen: false);

    print("📌 Recargando partes. Pantalla actual: $_pantallaActual");

    bool connexion = await _checkInternetAccess();

    if (_pantallaActual.isEmpty) {
      _pantallaActual = "Activos"; // Asegurar que siempre tenga un valor
    }

    if (connexion) {
      // 🔹 Si hay conexión, descargar los datos actualizados
      if (_pantallaActual == "Activos") {
        if (usuario.usuarioAdministrador == "ADM") {
          print("1");
          await partesProvider.getPartesActivosAdministrador();
        } else if (usuario.codigoClienteConectado ==
            usuario.codigoResponsableEquipo) {
          print("2");

          await partesProvider.getPartesPorVariosResponsablesActivos(
              partesProvider.responsablesPartes);
        } else {
          print("3");

          await partesProvider.getPartesActivos();
        }
      } else if (_pantallaActual == "Pendientes") {
        print("4");

        if (usuario.usuarioAdministrador == "ADM") {
          await partesProvider.getPartesPendientesAdministrador();
        } else if (usuario.codigoClienteConectado ==
            usuario.codigoResponsableEquipo) {
          await partesProvider.getPartesPorVariosResponsablesPendientes(
              partesProvider.responsablesPartes);
        } else {
          print("5");

          await partesProvider.getPartesPendientes();
        }
      } else {
        print("6");

        if (usuario.usuarioAdministrador == "ADM") {
          await partesProvider.getPartesTodosAdministrador();
        } else if (usuario.codigoClienteConectado ==
            usuario.codigoResponsableEquipo) {
          await partesProvider.getPartesPorVariosResponsablesTodos(
              partesProvider.responsablesPartes);
        } else {
          await partesProvider.getPartesTodos();
        }
      }
      // Obtener municipios únicos de los partes filtrados
      Set<String> municipiosSet = partesProvider.filteredPartes
          .map((parte) => parte.municipio ?? "")
          .where(
              (m) => m.isNotEmpty) // Filtrar vacíos antes de convertir en lista
          .toSet();

      List<String> municipiosOrdenados = municipiosSet.toList();
      municipiosOrdenados.sort(); // Ordenar alfabéticamente

      _municipiosDisponibles = ["Todos"] + municipiosOrdenados;

      print("📌 Municipios disponibles: $_municipiosDisponibles");

      // 🔥 Guardar los datos localmente según el tipo de parte
      await _guardarDatosLocalmente(
          _pantallaActual, partesProvider.filteredPartes);
    } else {
      // 🔹 Si no hay conexión, cargar los datos guardados localmente
      partesProvider.filteredPartes =
          await _cargarDatosLocales(_pantallaActual);
    }

    setState(() {}); // 🔥 Refresca la UI con los datos actualizados
  }

  DateTime _focusedDay = DateTime.now(); // Inicializar con la fecha actual

  final _codigoArticuloController = TextEditingController();
  final _descripcionArticuloController = TextEditingController();
  List<int> _expandedCards = []; // Lista para controlar las tarjetas expandidas
  final TextEditingController unidadesController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();
  DateTime _selectedDay = DateTime.now();
  bool _isCalendarView =
      false; // Cambiado a "false" para mostrar la tabla primero
  String _currentTitle = 'Partes Activos'; // Título inicial

  // Estado de la conexión
  String connectionStatus = "Comprobando conexión...";
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    _recargarPartes();
    super.initState();
    _pantallaActual = "Activos"; // Asegurar que siempre tenga un valor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recargarPartes(); // 🔥 Llamar sin verificar la conexión primero
    });
    // Escuchar cambios en la conectividad
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await _updateConnectionStatus(result);
    });

    // Verificar conexión al iniciar la pantalla
    _checkInitialConnection();
  }

  // Método para verificar el estado inicial de la conexión
  Future<void> _checkInitialConnection() async {
    final initialResult = await Connectivity().checkConnectivity();
    await _updateConnectionStatus(initialResult);
  }

  Future<void> _guardarDatosLocalmente(String tipo, List<parte_> partes) async {
    final prefs = await SharedPreferences.getInstance();
    String partesJson = jsonEncode(partes.map((p) => p.toJson()).toList());

    // 🔹 Guardar partes según el tipo
    if (tipo == "Activos") {
      await prefs.setString('partesActivos', partesJson);
    } else if (tipo == "Pendientes") {
      await prefs.setString('partesPendientes', partesJson);
    } else if (tipo == "Todos") {
      await prefs.setString('partesTodos', partesJson);
    }

    print("✅ Datos de partes guardados localmente para: $tipo");

    // 🔥 Guardar también las líneas de cada parte
    /*
    for (parte_ parte in partes) {
      await _guardarLineasParteLocalmente(
        parte.codigoEmpresa!,
        parte.codigoTipoParteLC!,
        parte.ejercicioParteLC,
        parte.serieParteLc!,
        parte.numeroParteLC,
      );
    }*/
  }

  /// 🔹 Método para guardar localmente las líneas de un parte
  Future<void> _guardarLineasParteLocalmente(
      int codigoEmpresa,
      String codigoTipoParte,
      int ejercicioParte,
      String serieParte,
      int numeroParte) async {
    final prefs = await SharedPreferences.getInstance();
    final lineasParteProvider =
        LineasParte_provider(); // Instancia del provider

    // Configurar datos del provider antes de llamar al método
    lineasParteProvider.codigoEmpresa = codigoEmpresa;
    lineasParteProvider.codigoTipoParte = codigoTipoParte;
    lineasParteProvider.ejercicioPedido = ejercicioParte;
    lineasParteProvider.seriePedido = serieParte;
    lineasParteProvider.numeroPedido = numeroParte;

    try {
      // Llamar al método que obtiene las líneas de partes desde la API
      await lineasParteProvider.getLineasPartes();

      // Si hay líneas, guardarlas localmente
      if (lineasParteProvider.filtroLineaParte.isNotEmpty) {
        String clave =
            "lineas_${codigoEmpresa}_${codigoTipoParte}_${ejercicioParte}_${serieParte}_${numeroParte}";
        String lineasJson = jsonEncode(lineasParteProvider.filtroLineaParte
            .map((l) => l.toJson())
            .toList());
        await prefs.setString(clave, lineasJson);

        print("✅ Líneas guardadas localmente para parte: $clave");
      } else {
        print(
            "⚠ No hay líneas para el parte: $codigoEmpresa-$codigoTipoParte-$ejercicioParte-$serieParte-$numeroParte");
      }
    } catch (e) {
      print("❌ Error al guardar líneas localmente para parte: $e");
    }
  }

  Future<List<parte_>> _cargarDatosLocales(String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    String? partesJson;

    // 🔹 Cargar según el tipo de parte
    if (tipo == "Activos") {
      partesJson = prefs.getString('partesActivos');
    } else if (tipo == "Pendientes") {
      partesJson = prefs.getString('partesPendientes');
    } else if (tipo == "Todos") {
      partesJson = prefs.getString('partesTodos');
    }

    if (partesJson != null) {
      List<dynamic> partesList = jsonDecode(partesJson);
      List<parte_> partesCargadas =
          partesList.map((json) => parte_.fromJson(json)).toList();
      print("✅ Datos cargados desde almacenamiento local para: $tipo");
      return partesCargadas;
    }

    print("⚠ No hay datos guardados localmente para: $tipo");
    return [];
  }

  /// 🔹 Método para obtener líneas desde almacenamiento local si no hay conexión
  Future<List<LineasParte>> _cargarLineasPartesLocalmente({
    required int codigoEmpresa,
    required String codigoTipoParte,
    required int ejercicioParte,
    required String serieParte,
    required int numeroParte,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String clave =
        "lineas_${codigoEmpresa}_${codigoTipoParte}_${ejercicioParte}_${serieParte}_${numeroParte}";

    String? lineasJson = prefs.getString(clave);

    if (lineasJson != null) {
      List<dynamic> lineasList = jsonDecode(lineasJson);
      List<LineasParte> lineasCargadas =
          lineasList.map((json) => LineasParte.fromJson(json)).toList();

      print("✅ Líneas cargadas localmente para parte: $clave");
      return lineasCargadas;
    }

    print("⚠ No hay líneas guardadas localmente para parte: $clave");
    return [];
  }

  // Método para actualizar el estado de la conexión
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    String status;
    final provider = Provider.of<Parte_Provider>(context, listen: false);
    final parteProvider =
        Provider.of<LineasParte_provider>(context, listen: false);

    if (result == ConnectivityResult.none) {
      status = "Sin conexión a Internet";
      connection = false;
    } else {
      connection = true;
      final pendingLines = await parteProvider.getPendingLines();

      if (pendingLines.length > 0) {
        for (final line in pendingLines) {
          final success = await parteProvider.createPartes(
            line['codigoEmpresa'],
            line['codigoTipoParteLc'],
            line['ejercicioParteLc'],
            line['serieParteLc'],
            line['numeroParteLc'],
            line['codigoTipoFaseLc'],
            line['codigoActividadParteLc'],
            line['tecnicoAsignadoLc'],
            line['codigoGastoComercialLc'],
            line['facturableLc'],
            line['codigoArticulo'],
            line['unidades'],
            line['horaEntradaLc'],
            line['liquidableLc'],
            line['observaciones'],
          );
          parteProvider.removeLineLocally(line);
        }
      }

      var pendingLinesCerrado = await provider.getPendingPartesCerrados();

      if (pendingLinesCerrado.length > 0) {
        for (final line in pendingLinesCerrado) {
          await provider.actualizarStatusParte(
              codigoEmpresa: line['codigoEmpresa'],
              codigoTipoParteLC: line['codigoTipoParteLC'],
              ejercicioParteLC: line['ejercicioParteLC'],
              serieParteLc: line['serieParteLc'],
              numeroParteLC: line['numeroParteLC'],
              nuevoStatusParteLc: 3);
          provider.removeParteCerradoLocally(line);
        }
      }

      // Verificar acceso a Internet real
      bool hasInternet = await _checkInternetAccess();
      status =
          hasInternet ? "Conexión a Internet activa" : "Sin acceso a Internet";
    }

    setState(() {
      connectionStatus = status;
    });
  }

  // Método para verificar acceso a Internet real
  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  @override
  void dispose() {
    // Cancelar la suscripción al stream de conectividad
    connectivitySubscription.cancel();
    unidadesController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final usuario = Provider.of<Usuario_provider>(context);

    final partesProvider = Provider.of<Parte_Provider>(context);

    partesProvider.responsableParteLc = usuario.codigoClienteConectado ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(
                _isCalendarView ? Icons.table_chart : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isCalendarView =
                    !_isCalendarView; // Alterna entre tabla y calendario
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Icono para mostrar los partes Activos
              IconButton(
                icon: Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Mostrar Partes Activos',
                onPressed: () async {
                  _pantallaActual = "Activos";
                  setState(() {
                    _currentTitle = 'Partes Activos'; // Título inicial
                  });

                  bool connexion = await _checkInternetAccess();

                  if (connexion) {
                    if (usuario.usuarioAdministrador == "ADM") {
                      await partesProvider.getPartesActivosAdministrador();
                    } else if (usuario.codigoClienteConectado ==
                        usuario.codigoResponsableEquipo) {
                      await partesProvider
                          .getPartesPorVariosResponsablesActivos(
                              partesProvider.responsablesPartes);
                    } else {
                      await partesProvider.getPartesActivos();
                    }

                    // 🔥 Guardar los datos localmente
                    await _guardarDatosLocalmente(
                        _pantallaActual, partesProvider.filteredPartes);
                  } else {
                    // 🔹 Cargar los datos desde almacenamiento local si no hay internet

                    partesProvider.filteredPartes =
                        await _cargarDatosLocales(_pantallaActual);
                  }

                  setState(() {}); // Refrescar la interfaz
                },
              ),

              // Icono para mostrar los partes Pendientes
              IconButton(
                icon: Icon(Icons.hourglass_empty, color: Colors.orange),
                tooltip: 'Mostrar Partes Pendientes',
                onPressed: () async {
                  _pantallaActual = "Pendientes";
                  setState(() {
                    _currentTitle = 'Partes Pendientes'; // Título inicial
                  });

                  print("🟠 Botón Partes Pendientes PRESIONADO");

                  bool connexion = await _checkInternetAccess();
                  print("🌐 Conexión a internet: $connexion");

                  if (connexion) {
                    // 🔹 Si hay conexión, obtener los datos actualizados
                    if (usuario.usuarioAdministrador == "ADM") {
                      await partesProvider.getPartesPendientesAdministrador();
                    } else if (usuario.codigoClienteConectado ==
                        usuario.codigoResponsableEquipo) {
                      await partesProvider
                          .getPartesPorVariosResponsablesPendientes(
                              partesProvider.responsablesPartes);
                    } else {
                      await partesProvider.getPartesPendientes();
                    }

                    // 🔥 Guardar los datos obtenidos localmente
                    await _guardarDatosLocalmente(
                        "Pendientes", partesProvider.partesPendientes);
                  } else {
                    // 🔹 Cargar los datos desde almacenamiento local si no hay internet
                    List<parte_> datosLocales =
                        await _cargarDatosLocales("Pendientes");

                    // ❗ Evitar datos obsoletos: Si la lista no tiene partes pendientes, limpiamos los datos locales
                    if (datosLocales.isEmpty) {
                      partesProvider.partesPendientes = [];
                    } else {
                      partesProvider.partesPendientes = datosLocales;
                    }
                  }

                  print(
                      "📋 Total partes obtenidos: ${partesProvider.partesPendientes.length}");

                  if (partesProvider.partesPendientes.isEmpty) {
                    setState(() {
                      _currentTitle = 'No hay partes pendientes';
                      print("❌ No hay partes pendientes.");
                    });
                  } else {
                    setState(() {
                      print("✅ Se han cargado partes pendientes.");
                    });
                  }
                },
              ),

              // Icono para mostrar Todos los partes
              IconButton(
                icon: Icon(Icons.all_inbox, color: Colors.black),
                tooltip: 'Mostrar Todos los Partes',
                onPressed: () async {
                  _pantallaActual = "Todos";
                  setState(() {
                    _currentTitle = "Todos los Partes";
                  });

                  bool connexion = await _checkInternetAccess();

                  if (connexion) {
                    if (usuario.usuarioAdministrador == "ADM") {
                      print("Entra aqui 1");
                      await partesProvider.getPartesTodosAdministrador();
                    } else if (usuario.codigoClienteConectado ==
                        usuario.codigoResponsableEquipo) {
                      print("Entra aqui 2");
                      await partesProvider.getPartesPorVariosResponsablesTodos(
                          partesProvider.responsablesPartes);
                    } else {
                      print("Entra aqui 3");
                      await partesProvider.getPartesTodos();
                    }
                    await _guardarDatosLocalmente(
                        _pantallaActual, partesProvider.todosPartes);
                  } else {
                    // 🔹 Cargar los datos desde almacenamiento local si no hay internet
                    partesProvider.todosPartes =
                        await _cargarDatosLocales(_pantallaActual);
                  }

                  setState(() {}); // Refrescar la interfaz
                },
              ),
            ],
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Estado de Conexión: $connectionStatus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: connectionStatus == "Sin conexión a Internet" ||
                        connectionStatus == "Sin acceso a Internet"
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              hint: Text("Filtrar por Municipio"),
              value: _selectedMunicipio,
              isExpanded: true,
              items: _municipiosDisponibles.map((String municipio) {
                return DropdownMenuItem<String>(
                  value: municipio,
                  child: Text(municipio),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMunicipio = newValue;
                });
              },
            ),
          ),

          // 🔥 Mostrar el mensaje si no hay partes pendientes
          Expanded(
            child: partesProvider.filteredPartes == null
                ? const Center(
                    child:
                        CircularProgressIndicator()) // 🔥 Indicador solo mientras carga
                : partesProvider.filteredPartes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange, size: 50),
                            SizedBox(height: 10),
                            Text(
                              "No hay partes pendientes asignados al responsable",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              usuario.codigoClienteConectado
                                  .toString(), // Muestra el nombre del responsable
                              style: TextStyle(
                                  fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      )
                    : (_isCalendarView
                        ? _showCalendar(partesProvider)
                        : _showListView(partesProvider)),
          ),
        ],
      ),
    );
  }

  Widget _showCalendar(Parte_Provider partesProvider) {
    // Crear un mapa para asociar las fechas con los eventos
    final Map<DateTime, List<parte_>> eventos = {};

    for (var parte in partesProvider.partes) {
      final fecha =
          DateTime(parte.fecha.year, parte.fecha.month, parte.fecha.day);
      if (eventos.containsKey(fecha)) {
        eventos[fecha]!.add(parte);
      } else {
        eventos[fecha] = [parte];
      }
    }

    // Obtener las partes para el día seleccionado
    final partesDelDia = eventos[DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        )] ??
        [];

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay:
              DateTime(DateTime.now().year + 1, 12, 31), // Permitir un año más
          focusedDay: _focusedDay.isBefore(DateTime(2020)) ||
                  _focusedDay.isAfter(DateTime(DateTime.now().year + 1))
              ? DateTime.now() // Evita que esté fuera de rango
              : _focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay =
                  focusedDay; // Sincronizar focusedDay con selectedDay
            });
          },
          eventLoader: (day) {
            final fecha = DateTime(day.year, day.month, day.day);
            return eventos[fecha] ?? [];
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
            markerDecoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ), // Mostrar la lista de partes seleccionados en el día
        Expanded(
          child: partesDelDia.isEmpty
              ? const Center(
                  child: Text("No hay partes para este día"),
                )
              : ListView.builder(
                  itemCount: partesDelDia.length,
                  itemBuilder: (context, index) {
                    final parte = partesDelDia[index];
                    final isExpanded = _expandedCards.contains(index);

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Parte ${parte.codigoTipoParteLC}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Fecha: ${DateFormat('yyyy-MM-dd').format(parte.fecha)}',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Número de Parte y Serie en una sola línea
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Número Parte: ${parte.numeroParteLC}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Serie: ${parte.serieParteLc}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Teléfono
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 14, color: Colors.teal),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${parte.telefono}',
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Razón social, domicilio y municipio en columnas
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Razón: ${parte.razonSocial}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'Domicilio: ${parte.domicilio}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'Municipio: ${parte.municipio}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Horas máquina, reparación, previas reparación y fecha fin garantía
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'H. Máquina: ${parte.mM_HorasC ?? "-"}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                            Text(
                                              'H. Reparación: ${parte.mM_HorasG ?? "-"}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'H. Previstas: ${parte.mM_HorasPR ?? "-"}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                            Text(
                                              'Fin Garantía: ${(parte.mm_fechafinGarantia != null && parte.mm_fechafinGarantia!.isNotEmpty) ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(parte.mm_fechafinGarantia!) ?? DateTime(0)) : "-"}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Observaciones
                                if (parte.observaciones != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.note,
                                            size: 14, color: Colors.teal),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Obs: ${parte.observaciones}',
                                            style:
                                                const TextStyle(fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'Crear Línea') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ImputarLineasScreen(parte: parte),
                                      ),
                                    );
                                  } else if (value == 'Detalle Parte') {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ParteDetalleScreen(parte: parte),
                                      ),
                                    );

                                    if (result == true) {
                                      print("hiher8iowheoireho");
                                      _recargarPartes(); // 🔥 Recargar la lista de partes
                                    }
                                  } else if (value == 'Cerrar Parte') {
                                    _abrirCerrarParte(parte);
                                  } else if (value == 'Albaran') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AlbaranesScreen(
                                          codigoEmpresa: parte.codigoEmpresa!,
                                          codigoTipoParteLC:
                                              parte.codigoTipoParteLC!,
                                          ejercicioParteLC:
                                              parte.ejercicioParteLC,
                                          serieParteLc: parte.serieParteLc!,
                                          numeroParteLC: parte.numeroParteLC,
                                        ),
                                      ),
                                    ).then((_) {
                                      // Recargar los datos cuando regresamos de AlbaranesScreen
                                      Provider.of<VinculacionAlbaran_Provider>(
                                              context,
                                              listen: false)
                                          .getArticulos(
                                        codigoEmpresa: parte.codigoEmpresa!,
                                        codigoTipoParte:
                                            parte.codigoTipoParteLC!,
                                        ejercicioParte: parte.ejercicioParteLC,
                                        serieParte: parte.serieParteLc!,
                                        numeroParte: parte.numeroParteLC,
                                      );
                                    });
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'Detalle Parte',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Detalle Parte'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'Crear Línea',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Crear Línea'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'Albaran',
                                    child: Row(
                                      children: [
                                        Icon(Icons.receipt,
                                            color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Albaran'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'Cerrar Parte',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Cerrar Parte'),
                                      ],
                                    ),
                                  ),
                                ],
                                icon: Icon(Icons
                                    .more_vert), // Icono para abrir el menú
                              ),
                              IconButton(
                                icon: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () async {
                                  final lineasParteProvider =
                                      Provider.of<LineasParte_provider>(context,
                                          listen: false);

                                  lineasParteProvider.codigoTipoParte =
                                      parte.codigoTipoParteLC;
                                  lineasParteProvider.ejercicioPedido =
                                      parte.ejercicioParteLC;
                                  lineasParteProvider.seriePedido =
                                      parte.serieParteLc;
                                  lineasParteProvider.numeroPedido =
                                      parte.numeroParteLC;
                                  lineasParteProvider.codigoEmpresa =
                                      parte.codigoEmpresa;

                                  print("hey estoy aquí 1");

                                  setState(() {
                                    if (isExpanded) {
                                      print("hey estoy aquí 2 (colapsando)");
                                      _expandedCards.remove(index);
                                    } else {
                                      print("hey estoy aquí 3 (expandiendo)");
                                      _expandedCards.add(index);

                                      // Solo llamar a la API si el Expanded se está abriendo
                                      if (connection) {
                                        print(
                                            "hey estoy aquí 11 (llamada a la API)");
                                        Future.delayed(Duration.zero, () async {
                                          await lineasParteProvider
                                              .getLineasPartes();
                                        });
                                      } else {
                                        print(
                                            "hey estoy aquí 111 (cargando líneas locales)");
                                        Future.delayed(Duration.zero, () async {
                                          lineasParteProvider.filtroLineaParte =
                                              await _cargarLineasPartesLocalmente(
                                            codigoEmpresa: parte.codigoEmpresa!,
                                            codigoTipoParte:
                                                parte.codigoTipoParteLC!,
                                            ejercicioParte:
                                                parte.ejercicioParteLC,
                                            serieParte: parte.serieParteLc!,
                                            numeroParte: parte.numeroParteLC,
                                          );
                                        });
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: FutureBuilder(
                                  future: Provider.of<LineasParte_provider>(
                                          context,
                                          listen: false)
                                      .getLineasPartes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text("Error: ${snapshot.error}"));
                                    }

                                    final lineasParteProvider =
                                        Provider.of<LineasParte_provider>(
                                            context);

                                    if (lineasParteProvider
                                        .filtroLineaParte.isEmpty) {
                                      return const Center(
                                          child: Text(
                                              "No hay líneas disponibles."));
                                    }

                                    return DataTable(
                                      columns: const [
                                        DataColumn(
                                            label: Text('Cód. Actividad')),
                                        DataColumn(label: Text('Artículo')),
                                        DataColumn(
                                            label: Text('Técnico Asignado')),
                                        DataColumn(label: Text('Facturable')),
                                        DataColumn(label: Text('Unidades')),
                                        DataColumn(
                                            label: Text('Observaciones')),
                                      ],
                                      rows: lineasParteProvider.filtroLineaParte
                                          .map((linea) {
                                        return DataRow(cells: [
                                          DataCell(Text(
                                              linea.codigoActividadParteLc ??
                                                  'N/A')),
                                          DataCell(Text(
                                              linea.codigoArticulo ?? 'N/A')),
                                          DataCell(Text(
                                              linea.tecnicoAsignadoLc ??
                                                  'N/A')),
                                          DataCell(
                                            Checkbox(
                                              value: linea.facturableLc == -1,
                                              onChanged: (value) {},
                                            ),
                                          ),
                                          DataCell(Text(linea.unidades
                                                  ?.toStringAsFixed(2) ??
                                              '0.00')),
                                          DataCell(Text(
                                              linea.observaciones ?? 'N/A')),
                                        ]);
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _showListView(Parte_Provider partesProvider) {
    List<parte_> partesFiltradas;

    if (_pantallaActual == "Pendientes") {
      partesFiltradas =
          (_selectedMunicipio == null || _selectedMunicipio == "Todos")
              ? partesProvider.partesPendientes // ✅ USAR partesPendientes
              : partesProvider.partesPendientes
                  .where((parte) => parte.municipio == _selectedMunicipio)
                  .toList();
    } else if (_pantallaActual == "Todos") {
      partesFiltradas =
          (_selectedMunicipio == null || _selectedMunicipio == "Todos")
              ? partesProvider.todosPartes // ✅ USAR todosPartes
              : partesProvider.todosPartes
                  .where((parte) => parte.municipio == _selectedMunicipio)
                  .toList();
    } else {
      partesFiltradas =
          (_selectedMunicipio == null || _selectedMunicipio == "Todos")
              ? partesProvider.filteredPartes
              : partesProvider.filteredPartes
                  .where((parte) => parte.municipio == _selectedMunicipio)
                  .toList();
    }

    return _buildParteList(partesFiltradas);
  }

  Widget _buildParteList(List<parte_> partes) {
    return ListView.builder(
      itemCount: partes.length,
      itemBuilder: (context, index) {
        final parte = partes[index];
        final isExpanded = _expandedCards.contains(index);

        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Parte ${parte.codigoTipoParteLC}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Fecha: ${DateFormat('yyyy-MM-dd').format(parte.fecha)}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Número de Parte y Serie en una sola línea
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Número Parte: ${parte.numeroParteLC}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Serie: ${parte.serieParteLc}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Teléfono
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.teal),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${parte.telefono}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Razón social, domicilio y municipio en columnas
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Razón: ${parte.razonSocial}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Domicilio: ${parte.domicilio}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Municipio: ${parte.municipio}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Horas máquina, reparación, previas reparación y fecha fin garantía
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'H. Máquina: ${parte.mM_HorasC ?? "-"}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  'H. Reparación: ${parte.mM_HorasG ?? "-"}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'H. Previstas: ${parte.mM_HorasPR ?? "-"}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  'Fin Garantía: ${(parte.mm_fechafinGarantia != null && parte.mm_fechafinGarantia!.isNotEmpty) ? DateFormat('dd/MM/yyyy').format(DateTime.tryParse(parte.mm_fechafinGarantia!) ?? DateTime(0)) : "-"}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Observaciones
                    if (parte.observaciones != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.note,
                                size: 14, color: Colors.teal),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Obs: ${parte.observaciones}',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'Crear Línea') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImputarLineasScreen(parte: parte),
                          ),
                        );
                      } else if (value == 'Detalle Parte') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ParteDetalleScreen(parte: parte),
                          ),
                        );

                        if (result == true) {
                          print("llllllllll");

                          _recargarPartes(); // 🔥 Recargar la lista de partes
                        }
                      } else if (value == 'Cerrar Parte') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CerrarParteScreen(parte: parte),
                          ),
                        );
                      } else if (value == 'Albaran') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlbaranesScreen(
                                codigoEmpresa: parte.codigoEmpresa!,
                                codigoTipoParteLC: parte.codigoTipoParteLC!,
                                ejercicioParteLC: parte.ejercicioParteLC,
                                serieParteLc: parte.serieParteLc!,
                                numeroParteLC: parte.numeroParteLC),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'Detalle Parte',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Detalle Parte'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Crear Línea',
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Crear Línea'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Albaran',
                        child: Row(
                          children: [
                            Icon(Icons.receipt, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Albaran'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Cerrar Parte',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Cerrar Parte'),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert), // Icono para abrir el menú
                  ),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () async {
                      final lineasParteProvider =
                          Provider.of<LineasParte_provider>(context,
                              listen: false);

                      lineasParteProvider.codigoTipoParte =
                          parte.codigoTipoParteLC;
                      lineasParteProvider.ejercicioPedido =
                          parte.ejercicioParteLC;
                      lineasParteProvider.seriePedido = parte.serieParteLc;
                      lineasParteProvider.numeroPedido = parte.numeroParteLC;
                      lineasParteProvider.codigoEmpresa = parte.codigoEmpresa;

                      print("hey estoy aquí 1");

                      setState(() {
                        if (isExpanded) {
                          print("hey estoy aquí 2 (colapsando)");
                          _expandedCards.remove(index);
                        } else {
                          print("hey estoy aquí 3 (expandiendo)");
                          _expandedCards.add(index);

                          // Solo llamar a la API si el Expanded se está abriendo
                          if (connection) {
                            print("hey estoy aquí 11 (llamada a la API)");
                            Future.delayed(Duration.zero, () async {
                              await lineasParteProvider.getLineasPartes();
                            });
                          } else {
                            print(
                                "hey estoy aquí 111 (cargando líneas locales)");
                            Future.delayed(Duration.zero, () async {
                              lineasParteProvider.filtroLineaParte =
                                  await _cargarLineasPartesLocalmente(
                                codigoEmpresa: parte.codigoEmpresa!,
                                codigoTipoParte: parte.codigoTipoParteLC!,
                                ejercicioParte: parte.ejercicioParteLC,
                                serieParte: parte.serieParteLc!,
                                numeroParte: parte.numeroParteLC,
                              );
                            });
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: FutureBuilder(
                      future: Provider.of<LineasParte_provider>(context,
                              listen: false)
                          .getLineasPartes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }

                        final lineasParteProvider =
                            Provider.of<LineasParte_provider>(context);

                        if (lineasParteProvider.filtroLineaParte.isEmpty) {
                          return const Center(
                              child: Text("No hay líneas disponibles."));
                        }

                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Cód. Actividad')),
                            DataColumn(label: Text('Artículo')),
                            DataColumn(label: Text('Técnico Asignado')),
                            DataColumn(label: Text('Facturable')),
                            DataColumn(label: Text('Unidades')),
                            DataColumn(label: Text('Observaciones')),
                          ],
                          rows:
                              lineasParteProvider.filtroLineaParte.map((linea) {
                            return DataRow(cells: [
                              DataCell(
                                  Text(linea.codigoActividadParteLc ?? 'N/A')),
                              DataCell(Text(linea.codigoArticulo ?? 'N/A')),
                              DataCell(Text(linea.tecnicoAsignadoLc ?? 'N/A')),
                              DataCell(
                                Checkbox(
                                  value: linea.facturableLc == -1,
                                  onChanged: (value) {},
                                ),
                              ),
                              DataCell(Text(
                                  linea.unidades?.toStringAsFixed(2) ??
                                      '0.00')),
                              DataCell(Text(linea.observaciones ?? 'N/A')),
                            ]);
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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

class ImputarLineasScreen extends StatefulWidget {
  final parte_ parte;

  const ImputarLineasScreen({required this.parte, Key? key}) : super(key: key);

  @override
  _ImputarLineasScreenState createState() => _ImputarLineasScreenState();
}

class _ImputarLineasScreenState extends State<ImputarLineasScreen> {
  final TextEditingController unidadesController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  // Lista para almacenar las líneas pendientes
  List<Map<String, dynamic>> pendingLines = [];

  // Estado de la conexión
  String connectionStatus = "Comprobando conexión...";
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en la conectividad
    _clearFields(context);

    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await _updateConnectionStatus(result);
    });

    // Verificar conexión al iniciar la pantalla
    _checkInitialConnection();
  }

  // Método para verificar el estado inicial de la conexión
  Future<void> _checkInitialConnection() async {
    final initialResult = await Connectivity().checkConnectivity();
    await _updateConnectionStatus(initialResult);
  }

  // Método para actualizar el estado de la conexión
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final provider = Provider.of<Parte_Provider>(context, listen: false);
    final parteProvider =
        Provider.of<LineasParte_provider>(context, listen: false);

    String status;
    if (result == ConnectivityResult.none) {
      status = "Sin conexión a Internet";
    } else {
      final pendingLines = await parteProvider.getPendingLines();

      if (pendingLines.length > 0) {
        for (final line in pendingLines) {
          final success = await parteProvider.createPartes(
            line['codigoEmpresa'],
            line['codigoTipoParteLc'],
            line['ejercicioParteLc'],
            line['serieParteLc'],
            line['numeroParteLc'],
            line['codigoTipoFaseLc'],
            line['codigoActividadParteLc'],
            line['tecnicoAsignadoLc'],
            line['codigoGastoComercialLc'],
            line['facturableLc'],
            line['codigoArticulo'],
            line['unidades'],
            line['horaEntradaLc'],
            line['liquidableLc'],
            line['observaciones'],
          );
          parteProvider.removeLineLocally(line);
        }
      }

      var pendingLinesCerrado = await provider.getPendingPartesCerrados();

      if (pendingLinesCerrado.length > 0) {
        for (final line in pendingLinesCerrado) {
          await provider.actualizarStatusParte(
              codigoEmpresa: line['codigoEmpresa'],
              codigoTipoParteLC: line['codigoTipoParteLC'],
              ejercicioParteLC: line['ejercicioParteLC'],
              serieParteLc: line['serieParteLc'],
              numeroParteLC: line['numeroParteLC'],
              nuevoStatusParteLc: 3);
          provider.removeParteCerradoLocally(line);
        }
      }

      // Verificar acceso a Internet real
      bool hasInternet = await _checkInternetAccess();
      status =
          hasInternet ? "Conexión a Internet activa" : "Sin acceso a Internet";
    }

    setState(() {
      connectionStatus = status;
    });
  }

  // Método para verificar acceso a Internet real
  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  @override
  void dispose() {
    // Cancelar la suscripción al stream de conectividad
    connectivitySubscription.cancel();
    unidadesController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividadProvider =
        Provider.of<ActividadProvider>(context, listen: false);

    final articulosprovider =
        Provider.of<VinculacionAlbaran_Provider>(context, listen: false);

    final usuarioprovider =
        Provider.of<Usuario_provider>(context, listen: false);

    // Configuración inicial de los datos

    articulosprovider.codigoEmpresa = widget.parte.codigoEmpresa ?? 0;

    actividadProvider.codigoEmpresa = widget.parte.codigoEmpresa ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Imputar Líneas'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado de Conexión: $connectionStatus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: connectionStatus == "Sin conexión a Internet" ||
                          connectionStatus == "Sin acceso a Internet"
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              const Divider(height: 20, thickness: 1, color: Colors.grey),
              const Text(
                'Datos del Parte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 5),
              _buildReadOnlyField(
                  'Código Empresa', widget.parte.codigoEmpresa.toString()),
              _buildReadOnlyField(
                  'Tipo Parte', widget.parte.codigoTipoParteLC.toString()),
              _buildReadOnlyField(
                  'Ejercicio Parte', widget.parte.ejercicioParteLC.toString()),
              _buildReadOnlyField(
                  'Serie Parte', widget.parte.serieParteLc.toString()),
              _buildReadOnlyField(
                  'Número Parte', widget.parte.numeroParteLC.toString()),
              const Divider(height: 20, thickness: 1, color: Colors.grey),
              const Text(
                'Datos para Imputar Líneas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 5),
              DropdownActividadWidget(),
              DropdownArticulosWidget(
                  codigoEmpresa: widget.parte.codigoEmpresa!,
                  codigoTipoParte: widget.parte.codigoTipoParteLC!,
                  ejercicioParte: widget.parte.ejercicioParteLC,
                  serieParte: widget.parte.serieParteLc ?? "",
                  numeroParte: widget.parte.numeroParteLC),
              const SizedBox(height: 5),
              _buildTextField(unidadesController, 'Unidades',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 5),
              const Text(
                'Observaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: observacionesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Escribe tus observaciones aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  setState(() {
                    pendingLines.add({
                      'actividad':
                          Provider.of<ActividadProvider>(context, listen: false)
                                  .selectedActividad ??
                              "",
                      'articulo': actividadSeleccionada.codigoArticulo ?? "",
                      'unidades': double.tryParse(unidadesController.text) ?? 0,
                      'observaciones': observacionesController.text,
                    });
                    _clearFields(context); // Limpia los campos y los ComboBox
                  });
                },
                child: const Text('Añadir Línea'),
              ),
              const SizedBox(height: 10),
              if (pendingLines.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingLines.length,
                  itemBuilder: (context, index) {
                    final line = pendingLines[index];
                    return ListTile(
                      title: Text('Artículo: ${line['articulo']}'),
                      subtitle: Text(
                          'Unidades: ${line['unidades']} - Observaciones: ${line['observaciones']}'),
                    );
                  },
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  final parteProvider =
                      Provider.of<LineasParte_provider>(context, listen: false);
                  bool allSuccess = true;

                  for (final line in pendingLines) {
                    final success = await parteProvider.createPartes(
                      widget.parte.codigoEmpresa ?? 0,
                      widget.parte.codigoTipoParteLC ?? "",
                      widget.parte.ejercicioParteLC ?? 0,
                      widget.parte.serieParteLc ?? "",
                      widget.parte.numeroParteLC ?? 0,
                      "DEF",
                      line['actividad'],
                      usuarioprovider.codigoClienteConectado ?? "",
                      "DIETA1",
                      0,
                      line['articulo'],
                      line['unidades'],
                      0,
                      0,
                      line['observaciones'],
                    );

                    print(line['articulo']);

                    if (!success) allSuccess = false;
                  }

                  if (allSuccess) {
                    setState(() {
                      pendingLines.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Todas las líneas imputadas correctamente')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Lineas Guardadas Localmente.')));
                    setState(() {
                      pendingLines.clear();
                    });
                    var len = pendingLines.length;
                  }
                },
                child: const Text('Imputar Todas las Líneas'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFields(BuildContext context) {
    unidadesController.clear();
    observacionesController.clear();

    final actividadProvider =
        Provider.of<ActividadProvider>(context, listen: false);
    final articulosProvider =
        Provider.of<Articulos_provider>(context, listen: false);

    actividadProvider.selectedActividad = "";
    articulosProvider.selectedArticulo = "";

    // 🔥 Notifica cambios en la UI
    setState(() {});
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal, width: 1.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
    );
  }
}

class DropdownActividadWidget extends StatefulWidget {
  @override
  _DropdownActividadWidgetState createState() =>
      _DropdownActividadWidgetState();
}

class _DropdownActividadWidgetState extends State<DropdownActividadWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final actividadProvider =
        Provider.of<ActividadProvider>(context, listen: false);

    if (connection) {
      actividadProvider.getActividad();
    } else {
      actividadProvider.getActividadLocales(
          codigoEmpresa: actividadProvider.codigoEmpresa);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActividadProvider>(
      builder: (context, provider, child) {
        // ✅ Crear lista de actividades con código y descripción
        var uniqueActividades = [
              {"codigo": "", "descripcion": "Seleccione una Actividad"}
            ] +
            provider.filteredActividades
                .map((a) => {
                      "codigo": a.codigoActividadParteLc ?? "",
                      "descripcion": a.actividadParteLc ?? "",
                      "codigoArticulo": a.codigoArticulo ??
                          "" // 🔥 Se agrega el código de artículo
                    })
                .toList();

        if (uniqueActividades.length == 1) {
          return const Center(
            child: Text('No hay Actividades disponibles.'),
          );
        }

        // ✅ Mantener la actividad seleccionada correctamente
        String? selectedValue = provider.selectedActividad != null &&
                provider.filteredActividades.any((actividad) =>
                    actividad.codigoActividadParteLc ==
                    provider.selectedActividad)
            ? provider.selectedActividad
            : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButton<String>(
            hint: const Text('Seleccione una Actividad'),
            value: selectedValue, // ✅ Mantener la actividad seleccionada
            isExpanded: true,
            items: uniqueActividades.map((actividad) {
              String codigo = actividad["codigo"]!;
              String descripcion = actividad["descripcion"]!;
              String displayText = codigo.isNotEmpty
                  ? "$codigo - $descripcion" // ✅ Mostrar Código + Descripción
                  : "Seleccione una Actividad";
              codigoDescripcionActividad = displayText;
              return DropdownMenuItem<String>(
                value:
                    codigo, // ✅ Ahora se usa solo el código para evitar errores
                child: Text(
                  displayText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: codigo.isNotEmpty ? Colors.black : Colors.grey,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                // ✅ Buscar la actividad seleccionada
                actividadSeleccionada = provider.filteredActividades.firstWhere(
                  (actividad) => actividad.codigoActividadParteLc == value,
                  orElse: () => ActividadParte(
                      codigoEmpresa: 0,
                      codigoActividadParteLc: "",
                      actividadParteLc: "",
                      imputableLc: 0,
                      codigoArticulo: "",
                      codigoGrupoActividadParteLc: "",
                      esVisibleEnMovil: 0),
                );

                print(
                    "Actividad seleccionada: ${actividadSeleccionada.codigoActividadParteLc}");
                print(
                    "Código Artículo asociado: ${actividadSeleccionada.codigoArticulo}");
                setState(() {
                  provider.selectActividad(
                      actividadSeleccionada.codigoActividadParteLc!, context);
                });

                // ✅ Mantener la selección de actividad
                provider.selectedActividad =
                    actividadSeleccionada.codigoActividadParteLc;
                provider.notifyListeners(); // 🔥 Actualizar UI

                // ✅ Traspasar el código de artículo al otro `DropdownButton`
                Provider.of<VinculacionAlbaran_Provider>(context, listen: false)
                    .setSelectedArticulo(actividadSeleccionada.codigoArticulo);
              }
            },
          ),
        );
      },
    );
  }
}

class DropdownArticulosWidget extends StatefulWidget {
  final int codigoEmpresa;
  final String codigoTipoParte;
  final int ejercicioParte;
  final String serieParte;
  final int numeroParte;

  const DropdownArticulosWidget({
    Key? key,
    required this.codigoEmpresa,
    required this.codigoTipoParte,
    required this.ejercicioParte,
    required this.serieParte,
    required this.numeroParte,
  }) : super(key: key);

  @override
  _DropdownArticulosWidgetState createState() =>
      _DropdownArticulosWidgetState();
}

class _DropdownArticulosWidgetState extends State<DropdownArticulosWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final articulosProvider =
        Provider.of<VinculacionAlbaran_Provider>(context, listen: false);

    // Definiendo las variables para el filtro
    final int codigoEmpresa = widget.codigoEmpresa;
    final String codigoTipoParte = widget.codigoTipoParte;
    final int ejercicioParte = widget.ejercicioParte;
    final String serieParte = widget.serieParte;
    final int numeroParte = widget.numeroParte;

    if (connection) {
      articulosProvider.getArticulos(
        codigoEmpresa: codigoEmpresa,
        codigoTipoParte: codigoTipoParte,
        ejercicioParte: ejercicioParte,
        serieParte: serieParte,
        numeroParte: numeroParte,
      );
    } else {
      //    articulosProvider.getArticulosLocales(codigoEmpresa: codigoEmpresa);

      // Filtrar artículos con las variables establecidas
      /*  articulosProvider.filteredArticulos = articulosProvider.articulos
          .where((map) =>
              map['codigoEmpresa'] == codigoEmpresa &&
              map['codigoTipoParteLc'] == codigoTipoParte &&
              map['eJercicioParteLc'] == ejercicioParte &&
              map['serieParteLc'] == serieParte &&
              map['numeroParteLc'] == numeroParte)
          .toList();
*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VinculacionAlbaran_Provider>(
      builder: (context, provider, child) {
        // ✅ Asegurar que no haya valores `null` y agregar una opción vacía
        final articulosFiltrados = provider.filteredArticulos
            .where((articulo) => articulo.codigoArticulo != "COMENXPARTES")
            .map((articulo) => articulo.codigoArticulo?.trim() ?? "")
            .toSet() // Eliminar duplicados
            .toList();

        // Agregar una opción vacía inicial
        var opcionesArticulos = [""] + articulosFiltrados;

        // 🛑 Si el valor seleccionado no está en la lista, establecerlo en `null`
        if (provider.selectedArticulo != null &&
            !opcionesArticulos.contains(provider.selectedArticulo)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.setSelectedArticulo(null);
          });
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DropdownButton<String>(
            hint: const Text('Seleccione un Artículo'),
            value: (provider.selectedArticulo != null &&
                    opcionesArticulos.contains(provider.selectedArticulo))
                ? provider.selectedArticulo
                : null, // ✅ Evita errores si el valor seleccionado no está en la lista
            isExpanded: true,
            items: opcionesArticulos.map((codigo) {
              return DropdownMenuItem<String>(
                value: codigo,
                child: Text(
                  codigo.isNotEmpty
                      ? codigo.toString()
                      : "Seleccione un Artículo",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: codigo.isNotEmpty ? Colors.black : Colors.grey,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              provider.setSelectedArticulo(value!);
            },
          ),
        );
      },
    );
  }
}

class CerrarParteScreen extends StatefulWidget {
  final parte_ parte;

  const CerrarParteScreen({Key? key, required this.parte}) : super(key: key);

  @override
  _CerrarParteScreenState createState() => _CerrarParteScreenState();
}

class _CerrarParteScreenState extends State<CerrarParteScreen> {
  final TextEditingController unidadesController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  final _clienteController = TextEditingController();
  final SignatureController _operarioSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _clienteSignatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  String connectionStatus = "Comprobando conexión...";
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Escuchar cambios en la conectividad
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await _updateConnectionStatus(result);
    });

    // Verificar conexión al iniciar la pantalla
    _checkInitialConnection();
  }

  // Método para verificar el estado inicial de la conexión
  Future<void> _checkInitialConnection() async {
    final initialResult = await Connectivity().checkConnectivity();
    await _updateConnectionStatus(initialResult);
  }

  // Método para actualizar el estado de la conexión
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final provider = Provider.of<Parte_Provider>(context, listen: false);
    final parteProvider =
        Provider.of<LineasParte_provider>(context, listen: false);

    String status;
    if (result == ConnectivityResult.none) {
      status = "Sin conexión a Internet";
    } else {
      final pendingLines = await parteProvider.getPendingLines();

      if (pendingLines.length > 0) {
        for (final line in pendingLines) {
          final success = await parteProvider.createPartes(
            line['codigoEmpresa'],
            line['codigoTipoParteLc'],
            line['ejercicioParteLc'],
            line['serieParteLc'],
            line['numeroParteLc'],
            line['codigoTipoFaseLc'],
            line['codigoActividadParteLc'],
            line['tecnicoAsignadoLc'],
            line['codigoGastoComercialLc'],
            line['facturableLc'],
            line['codigoArticulo'],
            line['unidades'],
            line['horaEntradaLc'],
            line['liquidableLc'],
            line['observaciones'],
          );
          parteProvider.removeLineLocally(line);
        }
      }

      var pendingLinesCerrado = await provider.getPendingPartesCerrados();

      if (pendingLinesCerrado.length > 0) {
        for (final line in pendingLinesCerrado) {
          await provider.actualizarStatusParte(
              codigoEmpresa: line['codigoEmpresa'],
              codigoTipoParteLC: line['codigoTipoParteLC'],
              ejercicioParteLC: line['ejercicioParteLC'],
              serieParteLc: line['serieParteLc'],
              numeroParteLC: line['numeroParteLC'],
              nuevoStatusParteLc: 3);

          provider.removeParteCerradoLocally(line);
        }
      }

      // Verificar acceso a Internet real
      bool hasInternet = await _checkInternetAccess();
      status =
          hasInternet ? "Conexión a Internet activa" : "Sin acceso a Internet";
    }

    setState(() {
      connectionStatus = status;
    });
  }

  // Método para verificar acceso a Internet real
  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  @override
  void dispose() {
    // Cancelar la suscripción al stream de conectividad
    connectivitySubscription.cancel();
    unidadesController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  void _guardarParte() async {
    final albaran = Provider.of<LineasAlbaranProvider>(context, listen: false);
    final articulosprovider =
        Provider.of<VinculacionAlbaran_Provider>(context, listen: false);
    final provider = Provider.of<Parte_Provider>(context, listen: false);
    final usuario = Provider.of<Usuario_provider>(context, listen: false);
    final partesProvider = Provider.of<Parte_Provider>(context, listen: false);
    final calculoAlbaran =
        Provider.of<CalculoDiferidoAlbaranProvider>(context, listen: false);

    if (_clienteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el nombre del cliente.'),
        ),
      );
      return;
    }

    if (_operarioSignatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, realiza la firma del operario.'),
        ),
      );
      return;
    }

    if (_clienteSignatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, realiza la firma del cliente.'),
        ),
      );
      return;
    }

    try {
      final parte = widget.parte;

      final success = await provider.actualizarStatusParte(
        codigoEmpresa: parte.codigoEmpresa ?? 0,
        codigoTipoParteLC: parte.codigoTipoParteLC ?? "",
        ejercicioParteLC: parte.ejercicioParteLC ?? 0,
        serieParteLc: parte.serieParteLc ?? "",
        numeroParteLC: parte.numeroParteLC ?? 0,
        nuevoStatusParteLc: 3,
      );

      if (success) {
        await articulosprovider.getAlbaran(
            codigoEmpresa: parte.codigoEmpresa,
            codigoTipoParte: parte.codigoTipoParteLC,
            ejercicioParte: parte.ejercicioParteLC,
            serieParte: parte.serieParteLc,
            numeroParte: parte.numeroParteLC);

        for (var i in articulosprovider.albaran) {
          await albaran.insertLineasNegativas(
            codigoEmpresa: i.codigoEmpresa,
            ejercicioAlbaran: i.ejercicioAlbaran,
            serieAlbaran: i.serieAlbaran ?? '',
            numeroAlbaran: i.numeroAlbaran,
          );

          calculoAlbaran.getCalculoDiferido(
              tipoDoc: "AC",
              ejercicio: i.ejercicioAlbaran,
              codigoEmpresa: i.codigoEmpresa,
              serieAlbaran: i.serieAlbaran ?? '',
              numeroAlbaran: i.numeroAlbaran);
        }

        // 🔹 Asegurar que se actualiza la UI antes de cerrar la pantalla
        bool connexion = await _checkInternetAccess();

        if (_pantallaActual == "Activos") {
          if (connexion == true) {
            if (usuario.usuarioAdministrador == "ADM") {
              await partesProvider.getPartesActivosAdministrador();
            } else if (usuario.codigoClienteConectado ==
                usuario.codigoResponsableEquipo) {
              await partesProvider.getPartesPorVariosResponsablesActivos(
                  partesProvider.responsablesPartes);
            } else {
              await partesProvider.getPartesActivos();
            }
          } else {
            partesProvider.filteredPartes =
                await partesProvider.getPartesActivosLocales();
          }
        } else if (_pantallaActual == "Pendientes") {
          if (connexion == true) {
            if (usuario.usuarioAdministrador == "ADM") {
              await partesProvider.getPartesPendientesAdministrador();
            } else if (usuario.codigoClienteConectado ==
                usuario.codigoResponsableEquipo) {
              await partesProvider.getPartesPorVariosResponsablesPendientes(
                  partesProvider.responsablesPartes);
            } else {
              await partesProvider.getPartesPendientes();
            }
          } else {
            partesProvider.filteredPartes =
                await partesProvider.getPartesPendientesLocales();
          }
        } else {
          if (connexion == true) {
            if (usuario.usuarioAdministrador == "ADM") {
              await partesProvider.getPartesTodosAdministrador();
            } else if (usuario.codigoClienteConectado ==
                usuario.codigoResponsableEquipo) {
              await partesProvider.getPartesPorVariosResponsablesTodos(
                  partesProvider.responsablesPartes);
            } else {
              await partesProvider.getPartesTodos();
            }
          } else {
            partesProvider.filteredPartes =
                await partesProvider.getPartesTodosLocales();
          }
        }

        // ✅ Ahora cerrar la pantalla después de actualizar los datos
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el estado del parte.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar el parte: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cerrar Parte - ${widget.parte.numeroParteLC}'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        // Permite el desplazamiento si el contenido es muy largo
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Estado de Conexión: $connectionStatus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: connectionStatus == "Sin conexión a Internet" ||
                          connectionStatus == "Sin acceso a Internet"
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),
            Text(
              'Cerrando Parte ${widget.parte.numeroParteLC}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nombre del Cliente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _clienteController,
              decoration: InputDecoration(
                hintText: 'Ingresa el nombre del cliente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Firma del Operario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _operarioSignatureController,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _operarioSignatureController.clear();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Borrar Firma del Operario'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Firma del Cliente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _clienteSignatureController,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _clienteSignatureController.clear();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Borrar Firma del Cliente'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarParte,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Cerrar Parte'),
            ),
          ],
        ),
      ),
    );
  }
}
