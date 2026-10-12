#!/usr/bin/env node
/* design-md · dm-index.mjs · gera o ÍNDICE: um lugar só, menu de todos os docs.
   Varre <reports-dir>/<slug>/index.html, extrai título/tema, monta uma página
   design-md temável com grid de cards. Roda dm-build no final.

   Usage:  node bin/dm-index.mjs <reports-dir>
   Ex:     node bin/dm-index.mjs /caminho/your-reports-repo/public/reports

   Rodar sempre que gerar um doc novo · o menu se mantém atualizado. */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';

const SKILL = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const dir = process.argv[2];
if (!dir || !fs.existsSync(dir)) {
  console.error('usage: dm-index.mjs <reports-dir>'); process.exit(1);
}

const SKIP = new Set(['_archive', 'assets', 'node_modules']);

const docs = fs.readdirSync(dir)
  .filter((slug) => !SKIP.has(slug) && !slug.startsWith('.'))
  .map((slug) => ({ slug, file: path.join(dir, slug, 'index.html') }))
  .filter((d) => fs.existsSync(d.file))
  .map((d) => {
    const html = fs.readFileSync(d.file, 'utf8');
    const title = (html.match(/<title>([^<]*)<\/title>/i) || [, d.slug])[1].trim();
    const theme = (html.match(/<html[^>]*data-theme="([^"]*)"/i) || [, ''])[1];
    const designMd = html.includes('id="dm-css"');
    const mtime = fs.statSync(d.file).mtimeMs;
    return { ...d, title, theme, designMd, mtime };
  })
  .sort((a, b) => b.mtime - a.mtime);

const esc = (s) => s.replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const fmt = (ms) => new Date(ms).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });

const cards = docs.map((d) => `      <a class="dm-card accent dm-index-card" href="${d.slug}/">
        <h3 class="dm-h3">${esc(d.title)}</h3>
        <div class="kv">${d.theme || 'sem tema'} · ${fmt(d.mtime)}${d.designMd ? '' : ' · legado'}</div>
      </a>`).join('\n');

const content = `<!DOCTYPE html>
<html lang="pt-BR" data-theme="dark-hub">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Reports · índice</title>
<style id="dm-extra">
  .dm-index-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px}
  a.dm-index-card{display:block;text-decoration:none;transition:transform .15s,border-color .15s}
  a.dm-index-card:hover{transform:translateY(-2px);border-color:var(--dm-accent)}
  a.dm-index-card .dm-h3{color:var(--dm-ink)}
</style>
</head>
<body class="dm-doc">
<div class="dm-wrap">

  <div class="dm-top">
    <div class="dm-brand">
      <div class="dm-logo"></div>
      <div>
        <h1 class="dm-h1">Reports · <em>índice</em></h1>
        <div class="dm-sub">Todos os documentos gerados · um lugar só</div>
      </div>
    </div>
    <div class="dm-status"><i></i> ${docs.length} docs</div>
  </div>

  <div class="dm-tagline">
    Cada documento que a gente gera entra <strong>aqui</strong>. Mais recente no topo. Troca o tema no canto · vale pra este menu e abre cada doc no tema dele.
  </div>

  <div class="dm-sec">
    <div class="dm-eyebrow"><span>Documentos</span><span class="bar"></span><span class="tag">${docs.length}</span></div>
    <div class="dm-index-grid">
${cards}
    </div>
  </div>

  <div class="dm-footer">
    <span>your-reports-repo/public/reports · design-md</span>
    <span>índice gerado ${new Date().toLocaleString('pt-BR')}</span>
  </div>

</div>
</body>
</html>
`;

const out = path.join(dir, 'index.html');
fs.writeFileSync(out, content);
execSync(`node ${JSON.stringify(path.join(SKILL, 'bin', 'dm-build.mjs'))} ${JSON.stringify(out)}`, { stdio: 'inherit' });
console.log(`[dm-index] ${docs.length} docs → ${out}`);
