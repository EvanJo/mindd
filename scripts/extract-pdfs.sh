#!/bin/bash
set -euo pipefail

# extract-pdfs.sh — Batch extract text from PDFs for wiki ingestion.
#
# Usage: ./scripts/extract-pdfs.sh [source_dir]
#   source_dir defaults to raw/ai_automation
#
# For each PDF in source_dir:
#   1. Extracts text to source_dir/extracted/<name>.txt
#   2. Moves the PDF to source_dir/processed/
#
# Processes in batches of 5, printing progress.

SRC_DIR="${1:-raw/ai_automation}"
EXTRACTED="$SRC_DIR/extracted"
PROCESSED="$SRC_DIR/processed"

mkdir -p "$EXTRACTED" "$PROCESSED"

# Check for pdftotext
if ! command -v pdftotext &>/dev/null; then
  echo "ERROR: pdftotext not found. Install poppler: brew install poppler"
  exit 1
fi

# Collect PDFs
TOTAL=$(find "$SRC_DIR" -maxdepth 1 -name "*.pdf" -type f | wc -l | tr -d ' ')

if [ "$TOTAL" -eq 0 ]; then
  echo "No PDFs found in $SRC_DIR"
  exit 0
fi

echo "Found $TOTAL PDFs in $SRC_DIR"
echo ""

COUNT=0
BATCH=0
find "$SRC_DIR" -maxdepth 1 -name "*.pdf" -type f -print0 | sort -z | while IFS= read -r -d '' pdf; do
  BASENAME="$(basename "$pdf" .pdf)"
  TXTFILE="$EXTRACTED/$BASENAME.txt"

  if [ -f "$TXTFILE" ]; then
    echo "  SKIP (already extracted): $BASENAME"
  else
    pdftotext "$pdf" "$TXTFILE"
    echo "  EXTRACTED: $BASENAME"
  fi

  mv "$pdf" "$PROCESSED/"

  COUNT=$((COUNT + 1))
  if [ $((COUNT % 5)) -eq 0 ]; then
    BATCH=$((BATCH + 1))
    echo "--- Batch $BATCH complete ($COUNT/$TOTAL) ---"
  fi
done

echo ""
echo "Done. Extracted $TOTAL PDFs."
echo "  Text files: $EXTRACTED/"
echo "  Originals:  $PROCESSED/"
