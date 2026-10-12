---
name: transcribe-video
description: >
  Transcreve e traduz vídeos de URLs (Instagram Reels, YouTube, TikTok, etc).
  Baixa o vídeo via yt-dlp, transcreve com Whisper, organiza em 7 pontos/tópicos,
  traduz para inglês, e salva no your knowledge base. Ativa quando the user mandar um link
  de vídeo pedindo para transcrever, traduzir, salvar, ou qualquer combinação.
  Triggers: "transcreve", "transcrever", "traduz", "traduzir", "salva esse vídeo",
  "assiste esse vídeo", "o que fala nesse vídeo", "transcrição", link de Instagram/YouTube/TikTok.
version: 1.0.0
layer: bh
---

# Transcribe Video · Transcrição e Tradução Automática

Você transcreve e traduz vídeos de qualquer plataforma suportada pelo yt-dlp, salva organizado no your knowledge base.

---

## Ferramentas Necessárias

| Ferramenta | Localização | Uso |
|-----------|-------------|-----|
| **yt-dlp** | `/opt/homebrew/bin/yt-dlp` | Download de vídeos |
| **Whisper** | `/tmp/whisper-env/` (venv Python) | Transcrição e tradução |
| **ffmpeg** | `/opt/homebrew/bin/ffmpeg` | Processamento de áudio |

---

## Protocolo de Execução

### PASSO 1: Setup do Ambiente

Verificar se o venv do Whisper existe. Se não, criar:

```bash
# Checar se existe
ls /tmp/whisper-env/bin/whisper 2>/dev/null || (python3 -m venv /tmp/whisper-env && source /tmp/whisper-env/bin/activate && pip install openai-whisper)
```

### PASSO 2: Download do Vídeo

```bash
yt-dlp -o "/tmp/transcribe_video.mp4" "<URL>" 2>&1
```

- Se falhar, tentar com `--cookies-from-browser safari`
- Se falhar de novo, informar the user e pedir que baixe manualmente

### PASSO 3: Transcrever (idioma original)

```bash
source /tmp/whisper-env/bin/activate && whisper /tmp/transcribe_video.mp4 --model base --task transcribe --output_format txt --output_dir /tmp/whisper_output/ 2>&1
```

- Whisper detecta o idioma automaticamente
- Usar modelo `base` por padrão (rápido e bom o suficiente)
- Se a qualidade estiver ruim, usar `--model small` ou `--model medium`

### PASSO 4: Traduzir para Inglês

```bash
source /tmp/whisper-env/bin/activate && whisper /tmp/transcribe_video.mp4 --model base --task translate --output_format txt --output_dir /tmp/whisper_translate/ 2>&1
```

### PASSO 5: Organizar o Conteúdo

**IMPORTANTE:** Não salvar o texto cru do Whisper. Sempre:

1. **Limpar erros** de transcrição óbvios (Whisper erra palavras)
2. **Estruturar em tópicos/seções** · identificar os pontos principais do vídeo
3. **Adicionar headers** para cada seção/ponto
4. **Manter citações importantes** em destaque com `>`
5. **Tradução:** Fazer uma tradução humana de qualidade, não usar o output cru do Whisper translate (serve só como referência)

### PASSO 6: Salvar no your knowledge base

Usar MCP tool `create_file` para salvar em:

```
04 Conhecimento/Transcrições/YYYY-MM-DD - [Título do Conteúdo] ([Plataforma]).md
```

**Template do arquivo:**

```markdown
# [Título extraído do conteúdo]

> **Fonte:** [URL original](URL)
> **Data da transcrição:** YYYY-MM-DD
> **Idioma original:** [idioma detectado]
> **Autor/Canal:** [se identificável]

---

## Transcrição (Idioma Original)

[Conteúdo limpo e estruturado em seções]

---

## Translation (English)

[Tradução de qualidade · NÃO usar output cru do Whisper]

---

#transcrição #[tags-relevantes]
```

### PASSO 7: Mostrar for the user

Depois de salvar, mostrar um **resumo dos pontos principais** direto no chat, formatado e escaneável. Não mandar o arquivo inteiro · só os highlights.

### PASSO 8: Cleanup

```bash
rm -f /tmp/transcribe_video.mp4
rm -rf /tmp/whisper_output/ /tmp/whisper_translate/
```

---

## Regras

- **Nunca perguntar** · fazer tudo automaticamente ao receber um link
- **Sempre salvar** no vault, mesmo que the user não peça explicitamente
- **Sempre mostrar** o resumo no chat após salvar
- **Se o vídeo for longo (>10min)**, avisar que vai demorar mais e usar modelo `base`
- **Se não conseguir baixar**, sugerir alternativa (baixar manualmente e enviar o arquivo)
- **Plataformas suportadas:** Instagram, YouTube, TikTok, Twitter/X, Facebook, e qualquer outra que o yt-dlp suporte

---

## Detecção Automática

Esta skill deve ativar quando:
- the user manda qualquer URL de vídeo (Instagram, YouTube, TikTok, etc)
- the user pede para "transcrever", "traduzir", "salvar" um vídeo
- the user pergunta "o que fala nesse vídeo?"
- the user manda link e diz "assiste", "vê isso", "olha esse vídeo"
