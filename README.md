# 🖨️ Impressão Térmica Pro (Thermal Printer Utility)

Um aplicativo Flutter focado em extrair a máxima qualidade de imagens em impressoras térmicas Bluetooth (58mm) utilizando o protocolo ESC/POS.

O projeto foi construído com uma mentalidade "Offline First", lidando com processamento pesado de imagens e manipulação de hardware de baixo nível diretamente no dispositivo, garantindo uma impressão nítida, fluida e sem travamentos.

> **Nota:** Este projeto serve como um caso de estudo sobre integração de hardware via BLE, multithreading em Dart e algoritmos de manipulação de pixels.

---

## 🧠 Destaques de Engenharia

O verdadeiro desafio de imprimir fotos em impressoras de cupom fiscal não é a conexão, mas a conversão e o envio de dados. Para resolver isso, implementei:

- **Dithering (Floyd-Steinberg) Manual:** Impressoras térmicas só entendem preto (0) ou branco (255) absoluto. O app aplica este algoritmo para distribuir o "erro" de cor para os pixels vizinhos, simulando tons de cinza perfeitos através de pontilhismo.
- **Multithreading com Isolates (`compute`):** O processamento da matriz de pixels de uma foto é pesado. Toda a lógica de Dithering, brilho e contraste roda em uma thread secundária (Isolate). Isso garante que o usuário possa ajustar os sliders em tempo real sem derrubar os frames (60fps) da UI.
- **Gestão de Buffer Bluetooth (Chunking):** Impressoras de baixo custo (como a KP-1025) possuem buffers muito pequenos. O envio dos bytes da imagem é fatiado em blocos estrategicamente calculados, com delays cirúrgicos e uso de `writeWithoutResponse`, evitando que a impressora corte linhas ou trave por sobrecarga.

---

## 📸 Demonstração
<img src="https://github.com/user-attachments/assets/d394d1d2-ffcf-4cca-a1ef-31d7ff4d1afd" width="250" /> <img src="https://github.com/user-attachments/assets/d96f42fe-298a-4da9-a3bc-61471b712f88" width="250" /> <img src="https://github.com/user-attachments/assets/344a8f8f-66b8-43cf-aa0a-c9e913402250" width="250" />

<img width="500" height="1608" alt="carbon" src="https://github.com/user-attachments/assets/19656d22-45d4-4958-aa0b-592cc5fff310" />


---

## 🚀 Funcionalidades

- **Conexão Bluetooth LE**: Escaneamento e conexão robusta com impressoras térmicas (BLE).
- **Gerenciamento de Imagens**: Captura via Câmera, Galeria e ferramenta de **Recorte (Crop)** integrada para ajustar a área de impressão.
- **Processamento Avançado**: Ajustes em tempo real de Contraste e Brilho diretamente na matriz da imagem.
- **Preview Dinâmico**: Visualize exatamente como a imagem será mapeada no papel térmico antes de gastar bobina.

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) - Framework UI.
- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) - Comunicação Bluetooth LE.
- [esc_pos_utils_plus](https://pub.dev/packages/esc_pos_utils_plus) - Geração de comandos ESC/POS.
- [image](https://pub.dev/packages/image) - Manipulação em baixo nível de matrizes de pixels.

## 📱 Pré-requisitos & Hardware Testado

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versão 3.x)
- Dispositivo Android físico (Emuladores não suportam BLE nativamente).
- Impressoras testadas: **KP-1025**, GoLink e modelos genéricos chineses de 58mm.

## 🔧 Instalação

**1. Clone o repositório:**
```bash
git clone [https://github.com/seu-usuario/thermal-printer-app.git](https://github.com/seu-usuario/thermal-printer-app.git)
cd thermal-printer-app
```

**2. Instale as dependências:**
```bash
flutter pub get
```

**3. Configure as permissões (Android):**
O projeto requer permissões de Bluetooth e Localização (já mapeadas no `AndroidManifest.xml`).

**4. Execute o App:**
Conecte seu dispositivo via USB e rode:
```bash
flutter run
```

## 📄 Licença
Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
