import 'package:flutter/material.dart';
import 'printer_controller.dart';

class HomeScreen extends StatelessWidget {
  final PrinterController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // --- ALTERADO: AnimatedBuilder removido do Scaffold e colocado apenas nos componentes ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressão Térmica Pro'),
        backgroundColor: const Color(0xFF0D1B50),
        foregroundColor: Colors.white,
        actions: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Icon(
                controller.connectedDevice != null
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: controller.connectedDevice != null
                    ? Colors.greenAccent
                    : Colors.redAccent,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.statusMessage.isEmpty) return const SizedBox();
                return Container(
                  width: double.infinity,
                  color: Colors.amber[100],
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    controller.statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.connectedDevice != null) return const SizedBox();
                return Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: controller.startScan,
                        child: const Text("Buscar Impressoras"),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: controller.scanResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final r = controller.scanResults[index];
                            return ListTile(
                              title: Text(
                                r.device.platformName.isNotEmpty
                                    ? r.device.platformName
                                    : "Device",
                              ),
                              subtitle: Text(r.device.remoteId.toString()),
                              trailing: ElevatedButton(
                                onPressed: () => controller.connect(r.device),
                                child: const Text('Conectar'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return Column(
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: controller.isProcessing
                                ? const CircularProgressIndicator()
                                : controller.previewBytes != null
                                    ? Image.memory(
                                        controller.previewBytes!,
                                        fit: BoxFit.contain,
                                        gaplessPlayback: true,
                                      )
                                    : const Text("Nenhuma imagem selecionada"),
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
                                label: const Text("Salvar cópia na Galeria"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        if (controller.selectedImage != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const Text("Ajuste de Qualidade (Preto / Branco)"),
                                Row(
                                  children: [
                                    const Icon(Icons.contrast, size: 20),
                                    Expanded(
                                      child: Slider(
                                        value: controller.contrast,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        label: "Contraste: ${controller.contrast.toStringAsFixed(1)}",
                                        onChanged: (v) => controller.updateParams(v, controller.brightness),
                                        onChangeEnd: (_) => controller.generatePreview(),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.brightness_6, size: 20),
                                    Expanded(
                                      child: Slider(
                                        value: controller.brightness,
                                        min: 0.1,
                                        max: 2.0,
                                        divisions: 19,
                                        label: "Brilho: ${controller.brightness.toStringAsFixed(1)}",
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
                    );
                  },
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                ],
              ),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton.filledTonal(
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.photo_library),
                      ),
                      IconButton.filledTonal(
                        onPressed: controller.takePhoto,
                        icon: const Icon(Icons.camera_alt),
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
                              backgroundColor: const Color(0xFF0D1B50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: controller.isPrinting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.print),
                            label: const Text('IMPRIMIR'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}