import 'package:flutter/material.dart';
import 'package:flutter_application_1/Providers/Actividad_Provider.dart';
import 'package:flutter_application_1/Providers/Articulos_Provider.dart';
import 'package:flutter_application_1/Providers/CalculoDiferidoAlbaranProvider.dart';
import 'package:flutter_application_1/Providers/DomicilioProvider.dart';
import 'package:flutter_application_1/Providers/EquipoAplicador_Provider.dart';
import 'package:flutter_application_1/Providers/GlobalConfig.dart';
import 'package:flutter_application_1/Providers/LineasAlbaranProvider.dart';
import 'package:flutter_application_1/Providers/VinculacionAlbaran_Provider.dart';
import 'package:flutter_application_1/Providers/fases_provider.dart';
import 'package:flutter_application_1/Providers/lineasParte_provider.dart';
import 'package:flutter_application_1/Providers/usuario_provider.dart';
import 'package:flutter_application_1/Providers/parte_provider.dart';
import 'package:flutter_application_1/screens/ServerConfigScreen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/parte.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfig.instance
      .initialize(); // Asegura que serverConfig está inicializado antes de los Providers

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Parte_Provider()),
        ChangeNotifierProvider(create: (_) => Usuario_provider()),
        ChangeNotifierProvider(create: (_) => FasesProvider()),
        ChangeNotifierProvider(
            create: (_) => ActividadProvider(VinculacionAlbaran_Provider())),
        ChangeNotifierProvider(create: (_) => LineasParte_provider()),
        ChangeNotifierProvider(create: (_) => Articulos_provider()),
        ChangeNotifierProvider(create: (_) => EquipoAplicadorProvider()),
        ChangeNotifierProvider(create: (_) => VinculacionAlbaran_Provider()),
        ChangeNotifierProvider(create: (_) => LineasAlbaranProvider()),
        ChangeNotifierProvider(create: (_) => CalculoDiferidoAlbaranProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                Domicilioprovider()), // Ahora puede acceder sin errores
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Api Imputaciones',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('es', 'ES'), // Español
      ],
      routes: {
        'login': (_) => const LoginScreen(),
        'parte': (_) => const PantallaParte(),
        'LoginScreen': (_) => const LoginScreen(),
        'config': (_) => ServerConfigScreen(),
      },
      initialRoute: 'login',
    );
  }
}
