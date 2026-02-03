#!/bin/bash
# Export manuscript chapters to a single Word document for Grammarly editing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Error: pandoc is not installed"
    echo "Install it with: brew install pandoc"
    exit 1
fi

# Define source and output directories
MANUSCRIPT_DIR="03_Manuscript"
OUTPUT_DIR="07_Exports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="${OUTPUT_DIR}/grammarly_edit_${TIMESTAMP}.docx"
TEMP_MD="${OUTPUT_DIR}/temp_combined.md"
TEMP_STRIPPED="${OUTPUT_DIR}/temp_stripped.md"
MANIFEST_FILE="${OUTPUT_DIR}/grammarly_edit_${TIMESTAMP}.manifest.json"

# Create exports directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "📚 Exporting manuscript for Grammarly..."
echo ""

# Combine all markdown files into one, preserving structure
> "$TEMP_MD"  # Clear temp file

# Function to add files from a directory
add_part_files() {
    local part_dir="$1"
    local part_name=$(basename "$part_dir")
    
    if [ -d "$part_dir" ]; then
        echo "# $part_name" >> "$TEMP_MD"
        echo "" >> "$TEMP_MD"
        
        # Sort files numerically/alphabetically
        for file in "$part_dir"/*.md; do
            if [ -f "$file" ]; then
                echo "  - Adding: $(basename "$file")"
                cat "$file" >> "$TEMP_MD"
                echo "" >> "$TEMP_MD"
                echo "" >> "$TEMP_MD"
            fi
        done
    fi
}

# Add all parts
for part in "$MANUSCRIPT_DIR"/Part_*; do
    add_part_files "$part"
done

echo ""

# Protect code blocks before sending to Word
echo "🛡️  Protecting code blocks from Word corruption..."
python3 "$SCRIPT_DIR/protect_code_blocks.py" strip "$TEMP_MD" "$TEMP_STRIPPED"

# The manifest is created as temp_stripped.manifest.json, rename it
if [ -f "${OUTPUT_DIR}/temp_stripped.manifest.json" ]; then
    mv "${OUTPUT_DIR}/temp_stripped.manifest.json" "$MANIFEST_FILE"
fi

echo ""
echo "🔄 Converting to Word document..."

# Convert to .docx with pandoc (use stripped version)
pandoc "$TEMP_STRIPPED" \
    -o "$OUTPUT_FILE" \
    --from markdown \
    --to docx \
    --reference-doc="${OUTPUT_DIR}/reference.docx" 2>/dev/null || \
pandoc "$TEMP_STRIPPED" \
    -o "$OUTPUT_FILE" \
    --from markdown \
    --to docx

# Clean up temp files
rm -f "$TEMP_MD" "$TEMP_STRIPPED"

echo ""
echo "✅ Export complete!"
echo "📄 File: $OUTPUT_FILE"
echo "📋 Manifest: $MANIFEST_FILE"
echo ""
echo "Next steps (Google Docs - FREE):"
echo "1. Go to https://drive.google.com"
echo "2. Upload this file"
echo "3. Right-click → 'Open with' → 'Google Docs'"
echo "4. Grammarly will work automatically (install browser extension if needed)"
echo "5. Make your edits"
echo "6. File → Download → Microsoft Word (.docx)"
echo "7. Run: bash scripts/import_from_grammarly.sh $OUTPUT_FILE"
echo ""
echo "⚠️  Keep the manifest file! It's needed to restore code blocks on import."
