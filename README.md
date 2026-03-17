# 🖨️ Impressão Térmica Pro (Thermal Printer Utility)

Um aplicativo Flutter focado em extrair a máxima qualidade de imagens em impressoras térmicas Bluetooth (58mm) utilizando o protocolo ESC/POS e **Inteligência Artificial Generativa**.

O projeto foi construído lidando com processamento pesado de imagens, manipulação de hardware de baixo nível diretamente no dispositivo e integrações via API, garantindo uma impressão nítida, fluida e criativa.

> **Nota:** Este projeto serve como um caso de estudo avançado sobre integração de hardware via BLE, multithreading em Dart, algoritmos de manipulação de pixels e engenharia de prompt invisível para limitações físicas de impressão.

---

## 🧠 Destaques de Engenharia

O verdadeiro desafio de imprimir fotos em impressoras de cupom fiscal não é a conexão, mas a conversão de dados. Para resolver isso, implementei:

- **Dithering (Floyd-Steinberg) Manual:** Impressoras térmicas só entendem preto (0) ou branco (255) absoluto. O app aplica este algoritmo para distribuir o "erro" de cor para os pixels vizinhos, simulando tons de cinza perfeitos através de pontilhismo.
- **Multithreading com Isolates (`compute`):** O processamento da matriz de pixels de uma foto é pesado. Toda a lógica de Dithering, brilho e contraste roda em uma thread secundária (Isolate). Isso garante que o usuário possa interagir com a UI a 60fps sem travamentos.
- **Engenharia de Prompt para Hardware:** A integração com a API do Hugging Face (Stable Diffusion) injeta modificadores invisíveis nas requisições (`1-bit pixel art`, `high contrast stencil`). Isso força a IA a gerar imagens sem sombras complexas, otimizadas exclusivamente para a limitação binária do papel térmico.
- **Gestão de Buffer Bluetooth (Chunking):** Impressoras de baixo custo (como a KP-1025) possuem buffers pequenos. O envio dos bytes da imagem é fatiado em blocos calculados com delays cirúrgicos (`wakelock` ativo), evitando que a impressora corte linhas por sobrecarga.
- **UI/UX e Estado Global:** Design minimalista baseado na regra 60-30-10, elevando o gerenciamento de estado do Bluetooth para o nível superior (Menu Principal), permitindo que o usuário navegue pelos módulos (Clássico ou IA) sem perder a conexão.

---

## 📸 Demonstração
<img src="https://github.com/user-attachments/assets/d394d1d2-ffcf-4cca-a1ef-31d7ff4d1afd" width="250" /> <img src="https://github.com/user-attachments/assets/d96f42fe-298a-4da9-a3bc-61471b712f88" width="250" /> <img src="https://github.com/user-attachments/assets/344a8f8f-66b8-43cf-aa0a-c9e913402250" width="250" />

*(Nota: Adicione aqui as novas screenshots da tela inicial e da tela de IA!)*

---

## 🚀 Funcionalidades

- **Módulo de IA Generativa:** Crie imagens do zero usando prompts de texto conectados à API do Hugging Face.
- **Conexão Bluetooth LE Global**: Escaneamento e conexão robusta com impressoras térmicas direto da Home.
- **Gerenciamento de Imagens**: Captura via Câmera, Galeria e ferramenta de Recorte (Crop) integrada.
- **Processamento Avançado**: Ajustes em tempo real de Contraste e Brilho diretamente na matriz da imagem.
- **Preview Dinâmico**: Visualize exatamente como a imagem será mapeada no papel térmico antes de imprimir.

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) - Framework UI.
- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) - Comunicação Bluetooth LE.
- [esc_pos_utils_plus](https://pub.dev/packages/esc_pos_utils_plus) - Geração de comandos ESC/POS.
- [image](https://pub.dev/packages/image) - Manipulação em baixo nível de matrizes de pixels.
- [http](https://pub.dev/packages/http) & [Hugging Face API](https://huggingface.co/) - Geração de imagens via Stable Diffusion XL.
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) - Segurança e injeção de variáveis de ambiente.

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

**3. Configure a Chave da IA (Segurança):**
O aplicativo utiliza a API gratuita do Hugging Face. Para rodar o gerador de imagens localmente, você precisa configurar a sua chave de acesso:
- Crie uma conta em [huggingface.co](https://huggingface.co/).
- Vá em **Settings > Access Tokens** e crie um token (tipo Read).
- Na raiz do projeto (mesmo nível do `pubspec.yaml`), crie um arquivo chamado exatamente **`.env`**.
- Adicione a seguinte linha dentro do arquivo `.env`:
  ```env
  HF_API_KEY=hf_SUA_CHAVE_GERADA_AQUI
  ```
*(O arquivo `.env` já está no `.gitignore` para não vazar a sua chave em commits públicos).*

**4. Configure as permissões (Android):**
O projeto requer permissões de Bluetooth e Localização (já mapeadas no `AndroidManifest.xml`).

**5. Execute o App:**
Conecte seu dispositivo via USB e rode:
```bash
flutter run
```

## 📄 Licença
Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.