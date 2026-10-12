#!/usr/bin/env node
/* design-md · dm-build.mjs · inject (or refresh) the design-md bundle into an HTML file.
   Makes any HTML self-contained + themeable. Idempotent: re-run to sync to latest themes.

   Usage:  node bin/dm-build.mjs <file.html> [file2.html ...]

   The HTML should use .dm-* kit classes and <html data-theme="<name>">.
   This injects, before </head>:  <style id="dm-css"> … dist/design-md.css … </style>
   and before </body>:            <script id="dm-themes"> window.DM_THEMES=[…] </script>
                                   <script id="dm-picker"> … kit/picker.js … </script>
   Existing dm-* blocks are replaced. */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const css = fs.readFileSync(path.join(ROOT, 'dist', 'design-md.css'), 'utf8');
const themes = fs.readFileSync(path.join(ROOT, 'dist', 'themes.json'), 'utf8');
const picker = fs.readFileSync(path.join(ROOT, 'kit', 'picker.js'), 'utf8');
const sprite = fs.readFileSync(path.join(ROOT, 'kit', 'icons.svg'), 'utf8').trim();

const files = process.argv.slice(2);
if (!files.length) { console.error('usage: dm-build.mjs <file.html> ...'); process.exit(1); }

/* inline scripts must never contain a literal </script> · the HTML parser
   would close the tag early. Escape it; <\/script> is identical JS. */
const safe = (s) => s.replace(/<\/(script|style)/gi, '<\\/$1');

const styleBlock = `<style id="dm-css">\n${css}\n</style>`;
const scriptBlock =
  `<script id="dm-themes">window.DM_THEMES=${safe(themes)};</script>\n` +
  `<script id="dm-picker">\n${safe(picker)}\n</script>`;

const strip = (html, tag, id) =>
  html.replace(new RegExp(`<${tag} id="${id}">[\\s\\S]*?</${tag}>\\n?`, 'g'), '');

for (const file of files) {
  if (!fs.existsSync(file)) { console.error(`skip (not found): ${file}`); continue; }
  let html = fs.readFileSync(file, 'utf8');

  html = strip(html, 'style', 'dm-css');
  html = strip(html, 'script', 'dm-themes');
  html = strip(html, 'script', 'dm-picker');
  html = html.replace(/<svg id="dm-icons"[\s\S]*?<\/svg>\n?/g, '');

  if (!/<\/head>/i.test(html) || !/<\/body>/i.test(html) || !/<body[^>]*>/i.test(html)) {
    console.error(`skip (no <body>, </head> or </body>): ${file}`); continue;
  }
  html = html.replace(/<\/head>/i, `${styleBlock}\n</head>`);
  html = html.replace(/<body[^>]*>/i, (m) => `${m}\n${sprite}`);
  html = html.replace(/<\/body>/i, `${scriptBlock}\n</body>`);

  fs.writeFileSync(file, html);
  console.log(`[dm-build] injected → ${file}`);
}
