# Impressão Térmica Pro (Thermal Printer Utility)

Um aplicativo Flutter desenvolvido para facilitar a impressão de imagens em impressoras térmicas Bluetooth (58mm) utilizando protocolo ESC/POS.

O projeto foca em oferecer uma experiência "Offline First", com recursos avançados de processamento de imagem para garantir a melhor qualidade de impressão em preto e branco (dithering).

## 🚀 Funcionalidades

- **Conexão Bluetooth LE**: Escaneamento e conexão robusta com impressoras térmicas via Bluetooth Low Energy (BLE).
- **Gerenciamento de Imagens**:
  - Captura de fotos via Câmera.
  - Seleção de imagens da Galeria.
  - Ferramenta de **Recorte (Crop)** integrada para ajustar a área de impressão.
- **Processamento de Imagem Avançado**:
  - Conversão para Escala de Cinza e Preto & Branco.
  - Algoritmo de **Dithering (Floyd-Steinberg)** para simulação de tons de cinza com alta qualidade.
  - Ajustes em tempo real de **Contraste** e **Brilho**.
- **Preview em Tempo Real**: Visualize como a imagem ficará no papel térmico antes de imprimir.
- **Gerenciamento de Conexão**: Indicadores visuais de status (conectado/desconectado).

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) - Framework UI.
- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) - Comunicação Bluetooth LE.
- [esc_pos_utils_plus](https://pub.dev/packages/esc_pos_utils_plus) - Geração de comandos ESC/POS.
- [image](https://pub.dev/packages/image) - Manipulação e processamento de pixels.
- [image_picker](https://pub.dev/packages/image_picker) - Seleção de fotos.
- [image_cropper](https://pub.dev/packages/image_cropper) - Recorte de imagens UI.
- [permission_handler](https://pub.dev/packages/permission_handler) - Gerenciamento de permissões do sistema (Android/iOS).

## 📱 Pré-requisitos

Para rodar este projeto, você precisará de:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versão recomendada: 3.x)
- Android Studio ou VS Code configurado.
- Um dispositivo Android físico (para testar o Bluetooth, já que emuladores não suportam Bluetooth nativamente).
- Uma impressora térmica Bluetooth (ex: GoLink, genéricas 58mm).

## 🔧 Instalação

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/thermal-printer-app.git
   cd thermal-printer-app
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Configure as permissões (Android):**
   O projeto já deve ter as permissões necessárias configuradas em `android/app/src/main/AndroidManifest.xml`:
   - `BLUETOOTH_SCAN`
   - `BLUETOOTH_CONNECT`
   - `ACCESS_FINE_LOCATION` (para versões antigas do Android)
   - `CAMERA`

4. **Execute o App:**
   Conecte seu dispositivo via USB e rode:
   ```bash
   flutter run
   ```

## 📖 Como Usar

1. Dê as permissões necessárias solicitadas ao abrir o app.
2. Toque em "Buscar Impressoras" para encontrar dispositivos BLE próximos.
3. Conecte-se à sua impressora térmica.
4. Selecione uma imagem da galeria ou tire uma foto.
5. Faça o recorte (crop) da área desejada.
6. Use os sliders de **Contraste** e **Brilho** para ajustar a visualização no preview.
7. Toque no botão "IMPRIMIR" para enviar a imagem para a impressora.

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
