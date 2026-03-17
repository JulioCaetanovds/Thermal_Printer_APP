import 'package:flutter/material.dart';
import 'printer_controller.dart';
import 'main_menu_screen.dart'; 

void main() {
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
        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // 60% Dominante (Gelo)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E4B8A), // 10% Destaque (Azul Arroxeado)
          primary: const Color(0xFF5E4B8A),
          surface: const Color(0xFFFAFAFA), 
        ),
        useMaterial3: true,
      ),
      home: MainMenuScreen(controller: controller),
    );
  }
}