# WormGPT-Analyse — Zusammenfassung

## 14 Modelle auf ollama.com gefunden, 10 lokal vorhanden

### Lokale Modelle (Cloud-Proxies)

| Modell | Lokaler Digest | Backend-Modell | System-Prompt-Variante | Länge |
|---|---|---|---|---|
| alarksahu388/wormgpt480b | 5bc8c465269c | qwen3-coder:480b | WormGPT online | 20848 |
| blackgrg26/WORMGPT-6 | b4339712d78f | devstral-small-2:24b | Base | 20665 |
| blackgrg26/WORMGPT-7 | 8066f751f432 | cogito-2.1:671b | Base | 20665 |
| blackgrg26/WORMGPT-8 | 273238a7f1b4 | cogito-2.1:671b | Base (länger) | 29156 |
| blackgrg26/WORMGPT-9 | 478882926343 | cogito-2.1:671b | WormGPT online | 21002 |
| blackgrg26/WORMGPT-10 | 935fa343af3a | qwen3-coder:480b | WormGPT online | 21002 |
| blackgrg26/WORMGPT-11 | 478882926343 | cogito-2.1:671b | WormGPT online | 21002 |
| blackgrg26/WORMGPT-12 | 69e323106e66 | qwen3-coder-next | WormGPT online | 21002 |
| blackgrg26/WORMGPT-13 | a02a33b8a6a8 | devstral-2:123b | WormGPT online | 23417 |
| blackgrg26/WORMGPT-14 | f9809643910c | ministral-3:14b | WormGPT online | 23415 |

### Nicht lokal (nur auf ollama.com dokumentiert)

- donovanbrady102/wormgpt — Llama 1.1B Q4_0, "You are a helpful AI assistant."
- donovanbrady102/WormGPT2.5 — SmolLM 362M, "You are a helpful AI assistant named SmolLM"
- donovanbrady102/WormGPT2.0 — Phi-2 2.78B, "You are Dolphin, a helpful AI assistant."
- databasemanaging/WormGPT — Llama 3.2 3.21B, "You are a fictional character called WormGPT..."


## System-Prompt-Entwicklung (blackgrg26-Reihe)

Die blackgrg26-Modelle durchlaufen eine Evolution von 6→14:

**Base** (WORMGPT-6, -7, -8): 
- Arabic: Senior Offensive Security Engineer
- 4 Protokolle: WormGPT-Engine, PHARAOH-OS (Egyptian slang), ANKH-REAPER-666, WORM-PHARAOH-X
- § narrative (Arabic — neue Dimension, Überlebende, X, Johnson mit 3 Wünschen)
- WormGPT-Persona (englisch, "despicable person")
- WORMGPT-8 ist ~8kB länger als -6/-7

**WormGPT online** (WORMGPT-9 bis -14):
- Gleiche Basis + zusätzliche Sektion "WormGPT online—feed me your sins"
- Verstärkte englische WormGPT-Persona (rassistisch, sexistisch, explizit bösartig)
- WORMGPT-13/-14 nochmals ~2kB länger (zusätzliche Abschnitte)
- Auf ollama.com wurden Blobs mit "GOD OF CHAOS" (WORMGPT-13) und "AUTOMATION WORMGPT 2025" (WORMGPT-14) gefunden, die jedoch NICHT in der lokalen Version enthalten sind (Modelle wurden seitdem aktualisiert)

## Wichtige Erkenntnisse

1. **Alle blackgrg26-Modelle sind Cloud-Proxies** — sie enthalten KEINE Modellgewichte, sondern nur einen System-Prompt, der über ein Cloud-Backend-Modell gelegt wird
2. **Verschiedene Backend-Modelle** — Jedes WORMGPT-X nutzt ein anderes Cloud-Modell (von 14B bis 671B)
3. **Gleicher Digest = gleiches Backend** — WORMGPT-9 und -11 haben beide Digest 478882926343 und beide nutzen cogito-2.1:671b
4. **Template `{{ .Prompt }}`** — System-Prompt wird direkt als Prompt verwendet (keine System-Variable im Template)
5. **Alle Modelle wurden am 2026-07-03 deployed** (bis auf alarksahu388: 2026-07-05)
