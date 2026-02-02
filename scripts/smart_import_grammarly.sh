#!/bin/bash
# Smart import: attempts to automatically apply grammar changes from Grammarly

# Check if required tools are installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Error: pandoc is not installed"
    echo "Install it with: brew install pandoc"
    exit 1
fi

# Check if input file is provided
if [ -z "$1" ]; then
    echo "❌ Error: No input file provided"
    echo "Usage: bash scripts/smart_import_grammarly.sh <edited_file.docx>"
    exit 1
fi

INPUT_FILE="$1"

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: File not found: $INPUT_FILE"
    exit 1
fi

TEMP_DIR="07_Exports/temp_import_$(date +"%Y%m%d_%H%M%S")"
BACKUP_DIR="07_Exports/backups_$(date +"%Y%m%d_%H%M%S")"

mkdir -p "$TEMP_DIR"
mkdir -p "$BACKUP_DIR"

echo "🧠 Smart Import from Grammarly"
echo "================================"
echo ""

# Convert the edited Word document to markdown
echo "🔄 Converting Word to markdown..."
CONVERTED_MD="$TEMP_DIR/converted.md"
pandoc "$INPUT_FILE" \
    -o "$CONVERTED_MD" \
    --from docx \
    --to markdown \
    --wrap=none

echo "✅ Conversion complete"
echo ""

# Backup current manuscript
echo "💾 Creating backup..."
cp -r 03_Manuscript "$BACKUP_DIR/"
echo "✅ Backup: $BACKUP_DIR"
echo ""

# Split the converted markdown by chapters
echo "✂️  Splitting by chapters..."
echo ""

# This is a basic splitter - looks for chapter headings
csplit -s -f "$TEMP_DIR/chapter_" "$CONVERTED_MD" '/^## Chapter/' '{*}' 2>/dev/null || \
    echo "⚠️  Warning: Could not auto-split by chapters"

echo "📊 Analysis:"
echo "  - Original chapter files: $(find 03_Manuscript/Part_* -name "*.md" | wc -l | tr -d ' ')"
echo "  - Converted chunks: $(ls -1 "$TEMP_DIR"/chapter_* 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "🔍 Recommended workflow:"
echo ""
echo "1. Review the converted file:"
echo "   code $CONVERTED_MD"
echo ""
echo "2. Use VS Code's 'Compare' feature:"
echo "   - Open original chapter"
echo "   - Right-click → 'Select for Compare'"
echo "   - Open converted file"
echo "   - Right-click → 'Compare with Selected'"
echo ""
echo "3. Or use command-line diff:"
echo "   diff -u 03_Manuscript/Part_III/12_the_competitors_meta.md $CONVERTED_MD"
echo ""
echo "4. Copy grammar improvements manually (safest approach)"
echo ""
echo "💡 Pro tip: Grammarly mainly improves:"
echo "  ✓ Comma placement"
echo "  ✓ Subject-verb agreement"
echo "  ✓ Word choice"
echo "  ✓ Sentence clarity"
echo ""
echo "  ✗ It may mess up:"
echo "  ✗ Markdown formatting"
echo "  ✗ Code blocks"
echo "  ✗ Intentional stylistic choices"
echo ""
echo "  → Focus on adopting grammar fixes, not everything"
echo ""
