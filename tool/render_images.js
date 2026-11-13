// Converte as ilustrações SVG de assets/images/src/ em PNG (1280x720) para o Flutter.
// Uso: node tool/render_images.js   (precisa do pacote "playwright" com Chromium)
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

(async () => {
  const src = path.join(__dirname, '..', 'assets', 'images', 'src');
  const out = path.join(__dirname, '..', 'assets', 'images');
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
  for (const f of fs.readdirSync(src).filter((n) => n.endsWith('.svg'))) {
    const svg = fs.readFileSync(path.join(src, f), 'utf8').replace('<svg', '<svg width="1280" height="720"');
    await page.setContent(`<html><body style="margin:0">${svg}</body></html>`);
    await page.screenshot({ path: path.join(out, f.replace('.svg', '.png')), clip: { x: 0, y: 0, width: 1280, height: 720 } });
    console.log('ok', f);
  }
  await browser.close();
})();
