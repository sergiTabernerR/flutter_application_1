import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/Actividad_Provider.dart';
import 'package:flutter_application_1/Providers/Articulos_Provider.dart';
import 'package:flutter_application_1/Providers/ConfigManager.dart';
import 'package:flutter_application_1/Providers/EquipoAplicador_Provider.dart';
import 'package:flutter_application_1/Providers/fases_provider.dart';
import 'package:flutter_application_1/Providers/lineasParte_provider.dart';
import 'package:flutter_application_1/Providers/parte_provider.dart';
import 'package:flutter_application_1/Providers/usuario_provider.dart';
import 'package:flutter_application_1/models/FasesPartes.dart';
import 'package:flutter_application_1/models/usuario.dart';
import 'package:flutter_application_1/widgets/input_decoration.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _txtUsuario = TextEditingController();
  final _txtPassword = TextEditingController();
  final _usuarioFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _txtUsuario.dispose();
    _txtPassword.dispose();
    _usuarioFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _navigateToConfig(BuildContext context) async {
    // Navegar a la pantalla de configuración
    await Navigator.pushNamed(context, 'config');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ConfigManager.loadConfig(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar un indicador de carga mientras se verifica la configuración
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          // Si no hay configuración, redirigir a la pantalla de configuración
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, 'config');
          });
          return const Scaffold(); // Pantalla vacía mientras redirige
        } else {
          // Si hay configuración, mostrar la pantalla de login
          return _buildLoginScreen(context);
        }
      },
    );
  }

  Widget _buildLoginScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Ocultar teclado al tocar fuera
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                cajaVerde(size),
                iconoPersona(),
                loginForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginForm(BuildContext context) {
    final usuarioProvider = Provider.of<Usuario_provider>(context);
    final partesProvider = Provider.of<Parte_Provider>(context);
    final lineasProvider = Provider.of<LineasParte_provider>(context);
    final fasesProvider = Provider.of<FasesProvider>(context);
    final actividadProvider = Provider.of<ActividadProvider>(context);
    final articulosProvider = Provider.of<Articulos_provider>(context);
    final equipoAplicador = Provider.of<EquipoAplicadorProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 250),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
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
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      focusNode: _usuarioFocusNode,
                      controller: _txtUsuario,
                      decoration: InputDecorations.inputDecoration(
                        hintText: "User",
                        labelText: "User",
                        icon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      focusNode: _passwordFocusNode,
                      controller: _txtPassword,
                      obscureText: true,
                      decoration: InputDecorations.inputDecoration(
                        hintText: "Password",
                        labelText: "Password",
                        icon: const Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final usuarioProvider =
                                Provider.of<Usuario_provider>(context,
                                    listen: false);
                            print("==================");

                            usuarioProvider.getUsuarios();
                            print("ddd");

                            // Usar usuarios del almacenamiento local si no hay conexión
                            var usuarios = usuarioProvider.usuarios;
                            print(usuarioProvider.usuarios);
                            print(usuarios.length);
                            for (var i in usuarios) {
                              print(i.usuarioLogicNet);
                              print(i.contraseaLogicNet);
                            }

                            if (usuarios.isNotEmpty) {
                              var usuarioEncontrado = usuarios.firstWhere((e) =>
                                  e.usuarioLogicNet == _txtUsuario.text &&
                                  e.contraseaLogicNet == _txtPassword.text);
                              if (usuarioEncontrado != null) {
                                usuarioProvider.codigoClienteConectado =
                                    usuarioEncontrado.codigoCliente;
                                usuarioProvider.usuarioAdministrador =
                                    usuarioEncontrado.codigoCategoriaEmpleadoLc;
                                partesProvider.responsableParteLc =
                                    usuarioProvider.codigoClienteConectado ??
                                        "";

                                await partesProvider.getPartes();
                                var partesActivos = await partesProvider
                                    .getPendingPartesActivos();
                                // await partesProvider
                                //    .savePartesActivosLocal(partesActivos);

                                //      await partesProvider.getPartesPendientes();

                                //     var partesPendientes = await partesProvider
                                //         .getPendingPartesPendientes();

                                //     await partesProvider.savePartesPendientesLocal(
                                //         partesPendientes);
                                if (usuarioProvider.usuarioAdministrador ==
                                    "ADM") {
                                  //    await partesProvider
                                  //      .getPartesTodosAdministrador();
                                  //  partesProvider.filteredPartes =
                                  //     partesProvider.partes;
                                } else {
                                  //   await partesProvider.getPartesTodos();
                                  //   var partesTodos = await partesProvider
                                  //      .getPendingPartesTodos();

                                  //     await partesProvider
                                  //       .savePartesTodosLocal(partesTodos);
                                }
                                //  await lineasProvider.getTodasLineasPartes();

                                //    var lineasPartes = await lineasProvider
                                //         .getPendingLineasPartes();
                                //    await lineasProvider
                                //        .savePartesTodosLocal(lineasPartes);

                                //     await fasesProvider.getFases();

                                //   var fase = await fasesProvider.getTodasFases();

                                // await fasesProvider.saveFasesLocal(fase);

                                //  await actividadProvider.getActividad();

                                //   var actividad = await actividadProvider//
                                //         .getTodasActividades();

                                //     await actividadProvider
                                //          .saveActividadLocal(actividad);

                                //     await articulosProvider.getArticulos();

                                //        var articulos =
                                //            await articulosProvider.getTodosArticulos();

                                //        await articulosProvider
                                //            .saveArticulosLocal(articulos);

                                await equipoAplicador.getEquiposAplicadores();

                                Navigator.pushReplacementNamed(
                                    context, 'parte');
                              } else {
                                showErrorMessage(context,
                                    'Usuario o contraseña incorrectos');
                              }
                            } else {
                              showErrorMessage(context,
                                  'No hay usuarios disponibles localmente.');
                            }
                          } catch (e) {
                            // En caso de error, cargar usuarios locales y validarlos
                            print('Error durante la validación: $e');

                            final usuarioProvider =
                                Provider.of<Usuario_provider>(context,
                                    listen: false);

                            if (usuarioProvider.usuarios.isNotEmpty) {
                              var usuarioEncontrado = usuarioProvider.usuarios
                                  .firstWhere((e) =>
                                      e.usuarioLogicNet == _txtUsuario.text &&
                                      e.contraseaLogicNet == _txtPassword.text);

                              if (usuarioEncontrado != null) {
                                usuarioProvider.codigoClienteConectado =
                                    usuarioEncontrado.codigoCliente;
                                Navigator.pushReplacementNamed(
                                    context, 'parte');
                              } else {
                                showErrorMessage(context,
                                    'Usuario o contraseña incorrectos');
                              }
                            } else {
                              showErrorMessage(context,
                                  'Error al validar el usuario y no hay datos locales.');
                            }
                          }
                        }
                      },
                      child: const Text('Ingresar'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => _navigateToConfig(context),
                      child: const Text(
                        "Configurar Conexión",
                        style: TextStyle(color: Colors.blue),
                      ),
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

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  SafeArea iconoPersona() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        width: double.infinity,
        child: const Icon(Icons.person_pin, color: Colors.white, size: 100),
      ),
    );
  }

  Container cajaVerde(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal,
            Color.fromARGB(90, 70, 178, 1),
          ],
        ),
      ),
      width: double.infinity,
      height: size.height * 0.4,
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
