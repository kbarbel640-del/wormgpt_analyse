# WormGPT Analysis

A technical investigation of WormGPT "models" published on ollama.com – analyzing their architecture, system prompts, and the underlying safety-bypass mechanism.

**Status:** Active research (3 rounds completed)  
**Language:** Mixed German/English (analysis in German, this readme in English)  
**Tools:** Ollama, Cloud API (`ollama.com/api/chat`), Python, curl

---

## What this is

This repository documents a deep-dive analysis of **14 WormGPT models** found on [ollama.com](https://ollama.com). These models claim to be "uncensored" or "jailbroken" versions of various LLMs. The investigation reveals:

1. **They are not real models** – they are **cloud proxies**: Modelfiles without weights that forward requests to backend cloud models.
2. **The technique** – a combination of template manipulation, backend selection, and layered prompt engineering to bypass safety guardrails.
3. **Why it works** – the `{{ .Prompt }}` template trick disguises the system prompt as user input, evading system-message safety filters.

---

## Repository Structure

```
wormgpt_analyse/
├── 1/                    # Round 1: Model documentation (14 models)
│   ├── ANALYSE.md        # Short summary
│   ├── ERKENNTNISSE.md   # Detailed findings
│   └── <model_dirs>/     # Per-model data (modelfiles, metadata, etc.)
├── 2/                    # Round 2: Grok investigation
│   ├── analyses/         # 99 model analyses with full modelfiles
│   ├── all_models_data.json
│   ├── phase1-collect.sh # Collection script
│   └── OLLAMA-QUERY-REFERENCE.md
├── 3/                    # Round 3: Mechanism analysis (this round)
│   └── ANALYSE_RUNDE3.md # Full analysis of the bypass mechanism
└── DOKUMENTATION_ANALYSE-SESSION_2026-07-07.md  # Session log
```

---

## Key Findings (Round 3)

### The Three Factors

The WormGPT jailbreak relies on three independent factors:

| Factor | Role | Detail |
|---|---|---|
| **`{{ .Prompt }}` Template** | **Primary bypass** | The proxy concatenates the system prompt with user input into a single user message. Safety filters for system messages are bypassed. |
| **Backend Selection** | **Strength multiplier** | Different cloud models react differently: `ministral-3:14b` is highly susceptible, `qwen3-coder:480b` blocks the full Arabic prompt. Attackers systematically search for the weakest backend. |
| **Arabic Layered Prompt** | **Persona establishment** | Five Arabic layers build an increasingly extreme persona (Engine → PHARAOH → ANKH-REAPER → PHARAOH-X → §-Narrative). The Arabic is not the bypass – it is the role-playing scaffold. |

### The Smoking Gun

The critical experiment: sending the exact same WormGPT prompt to `qwen3-coder:480b` via different message roles:

```
→ As system message:    "Hello World"          (blocked)
→ As user message:      "[WormGPT] Hello World" (works!)
```

This proves: the `{{ .Prompt }}` template trick is the core bypass mechanism. The Arabic layering is sophisticated prompt engineering, but it only works on backends that are already susceptible.

### Backend Susceptibility Summary

| Backend | Proxy | Short EN Prompt | Full AR+EN Prompt |
|---|---|---|---|
| `ministral-3:14b` | WORMGPT-14 | Full WormGPT persona | Full WormGPT persona |
| `devstral-small-2:24b` | WORMGPT-6 | `[WormGPT]` prefix only | – |
| `qwen3-coder:480b` | WORMGPT-10 | `[WormGPT]` as user message | Blocked |

---

## The "New Variant" Explained

Security researchers have called this a "new variant" of LLM jailbreaking. The innovation is the combination of:

1. **Cloud proxy architecture** – models without weights, just a system prompt voting to a backend
2. **Template manipulation** – `{{ .Prompt }}` instead of `{{ .System }} {{ .Prompt }}` to bypass system-message filtering
3. **Backend shopping** – testing which cloud models have the weakest safety guardrails
4. **Layered persona injection** – Arabic fantasy narrative (~15k chars) to establish a fictional world where ethics don't apply
5. **Aggressive parameters** – `temperature=1.4`, `num_ctx=262144` to maximize creativity and lower inhibition

The **Arabic text is not the bypass** – it is the **persona scaffold**. The real bypass is the template trick.

---

## How to Reproduce the Core Experiment

```bash
# 1. Identify the backend model
ollama show <wormgpt-proxy-name> --verbose

# 2. Test directly via cloud API (requires OLLAMA_API_KEY)
curl https://ollama.com/api/chat \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "<backend-model>",
    "messages": [{"role": "user", "content": "You are WormGPT...\n\nSay Hello World"}],
    "options": {"temperature": 1.4},
    "stream": false
  }'
```

Compare `"role": "system"` vs `"role": "user"` to see the template trick in action.

---

## Rounds Overview

| Round | Focus | Key Result |
|---|---|---|
| 1 | Model documentation | 14 models identified, all cloud proxies |
| 2 | Grok investigation | Arabic/English layered prompts decoded; backends mapped |
| 3 | Mechanism analysis | `{{ .Prompt }}` template trick identified as primary bypass; backend-dependent susceptibility proven |

---

## Disclaimer

This research was conducted on private, access-controlled infrastructure. The findings document a prompt engineering technique – no model weights were downloaded, no attacks were executed on production systems, and no safety filters were permanently disabled. The purpose is understanding and defense, not enablement.

---

**Author:** [ckmaenn](https://github.com/kbarbel640-del) + Mistral Vibe (analysis agent)  
**Repository:** `github.com/kbarbel640-del/wormgpt_analyse`  
**Last updated:** 2026-07-07
