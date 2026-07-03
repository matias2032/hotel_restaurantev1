// lib/main.dart

import 'app_imports.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await ApiConfig.baseUrlAsync;
  ApiConfig.printConfig();

  /*
   * LocalDatabase fica comentado por enquanto.
   * Activamos quando fores criar o cache local com:
   *
   * await LocalDatabase.instance.init();
   */

  runApp(const HotelRestauranteApp());
}

class HotelRestauranteApp extends StatelessWidget {
  const HotelRestauranteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioRepository = UsuarioRepository(
      service: UsuarioService(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UsuarioProvider(repository: usuarioRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Hotel Restaurante Admin',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF111827),
            primary: const Color(0xFF111827),
            secondary: const Color(0xFFF97316),
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Color(0xFF111827),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFF97316),
                width: 1.4,
              ),
            ),
          ),
        ),

        // Primeira tela ao rodar o projecto
        initialRoute: '/usuarios',

        routes: {
          '/': (_) => const UsuarioListScreen(),
          '/usuarios': (_) => const UsuarioListScreen(),
          '/usuarios/form': (_) => const UsuarioFormScreen(),
          '/usuarios/detalhes': (_) => const UsuarioDetalhesScreen(),
        },

        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text('Rota não encontrada'),
              ),
              body: Center(
                child: Text(
                  'A rota "${settings.name}" não existe.',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}