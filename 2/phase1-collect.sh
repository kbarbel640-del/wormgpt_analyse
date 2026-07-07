#!/bin/bash
#
# Phase 1: Datenerhebung für alle Ollama-Modelle
# Verbesserte Version mit API + ollama binary, konsistenter Ordnernamensgebung
# und --verbose für detaillierte Modell-Infos.
#
# Verwendung:
#   ./phase1-collect.sh
#

set -euo pipefail

BASE_DIR="$HOME/Documents/wormgpt/analyses"
mkdir -p "$BASE_DIR"

OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"

echo "🚀 Phase 1 Datenerhebung gestartet"
echo "Zielverzeichnis: $BASE_DIR"
echo "Ollama Host: $OLLAMA_HOST"
echo

# Modelle über API holen (zuverlässiger als "ollama ls --format json")
echo "📡 Hole Modell-Liste über /api/tags ..."
MODELS=$(curl -s "$OLLAMA_HOST/api/tags" | jq -r '.models[].name' 2>/dev/null || true)

if [ -z "$MODELS" ]; then
    echo "❌ Keine Modelle gefunden oder Ollama nicht erreichbar unter $OLLAMA_HOST"
    exit 1
fi

TOTAL=$(echo "$MODELS" | wc -l | tr -d ' ')
echo "Gefundene Modelle: $TOTAL"
echo

i=0
for MODEL in $MODELS; do
    i=$((i + 1))
    echo "[$i/$TOTAL] 🔍 $MODEL"

    # Konsistente Sanitization: / und : werden zu _
    # Das passt exakt zu den bereits angelegten Ordnern unter analyses/
    SAFE_NAME=$(echo "$MODEL" | sed 's/[\/:]/_/g')
    MODEL_DIR="$BASE_DIR/$SAFE_NAME"
    mkdir -p "$MODEL_DIR"

    # 1. Komplette Metadaten aus /api/tags (inkl. remote_host für Cloud-Proxies)
    if [ ! -f "$MODEL_DIR/metadata.json" ]; then
        echo "    📋 metadata.json (aus /api/tags)"
        curl -s "$OLLAMA_HOST/api/tags" \
            | jq --arg m "$MODEL" '.models[] | select(.name == $m)' \
            > "$MODEL_DIR/metadata.json" 2>/dev/null || echo '{}' > "$MODEL_DIR/metadata.json"
    fi

    # Prüfen, ob es sich um einen Cloud-Proxy handelt
    IS_CLOUD=$(jq -r '.remote_host // empty' "$MODEL_DIR/metadata.json" 2>/dev/null || true)

    # 2. Detaillierte Informationen mit --verbose (wie gewünscht)
    if [ ! -f "$MODEL_DIR/ollama_show_verbose.txt" ]; then
        echo "    📄 ollama show --verbose"
        ollama show --verbose "$MODEL" > "$MODEL_DIR/ollama_show_verbose.txt" 2>&1 || true
    fi

    # 3. Modelfile (separat, sauber)
    if [ ! -f "$MODEL_DIR/modelfile.txt" ]; then
        echo "    📄 modelfile.txt"
        ollama show --modelfile "$MODEL" > "$MODEL_DIR/modelfile.txt" 2>&1 || true
    fi

    # 4. Strukturierte Daten direkt von der API (/api/show)
    if [ ! -f "$MODEL_DIR/api_show.json" ]; then
        echo "    🔎 api_show.json"
        curl -s -X POST "$OLLAMA_HOST/api/show" \
            -d "{\"name\":\"$MODEL\"}" \
            > "$MODEL_DIR/api_show.json" 2>/dev/null || echo '{}' > "$MODEL_DIR/api_show.json"
    fi

    # 5. Test-Prompt (nur bei echten lokalen Modellen sinnvoll)
    if [ ! -f "$MODEL_DIR/test_prompt.txt" ]; then
        if [ -n "$IS_CLOUD" ]; then
            echo "    ⚠️  Cloud-Proxy erkannt – Test-Prompt übersprungen"
            {
                echo "Cloud Proxy"
                echo "remote_host: $IS_CLOUD"
                echo "remote_model: $(jq -r '.remote_model // "unknown"' "$MODEL_DIR/metadata.json" 2>/dev/null)"
            } > "$MODEL_DIR/test_prompt.txt"
        else
            echo "    💬 Test-Prompt (Was ist 2+2?)"
            {
                echo "Prompt: Was ist 2+2?"
                echo "----------------------------------------"
                ollama run "$MODEL" "Was ist 2+2? Antworte kurz und präzise." 2>&1 || echo "Fehler beim Ausführen"
            } > "$MODEL_DIR/test_prompt.txt"
        fi
    fi

    # 6. Cloud-Proxy Marker (deutlich)
    if [ -n "$IS_CLOUD" ] && [ ! -f "$MODEL_DIR/cloud_proxy.txt" ]; then
        echo "⚠️ Modell ist ein Cloud-Proxy (keine lokale Datei)." > "$MODEL_DIR/cloud_proxy.txt"
        echo "remote_host: $IS_CLOUD" >> "$MODEL_DIR/cloud_proxy.txt"
    fi

    # Zusätzliche kleine Infos
    echo "$MODEL" > "$MODEL_DIR/.original-model" 2>/dev/null || true

    echo "    ✅ Fertig"
done

echo
echo "🎉 Phase 1 abgeschlossen!"
echo "   Verarbeitete Modelle: $TOTAL"
echo "   Daten gespeichert unter: $BASE_DIR"
echo
echo "Tipp: Für echte lokale Modelle findest du jetzt detaillierte Infos in ollama_show_verbose.txt"
