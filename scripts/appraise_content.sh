#!/bin/bash

# Content Appraisal Script
# Usage: ./scripts/appraise_content.sh [optional_file_path]

if [ -z "$1" ]; then
    echo "Usage: ./scripts/appraise_content.sh <path_to_file>"
    echo "Please provide a file to appraise."
    exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' not found."
    exit 1
fi

echo "=== Content Appraisal for: $FILE_PATH ==="
echo "Date: $(date)"
echo ""

# Word Count
WORD_COUNT=$(wc -w < "$FILE_PATH")
echo "Word Count: $WORD_COUNT"

# Reading Time (approx 200 wpm)
READING_TIME=$((WORD_COUNT / 200))
if [ $READING_TIME -lt 1 ]; then READING_TIME=1; fi
echo "Est. Reading Time: $READING_TIME min"
echo ""

# Structure Check (Headings)
echo "--- Structure (Headings) ---"
grep "^#" "$FILE_PATH"
echo ""

# TODO Check
echo "--- Outstanding TODOs ---"
grep "TODO" "$FILE_PATH" || echo "No TODOs found."
echo ""

echo "=== End Content Appraisal ==="
