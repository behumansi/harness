---
name: generate-image
description: |
  Gera imagens via Google Gemini 2.5 Flash Image API. Use quando o user pedir pra gerar imagem,
  criar ilustração, background, banner, hero image, avatar, ou qualquer asset visual.
  Triggers: "gera uma imagem", "cria uma imagem", "generate image", "hero image", "background image",
  "banner", "ilustração", "gera com gemini", "nano banana".
version: 1.0.0
license: MIT
layer: bh
---

# Generate Image · Gemini 2.5 Flash Image

Gera imagens usando a API do Google Gemini 2.5 Flash Image. Suporta prompts customizados, reference images, e salva direto no projeto.

## Config

- **API Key:** `${GEMINI_API_KEY}`
- **Model:** `gemini-2.5-flash-image`
- **Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent`

## Como usar

### Step 1: Entender o pedido

Pergunte ou infira:
- O que precisa ser gerado (hero, banner, avatar, ilustração, etc.)
- Dimensões desejadas (mencionar no prompt)
- Paleta de cores (usar brand colors do projeto se disponíveis)
- Onde salvar o arquivo (default: `public/` do projeto atual)

### Step 2: Gerar a imagem

Crie um script temporário em `/tmp/gen-image-{timestamp}.mjs`:

```javascript
import fs from "fs";

const API_KEY = "${GEMINI_API_KEY}";
const URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=${API_KEY}`;

const prompt = `<DETAILED_PROMPT_HERE>`;

async function generate() {
  console.log("Generating image via Gemini 2.5 Flash Image...");

  const body = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: { responseModalities: ["image", "text"] },
  };

  // Optional: add reference images
  // const refImage = fs.readFileSync("/path/to/reference.png");
  // body.contents[0].parts.unshift({
  //   inlineData: { mimeType: "image/png", data: refImage.toString("base64") }
  // });

  const res = await fetch(URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const err = await res.text();
    console.error("API Error:", res.status, err);
    process.exit(1);
  }

  const data = await res.json();
  const parts = data.candidates?.[0]?.content?.parts || [];

  for (const part of parts) {
    if (part.inlineData) {
      const buf = Buffer.from(part.inlineData.data, "base64");
      const ext = part.inlineData.mimeType.includes("png") ? "png" : "webp";
      const outPath = `<OUTPUT_PATH>.${ext}`;
      fs.writeFileSync(outPath, buf);
      console.log(`Saved: ${outPath} (${(buf.length / 1024).toFixed(1)}KB)`);
    }
    if (part.text) console.log("AI:", part.text);
  }
}

generate().catch(console.error);
```

### Step 3: Executar e validar

1. Rodar com `node /tmp/gen-image-{timestamp}.mjs` (timeout 120s)
2. Ler a imagem gerada com Read tool pra validar visualmente
3. Mostrar pro user e perguntar se quer ajustar

## Dicas de prompt

- Sempre especificar dimensões no prompt (ex: "1440x600 pixels, landscape")
- Mencionar "NO text, NO logos" se não quiser texto na imagem
- Pra manter consistência de personagem, usar reference images via inlineData
- Pra backgrounds, sempre pedir fade/dissolve nas bordas
- Usar paleta de cores específica do projeto quando disponível
- Retries: se 429 (quota), esperar 5s e tentar de novo (max 3x)

## Modelos disponíveis

| Modelo | Uso |
|--------|-----|
| `gemini-2.5-flash-image` | Geração rápida, boa qualidade (default) |

## Limitações

- Output sempre em PNG ou WebP (não controla formato)
- Dimensões no prompt são sugestivas (modelo pode gerar diferente)
- Rate limit: ~15 requests/min
- Sem NSFW, sem pessoas reais, sem logos de marcas reais
