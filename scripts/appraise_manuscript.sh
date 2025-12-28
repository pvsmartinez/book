#!/bin/bash

# Manuscript Appraisal Script
# This script appraises the full_book_preview.md file directly.

MANUSCRIPT_DIR="/Users/pedromartinez/Dev/book/03_Manuscript"
PREVIEW_FILE="$MANUSCRIPT_DIR/full_book_preview.md"

if [ ! -f "$PREVIEW_FILE" ]; then
    echo "Error: Preview file not found at $PREVIEW_FILE"
    exit 1
fi

echo "=== Full Manuscript Appraisal ==="
echo "Date: $(date)"
echo ""

# Word Count
WORD_COUNT=$(wc -w < "$PREVIEW_FILE")
echo "Total Word Count: $WORD_COUNT"

# Reading Time (approx 200 wpm)
READING_TIME=$((WORD_COUNT / 200))
if [ $READING_TIME -lt 1 ]; then READING_TIME=1; fi
echo "Est. Reading Time: $READING_TIME min"
echo ""

# Page Estimate (approx 250 words per page for standard 6x9 Trade Paperback)
PAGE_COUNT=$((WORD_COUNT / 250))
echo "Est. Page Count (6x9 Book): $PAGE_COUNT pages"
echo ""

# Structure Check (Headings)
echo "--- Manuscript Structure ---"
grep "^# " "$PREVIEW_FILE"
echo ""

echo "=== End Manuscript Appraisal ==="
