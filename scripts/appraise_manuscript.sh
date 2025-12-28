#!/bin/bash

# Manuscript Appraisal Script
# This script resolves @import statements in full_book_preview.md,
# strips out the "Blocking" sections, and appraises the actual Draft content.

MANUSCRIPT_DIR="/Users/pedromartinez/Dev/book/03_Manuscript"
PREVIEW_FILE="$MANUSCRIPT_DIR/full_book_preview.md"
TEMP_BOOK="/tmp/full_manuscript_draft.md"

if [ ! -f "$PREVIEW_FILE" ]; then
    echo "Error: Preview file not found at $PREVIEW_FILE"
    exit 1
fi

echo "=== Full Manuscript Appraisal (Drafts Only) ==="
echo "Date: $(date)"
echo ""

# Clear temp file
> "$TEMP_BOOK"

# Process the preview file line by line
while IFS= read -r line || [ -n "$line" ]; do
    if [[ $line =~ ^@import\ \"(.*)\" ]]; then
        IMPORT_PATH="${BASH_REMATCH[1]}"
        FULL_IMPORT_PATH="$MANUSCRIPT_DIR/$IMPORT_PATH"
        
        if [ -f "$FULL_IMPORT_PATH" ]; then
            # Extract content after "### Draft"
            # We use sed to find the line matching "### Draft" and print everything after it
            sed -n '/### Draft/,$p' "$FULL_IMPORT_PATH" | sed '1d' >> "$TEMP_BOOK"
            echo "" >> "$TEMP_BOOK"
        else
            echo "Warning: Could not find imported file: $FULL_IMPORT_PATH"
        fi
    elif [[ $line =~ ^#\ Part ]]; then
        # Keep Part headers
        echo "$line" >> "$TEMP_BOOK"
        echo "" >> "$TEMP_BOOK"
    fi
done < "$PREVIEW_FILE"

# Word Count
WORD_COUNT=$(wc -w < "$TEMP_BOOK")
echo "Total Word Count (Drafts): $WORD_COUNT"

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
grep "^#" "$TEMP_BOOK"
echo ""

# Clean up
rm "$TEMP_BOOK"

echo "=== End Manuscript Appraisal ==="
