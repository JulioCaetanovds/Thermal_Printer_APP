import 'package:flutter/material.dart';
import 'printer_controller.dart';
import 'classic_print_screen.dart';
import 'ai_creation_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final PrinterController controller;

  const MainMenuScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Center(
                    child: Text(
                      'Impressão\nTérmica Pro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1D1F),
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildConnectionCard(context),
                  
                  const SizedBox(height: 32),
                  _buildMenuCard(
                    context: context,
                    title: 'Impressão Clássica',
                    subtitle: 'Galeria, câmera e ajustes',
                    icon: Icons.print_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassicPrintScreen(controller: controller),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context: context,
                    title: 'Criação com IA',
                    subtitle: 'Gere imagens direto no papel',
                    icon: Icons.auto_awesome,
                    isAi: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiCreationScreen(controller: controller),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionCard(BuildContext context) {
    final isConnected = controller.connectedDevice != null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? Colors.green.withOpacity(0.5) : const Color(0xFFEBEBEB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: isConnected ? Colors.green[700] : Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isConnected ? 'Conectado a ${controller.connectedDevice!.platformName}' : 'Nenhuma impressora',
                  style: TextStyle(
                    color: isConnected ? Colors.green[800] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isConnected)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: controller.disconnect,
                )
              else
                ElevatedButton(
                  onPressed: controller.startScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F7),
                    foregroundColor: const Color(0xFF5E4B8A),
                    elevation: 0,
                  ),
                  child: const Text('Buscar'),
                ),
            ],
          ),
          if (!isConnected && controller.scanResults.isNotEmpty) ...[
            const Divider(height: 24, color: Color(0xFFEBEBEB)),
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: controller.scanResults.length,
                itemBuilder: (context, index) {
                  final r = controller.scanResults[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      r.device.platformName.isNotEmpty ? r.device.platformName : "Device",
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: TextButton(
                      onPressed: () => controller.connect(r.device),
                      child: const Text('Conectar'),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isAi = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isAi ? const Color(0xFF5E4B8A).withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF5E4B8A), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D1D1F))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}