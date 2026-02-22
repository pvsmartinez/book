#!/bin/bash

# Manuscript Appraisal Script
# Appraises the manuscript by reading chapter files from Part_* directories.

MANUSCRIPT_DIR="/Users/pedromartinez/Dev/book/03_Manuscript"

echo "=== Full Manuscript Appraisal ==="
echo "Date: $(date)"
echo ""

# Collect all chapter files
TOTAL_WORDS=0
echo "--- Manuscript Structure ---"
for part_dir in "$MANUSCRIPT_DIR"/Part_*; do
    if [ -d "$part_dir" ]; then
        PART_NAME=$(basename "$part_dir")
        PART_WORDS=0
        CHAPTER_COUNT=0
        for file in "$part_dir"/*.md; do
            if [ -f "$file" ]; then
                FILE_WORDS=$(wc -w < "$file")
                PART_WORDS=$((PART_WORDS + FILE_WORDS))
                CHAPTER_COUNT=$((CHAPTER_COUNT + 1))
            fi
        done
        TOTAL_WORDS=$((TOTAL_WORDS + PART_WORDS))
        printf "  %-12s  %2d chapters  %6d words\n" "$PART_NAME" "$CHAPTER_COUNT" "$PART_WORDS"
    fi
done
echo ""

echo "Total Word Count: $TOTAL_WORDS"

# Reading Time (approx 200 wpm)
READING_TIME=$((TOTAL_WORDS / 200))
if [ $READING_TIME -lt 1 ]; then READING_TIME=1; fi
echo "Est. Reading Time: $READING_TIME min"

# Page Estimate (approx 250 words per page for standard 6x9 Trade Paperback)
PAGE_COUNT=$((TOTAL_WORDS / 250))
echo "Est. Page Count (6x9 Book): $PAGE_COUNT pages"
echo ""

echo "=== End Manuscript Appraisal ==="
