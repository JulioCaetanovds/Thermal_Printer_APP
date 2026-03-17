import 'package:flutter/material.dart';
import 'printer_controller.dart';

class ClassicPrintScreen extends StatelessWidget {
  final PrinterController controller;

  const ClassicPrintScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            title: const Text('Impressão Clássica', style: TextStyle(fontSize: 18)),
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF1D1D1F),
            elevation: 0,
            centerTitle: true,
            actions: [
              Icon(
                controller.connectedDevice != null
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: controller.connectedDevice != null
                    ? const Color(0xFF5E4B8A) // Design integrado
                    : Colors.grey[400],
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Status Bar Refatorada
                if (controller.statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        controller.statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF5E4B8A), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                if (controller.connectedDevice == null)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.startScan,
                          icon: const Icon(Icons.search),
                          label: const Text("Buscar Impressoras"),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFF5F5F7),
                            foregroundColor: const Color(0xFF5E4B8A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: controller.scanResults.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEBEBEB)),
                            itemBuilder: (context, index) {
                              final r = controller.scanResults[index];
                              return ListTile(
                                title: Text(r.device.platformName.isNotEmpty ? r.device.platformName : "Device"),
                                subtitle: Text(r.device.remoteId.toString(), style: TextStyle(color: Colors.grey[500])),
                                trailing: TextButton(
                                  onPressed: () => controller.connect(r.device),
                                  child: const Text('Conectar'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                if (controller.connectedDevice != null) const Divider(color: Color(0xFFEBEBEB), height: 1),

                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7), // Cinza Soft
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: controller.isProcessing
                                ? const CircularProgressIndicator(color: Color(0xFF5E4B8A))
                                : controller.previewBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.memory(
                                          controller.previewBytes!,
                                          fit: BoxFit.contain,
                                          gaplessPlayback: true,
                                        ),
                                      )
                                    : Text("Nenhuma imagem selecionada", style: TextStyle(color: Colors.grey[500])),
                          ),
                        ),
                        if (controller.previewBytes != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: controller.saveToGallery,
                                icon: const Icon(Icons.save_alt, size: 20),
                                label: const Text("Salvar na Galeria"),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF5E4B8A)),
                              ),
                            ),
                          ),
                        if (controller.selectedImage != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ajuste de Qualidade", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.contrast, size: 20, color: Color(0xFF5E4B8A)),
                                    Expanded(
                                      child: Slider(
                                        value: controller.contrast,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        activeColor: const Color(0xFF5E4B8A),
                                        inactiveColor: const Color(0xFF5E4B8A).withOpacity(0.2),
                                        onChanged: (v) => controller.updateParams(v, controller.brightness),
                                        onChangeEnd: (_) => controller.generatePreview(),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.brightness_6, size: 20, color: Color(0xFF5E4B8A)),
                                    Expanded(
                                      child: Slider(
                                        value: controller.brightness,
                                        min: 0.1,
                                        max: 2.0,
                                        divisions: 19,
                                        activeColor: const Color(0xFF5E4B8A),
                                        inactiveColor: const Color(0xFF5E4B8A).withOpacity(0.2),
                                        onChanged: (v) => controller.updateParams(controller.contrast, v),
                                        onChangeEnd: (_) => controller.generatePreview(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton.filledTonal(
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.photo_library),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F7),
                          foregroundColor: const Color(0xFF5E4B8A),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: controller.takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F7),
                          foregroundColor: const Color(0xFF5E4B8A),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: ElevatedButton.icon(
                            onPressed: (controller.connectedDevice != null &&
                                    controller.previewBytes != null &&
                                    !controller.isPrinting)
                                ? controller.printImage
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E4B8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: controller.isPrinting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.print),
                            label: const Text('IMPRIMIR', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}