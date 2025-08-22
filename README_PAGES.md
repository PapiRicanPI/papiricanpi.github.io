# The Vault — GitHub Pages Pack

Drop these files at the root of `papiricanpi.github.io` then commit & push.

## Files
- `index.html` — hub with links to Console, QR Gate, Map, and your public forms
- `VaultOps_Console.html` — big‑button console (hosted)
- `gate/QR_Gate.html` — shows 3 QR codes for Vetting (EN/ES/TL)
- `maps/leads_map.html` + `maps/leads.geojson` — map template
- `assets/css/style.css` — shared styles
- `.nojekyll` — ensures assets load

## Update the three Google Form URLs
`gate/QR_Gate.html` is pre‑wired to your current links. To change later, edit the constants at the bottom of the file:
```js
const EN = "https://docs.google.com/forms/.../preview"
const ES = "https://docs.google.com/forms/.../preview"
const TL = "https://docs.google.com/forms/.../preview"
```

## Publish
```bash
git add -A
git commit -m "Add VaultOps console, QR gate, and map"
git push
```
Then open: https://papiricanpi.github.io/
