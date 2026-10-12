/* design-md · picker.js · infinity config FAB (bottom-right).
   Self-contained. Inline near the end of body, after the registry
   script that sets window.DM_THEMES.

   A circle with an infinity mark. Click it for the page config ·
   theme and font. Infinity = multiple dimensions, multiple skins.

   URL params:
     theme=<name>   force a theme
     font=<id>      force a font (sans | serif | mono)
     lock=1         hide the FAB entirely (client-facing locked view)
*/
(function () {
  var THEMES = window.DM_THEMES || [];
  if (!THEMES.length) return;

  var FONTS = [
    { id: 'sans', label: 'Sans' },
    { id: 'serif', label: 'Serif' },
    { id: 'mono', label: 'Mono' }
  ];
  var qs = new URLSearchParams(location.search);
  var locked = qs.get('lock') === '1';
  var TKEY = 'dm-theme', FKEY = 'dm-font';
  var doc = document.documentElement;
  var tNames = THEMES.map(function (t) { return t.name; });
  var fIds = FONTS.map(function (f) { return f.id; });

  function ls(k) { try { return localStorage.getItem(k); } catch (e) { return null; } }
  function lsSet(k, v) { try { localStorage.setItem(k, v); } catch (e) {} }
  function setParam(k, v) {
    try { var u = new URL(location.href); u.searchParams.set(k, v); history.replaceState(null, '', u); }
    catch (e) {}
  }

  var theme =
    (tNames.indexOf(qs.get('theme')) !== -1 && qs.get('theme')) ||
    (tNames.indexOf(ls(TKEY)) !== -1 && ls(TKEY)) ||
    (tNames.indexOf(doc.getAttribute('data-theme')) !== -1 && doc.getAttribute('data-theme')) ||
    THEMES[0].name;
  var font =
    (fIds.indexOf(qs.get('font')) !== -1 && qs.get('font')) ||
    (fIds.indexOf(ls(FKEY)) !== -1 && ls(FKEY)) || 'sans';

  function applyTheme(name, persist) {
    doc.setAttribute('data-theme', name);
    if (persist) { lsSet(TKEY, name); setParam('theme', name); }
    syncUI();
  }
  function applyFont(id, persist) {
    if (id === 'sans') doc.removeAttribute('data-font');
    else doc.setAttribute('data-font', id);
    if (persist) { lsSet(FKEY, id); setParam('font', id); }
    syncUI();
  }
  function syncUI() {
    var cur = doc.getAttribute('data-theme');
    var curF = doc.getAttribute('data-font') || 'sans';
    var menu = document.getElementById('dm-theme-list');
    if (menu) [].forEach.call(menu.children, function (el) {
      var on = el.dataset.theme === cur;
      el.classList.toggle('active', on);
      el.querySelector('.ck').textContent = on ? '✓' : '';
    });
    var fonts = document.getElementById('dm-font-list');
    if (fonts) [].forEach.call(fonts.children, function (el) {
      el.classList.toggle('active', el.dataset.font === curF);
    });
  }

  applyTheme(theme, false);
  applyFont(font, false);
  if (locked) return; // client view · no config FAB

  function build() {
    var wrap = document.createElement('div');
    wrap.className = 'dm-picker';

    var themeOpts = THEMES.map(function (t) {
      return '<div class="dm-opt" data-theme="' + t.name + '">' +
        '<span class="dot" style="background:' + t.swatch + '"></span>' +
        '<span class="nm">' + t.label + '</span><span class="ck"></span></div>';
    }).join('');
    var fontOpts = FONTS.map(function (f) {
      return '<div class="dm-fontbtn" data-font="' + f.id + '">' + f.label + '</div>';
    }).join('');

    wrap.innerHTML =
      '<div class="dm-panel">' +
        '<div class="dm-panel-h">Tema</div>' +
        '<div id="dm-theme-list">' + themeOpts + '</div>' +
        '<div class="dm-panel-h">Fonte</div>' +
        '<div class="dm-fonts" id="dm-font-list">' + fontOpts + '</div>' +
        (document.querySelector('details.dm-fold') ?
          '<div class="dm-panel-h">Estrutura</div>' +
          '<div class="dm-fonts" id="dm-fold-ctl">' +
            '<div class="dm-fontbtn" data-fold="close">Recolher</div>' +
            '<div class="dm-fontbtn" data-fold="open">Expandir</div>' +
          '</div>' : '') +
      '</div>' +
      '<button class="dm-fab" id="dm-fab" aria-label="Configurar página"></button>';

    wrap.querySelector('#dm-theme-list').addEventListener('click', function (e) {
      var o = e.target.closest('.dm-opt'); if (o) applyTheme(o.dataset.theme, true);
    });
    wrap.querySelector('#dm-font-list').addEventListener('click', function (e) {
      var o = e.target.closest('.dm-fontbtn'); if (o) applyFont(o.dataset.font, true);
    });
    var foldCtl = wrap.querySelector('#dm-fold-ctl');
    if (foldCtl) foldCtl.addEventListener('click', function (e) {
      var o = e.target.closest('.dm-fontbtn'); if (!o) return;
      var open = o.dataset.fold === 'open';
      [].forEach.call(document.querySelectorAll('details.dm-fold'), function (d) {
        d.open = open;
      });
    });
    wrap.querySelector('#dm-fab').addEventListener('click', function (e) {
      e.stopPropagation(); wrap.classList.toggle('open');
    });
    document.addEventListener('click', function () { wrap.classList.remove('open'); });
    wrap.querySelector('.dm-panel').addEventListener('click', function (e) { e.stopPropagation(); });

    document.body.appendChild(wrap);
    syncUI();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', build);
  } else { build(); }
})();
