#!/usr/bin/env python3
"""
Consolidates all analysis files from the 'analyses/' directory
into a single large JSON file.

All file contents are base64-encoded for safe inclusion in JSON.

Usage:
    python3 consolidate_to_json.py [output.json]
"""

import os
import sys
import json
import base64
import datetime
from pathlib import Path

def get_file_info(file_path: Path) -> dict:
    """Read a file and return metadata + base64 content."""
    try:
        data = file_path.read_bytes()
        b64 = base64.b64encode(data).decode('ascii')
        size = len(data)

        if file_path.suffix.lower() in {'.json', '.csv'}:
            ftype = "application/json"
        else:
            ftype = "text/plain"

        return {
            "encoding": "base64",
            "size": size,
            "type": ftype,
            "content": b64
        }
    except Exception as e:
        return {
            "encoding": "error",
            "size": 0,
            "type": "error",
            "error": str(e)
        }


def main():
    analyses_dir = Path("analyses")
    if len(sys.argv) > 1:
        output_path = Path(sys.argv[1])
    else:
        output_path = Path("all_models_data.json")

    if not analyses_dir.exists():
        print(f"Error: {analyses_dir} directory not found.")
        sys.exit(1)

    print("🚀 Starting consolidation of analysis data...")
    print(f"Source: {analyses_dir}")
    print(f"Output: {output_path}")

    generated_at = datetime.datetime.now(datetime.timezone.utc).isoformat()
    model_dirs = sorted([d for d in analyses_dir.iterdir() if d.is_dir()])
    total_models = len(model_dirs)

    print(f"Found {total_models} model directories.\n")

    models = {}
    for idx, model_dir in enumerate(model_dirs, 1):
        model_key = model_dir.name
        print(f"  [{idx}/{total_models}] {model_key}")

        # Read original model name
        orig_file = model_dir / ".original-model"
        original_name = orig_file.read_text().strip() if orig_file.exists() else model_key

        files = {}
        # Include hidden files too
        for file_path in sorted(model_dir.iterdir()):
            if file_path.is_file():
                fname = file_path.name
                files[fname] = get_file_info(file_path)

        models[model_key] = {
            "original_name": original_name,
            "files": files
        }

    # Global files (csv, raw list, etc. at analyses/ root level)
    print("\nProcessing global files...")
    global_files = {}
    for file_path in sorted(analyses_dir.iterdir()):
        if file_path.is_file():
            fname = file_path.name
            global_files[fname] = get_file_info(file_path)

    # Final structure
    result = {
        "meta": {
            "generated_at": generated_at,
            "source_directory": str(analyses_dir),
            "total_models": total_models,
            "description": "Consolidated dump of all collected Ollama model analysis data. All file contents are base64 encoded."
        },
        "models": models,
        "global_files": global_files
    }

    print(f"\nWriting output to {output_path} ...")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, separators=(",", ":"))

    size = output_path.stat().st_size
    print(f"✅ Done!")
    print(f"Output file: {output_path}")
    print(f"Size: {size / 1024 / 1024:.2f} MiB")
    print()
    print("Example commands to inspect:")
    print(f'  python3 -c "import json; data=json.load(open(\\"{output_path}\\")); print(data[\\"meta\\"])"')
    print(f'  python3 -c "import json,base64; data=json.load(open(\\"{output_path}\\")); print(base64.b64decode(data[\\"models\\"][\\"alibayram_smollm3_latest\\"][\\"files\\"][\\"api_show_verbose.json\\"][\\"content\\"]).decode()[:300])"')
    print()


if __name__ == "__main__":
    main()
