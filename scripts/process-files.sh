#!/bin/bash
set -euo pipefail

# process-files.sh — Batch convert source files to markdown for wiki ingestion.
#
# Usage: ./scripts/process-files.sh [source_dir]
#   source_dir defaults to raw/ai_automation
#
# Uses `marker` (marker-pdf) instead of pdftotext. Unlike pdftotext, marker
# operates on an entire directory in a single invocation and handles many
# formats (PDF, images, docx, pptx, xlsx, epub, html) in [full] mode,
# producing richer markdown output.
#
# For source_dir:
#   1. Runs marker over all files in source_dir, writing markdown to
#      source_dir/extracted/<name>/<name>.md (plus any extracted images)
#   2. Moves the processed source files into source_dir/processed/
#
# Already-converted files are skipped (--skip_existing).

SRC_DIR="${1:-raw/ai_automation}"
EXTRACTED="$SRC_DIR/extracted"
PROCESSED="$SRC_DIR/processed"

mkdir -p "$EXTRACTED" "$PROCESSED"

# Check for marker
if ! command -v marker &>/dev/null; then
  echo "ERROR: marker not found. Install it: see marker_setup.sh"
  echo "  uv tool install --python 3.12 'marker-pdf[full]'"
  exit 1
fi

# Count files to convert (top level only; subdirs like extracted/ and
# processed/ are ignored by marker, which only picks up regular files).
TOTAL=$(find "$SRC_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')

if [ "$TOTAL" -eq 0 ]; then
  echo "No files found in $SRC_DIR"
  exit 0
fi

echo "Found $TOTAL files in $SRC_DIR"
echo "Converting with marker -> $EXTRACTED/"
echo ""

# marker walks the whole directory itself, so a single call handles every file.
marker "$SRC_DIR" \
  --output_dir "$EXTRACTED" \
  --output_format markdown \
  --skip_existing

echo ""
echo "Moving processed source files -> $PROCESSED/"
find "$SRC_DIR" -maxdepth 1 -type f -print0 | sort -z | while IFS= read -r -d '' f; do
  mv "$f" "$PROCESSED/"
  echo "  MOVED: $(basename "$f")"
done

echo ""
echo "Done. Converted $TOTAL files."
echo "  Markdown:  $EXTRACTED/"
echo "  Originals: $PROCESSED/"
