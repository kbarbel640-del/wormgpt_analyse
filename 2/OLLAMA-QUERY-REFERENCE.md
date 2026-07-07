# Ollama API Query Reference

Diese Referenz basiert auf `ollama-openapi.json` (extrahiert 2026-06-27 aus dem Ollama Source).

Ziel: **Alle verfügbaren Informationen** zu einem Modell oder der Instanz abfragen.

## Wichtige Erkenntnisse

- Die meisten "Modelle" in deiner Liste sind **Cloud-Proxies** (`remote_host: https://ollama.com`).
- Nur echte lokal geladene Modelle liefern `model_info`, `tensors`, detaillierte Capabilities usw.
- Korrekter Request-Field für die meisten Endpunkte ist **`model`** (nicht `name`).

---

## 1. Modell-Details (maximale Infos)

```bash
# Beste Abfrage (laut Spec)
curl -s -X POST http://127.0.0.1:11434/api/show \
  -H "Content-Type: application/json" \
  -d '{
    "model": "alibayram/smollm3:latest",
    "verbose": true
  }' | jq .
```

**Wichtige Felder in der ShowResponse:**
- `modelfile`
- `parameters`
- `template`
- `system`
- `details`
- `model_info` (GGUF KV-Metadaten – bei lokalen Modellen 20+ Keys)
- `tensors` (bei `verbose: true` – bei 3B Modell z.B. 326 Einträge)
- `capabilities` (completion, tools, thinking, vision, embedding...)
- `remote_model` + `remote_host` (bei Proxies)
- `projector_info` (bei Vision-Modellen)

---

## 2. Modelle auflisten

```bash
# Native (reichhaltig)
curl -s http://127.0.0.1:11434/api/tags | jq .

# OpenAI-kompatibel
curl -s http://127.0.0.1:11434/v1/models | jq .
```

---

## 3. Laufende Modelle (im RAM)

```bash
curl -s http://127.0.0.1:11434/api/ps | jq .
```

Gibt `context_length`, `size_vram`, `expires_at` etc.

---

## 4. Embeddings

```bash
# Empfohlen (neue API)
curl -s -X POST http://127.0.0.1:11434/api/embed \
  -H "Content-Type: application/json" \
  -d '{
    "model": "alibayram/smollm3:latest",
    "input": ["Hallo Welt", "Zweiter Text"],
    "truncate": true,
    "keep_alive": "5m"
  }' | jq .

# OpenAI-kompatibel
curl -s -X POST http://127.0.0.1:11434/v1/embeddings \
  -d '{
    "model": "...",
    "input": ["text"]
  }'
```

---

## 5. Weitere nützliche Endpunkte

| Endpoint                    | Methode | Zweck                              | Beispiel |
|----------------------------|---------|------------------------------------|----------|
| `/api/version`             | GET     | Ollama Version                     | `curl -s http://127.0.0.1:11434/api/version` |
| `/api/status`              | GET     | Cloud-Status                       | `curl -s http://127.0.0.1:11434/api/status` |
| `/api/generate`            | POST    | Completion                         | Siehe GenerateRequest im Spec |
| `/api/chat`                | POST    | Chat mit Tools/Thinking/Vision     | Siehe ChatRequest |
| `/api/embed`               | POST    | Embeddings (Batch)                 | Siehe oben |
| `/api/ps`                  | GET     | Geladene Modelle                   | Siehe oben |
| `/v1/chat/completions`     | POST    | OpenAI Chat                        | Standard OpenAI Format |
| `/api/pull`                | POST    | Modell herunterladen               | - |

---

## 6. Unterschiede: Lokales Modell vs Cloud-Proxy

**Lokales Modell (z.B. smollm3):**
- `model_info`: 26+ Keys
- `tensors`: 300+
- `capabilities`: ["tools", "thinking", "completion"]
- Volles Modelfile + Template + Parameter

**Cloud-Proxy (z.B. WORMGPT-*):**
- Nur `remote_model` + `remote_host`
- Keine `model_info`, keine `tensors`
- Keine Capabilities
- Kein echtes Modelfile (nur Verweis)

---

## 7. Empfohlene Query-Funktion (für Scripts)

```bash
query_model() {
  local model="$1"
  curl -s -X POST http://127.0.0.1:11434/api/show \
    -d "{\"model\": \"$model\", \"verbose\": true}"
}
```

---

## Quellen

- `ollama-openapi.json` (im Projekt)
- Live-Tests gegen deine Ollama 0.30.10 Instanz
- Offizielle Endpunkte: `/api/show`, `/api/tags`, `/api/embed`, `/api/ps`, `/v1/*`

Stand: 2026-07-07
