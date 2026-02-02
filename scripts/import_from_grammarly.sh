#!/bin/bash
# Import Grammarly-edited Word document back to markdown files

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Error: pandoc is not installed"
    echo "Install it with: brew install pandoc"
    exit 1
fi

# Check if input file is provided
if [ -z "$1" ]; then
    echo "❌ Error: No input file provided"
    echo "Usage: bash scripts/import_from_grammarly.sh <edited_file.docx>"
    echo ""
    echo "Available files:"
    ls -1t 07_Exports/grammarly_edit_*.docx 2>/dev/null | head -5
    exit 1
fi

INPUT_FILE="$1"

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: File not found: $INPUT_FILE"
    exit 1
fi

TEMP_MD="07_Exports/temp_imported.md"
BACKUP_DIR="07_Exports/backups_$(date +"%Y%m%d_%H%M%S")"

echo "📥 Importing from Grammarly-edited document..."
echo "📄 Source: $INPUT_FILE"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Convert Word back to markdown
echo "🔄 Converting Word to markdown..."
pandoc "$INPUT_FILE" \
    -o "$TEMP_MD" \
    --from docx \
    --to markdown \
    --wrap=none \
    --extract-media=.

echo "✅ Conversion complete"
echo ""

# Create backup of all current manuscript files
echo "💾 Creating backup of current manuscript..."
cp -r 03_Manuscript "$BACKUP_DIR/"

echo "✅ Backup saved to: $BACKUP_DIR"
echo ""
echo "⚠️  MANUAL REVIEW REQUIRED"
echo ""
echo "The edited content has been converted to:"
echo "  → $TEMP_MD"
echo ""
echo "Next steps:"
echo "1. Open $TEMP_MD in VS Code"
echo "2. Review the changes (compare with originals)"
echo "3. Manually copy improved sections back to your chapter files"
echo ""
echo "Or, use a diff tool:"
echo "  code --diff 03_Manuscript/Part_III/12_the_competitors_meta.md $TEMP_MD"
echo ""
echo "💡 Tip: Focus on grammar/style improvements, not structural changes"
echo ""
