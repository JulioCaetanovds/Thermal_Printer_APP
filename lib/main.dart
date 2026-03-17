import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'printer_controller.dart';
import 'main_menu_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  WakelockPlus.enable(); // Mantém a tela acesa
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PrinterController();
    controller.init();

    return MaterialApp(
      title: 'Thermal Printer Utility',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E4B8A),
          primary: const Color(0xFF5E4B8A),
          surface: const Color(0xFFFAFAFA), 
        ),
        useMaterial3: true,
      ),
      home: MainMenuScreen(controller: controller),
    );
  }
}