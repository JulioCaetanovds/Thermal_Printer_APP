import 'package:flutter/material.dart';
import 'printer_controller.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciando controller aqui para simplicidade
    final controller = PrinterController();

    // Inicializa listeners e permissions
    controller.init();

    return MaterialApp(
      title: 'Thermal Printer Utility',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D1B50)),
        useMaterial3: true,
      ),
      home: HomeScreen(controller: controller),
    );
  }
}
