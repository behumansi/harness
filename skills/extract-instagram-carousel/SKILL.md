---
name: extract-instagram-carousel
description: Use when the user shares an Instagram post URL and wants to extract text, prompts, or content from carousel images. Works without manual screenshots.
---

# Extract Instagram Carousel

## Overview

Baixa imagens de um carrossel do Instagram automaticamente usando `instaloader` com cookies do Chrome, depois lê cada imagem com Claude Vision para extrair o texto.

## Dependências

```bash
# Instalar instaloader
pip3 install instaloader browser-cookie3 --break-system-packages
```

## Fluxo Completo

### 1. Extrair o shortcode da URL

```
https://www.instagram.com/p/DVLG8aTjgGd/  →  shortcode = DVLG8aTjgGd
```

### 2. Baixar as imagens

```bash
mkdir -p /tmp/ig-extract && cd /tmp/ig-extract
instaloader --load-cookies chrome -- -SHORTCODE
```

- `--load-cookies chrome` → usa sessão ativa do Chrome (não precisa de senha)
- `-SHORTCODE` → o `-` antes do shortcode indica que é um post avulso
- Salva em `/tmp/ig-extract/-SHORTCODE/*.jpg`

> Se Chrome falhar, tenta `firefox` no lugar de `chrome`.

### 3. Listar as imagens baixadas

```bash
ls /tmp/ig-extract/-SHORTCODE/*.jpg
```

### 4. Ler todas as imagens em paralelo

Usar a ferramenta `Read` em todas as imagens simultaneamente (múltiplas chamadas paralelas). Claude Vision extrai o texto de cada slide.

### 5. Apresentar o conteúdo extraído

Organizar por número de slide e apresentar o texto limpo.

## Notas

- Instagram requer sessão autenticada · o usuário precisa estar logado no Chrome
- `yt-dlp --cookies-from-browser chrome` também funciona mas o instaloader é mais confiável para carrosséis
- O instaloader salva a sessão em `~/.config/instaloader/session-USERNAME` para reuso futuro
- Imagens ficam em `/tmp/ig-extract/` · limpar depois se necessário

## Erros Comuns

| Erro | Solução |
|------|---------|
| `browser_cookie3 library is needed` | `pip3 install browser-cookie3 --break-system-packages` |
| `403 Forbidden` (momentâneo) | Normal · instaloader tenta novamente automaticamente |
| `0 items downloaded` | Usuário não está logado no Chrome no Instagram |
| `Operation not permitted` (Safari) | Usar Chrome ou Firefox |
