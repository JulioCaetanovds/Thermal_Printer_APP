import 'package:flutter/material.dart';
import 'package:thermal_printer_utility/printer_controller.dart';

class AiCreationScreen extends StatefulWidget {
  final PrinterController controller;

  const AiCreationScreen({super.key, required this.controller});

  @override
  State<AiCreationScreen> createState() => _AiCreationScreenState();
}

class _AiCreationScreenState extends State<AiCreationScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            title: const Text('Criação com IA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFFAFAFA),
            foregroundColor: const Color(0xFF1D1D1F),
            elevation: 0,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            actions: [
              Icon(
                widget.controller.connectedDevice != null ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: widget.controller.connectedDevice != null ? const Color(0xFF5E4B8A) : Colors.grey[400],
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (widget.controller.statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        widget.controller.statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF5E4B8A), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Center(
                            child: widget.controller.isProcessing
                                ? const CircularProgressIndicator(color: Color(0xFF5E4B8A))
                                : widget.controller.previewBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.memory(widget.controller.previewBytes!, fit: BoxFit.contain, gaplessPlayback: true),
                                      )
                                    : Text("A magia aparecerá aqui", style: TextStyle(color: Colors.grey[500])),
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Descreva a imagem:", style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _promptController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: "Ex: Um gato usando óculos escuros, estilo pixel art...",
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F7),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: widget.controller.isProcessing ? null : () {
                                  FocusScope.of(context).unfocus();
                                  widget.controller.generateFromAi(_promptController.text);
                                },
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text("GERAR COM IA"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F5F7),
                                  foregroundColor: const Color(0xFF5E4B8A),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, -5))],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: (widget.controller.connectedDevice != null && widget.controller.previewBytes != null && !widget.controller.isPrinting)
                        ? widget.controller.printImage
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E4B8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: widget.controller.isPrinting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.print),
                    label: const Text('IMPRIMIR', style: TextStyle(fontWeight: FontWeight.bold)),
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