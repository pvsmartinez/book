#!/bin/bash
# Import Grammarly-edited Word document back to markdown files

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Error: pandoc is not installed"
    echo "Install it with: brew install pandoc"
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: python3 is not installed"
    exit 1
fi

# Parse arguments
DRY_RUN=""
INTERACTIVE=""
INPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-n)
            DRY_RUN="--dry-run"
            shift
            ;;
        --interactive|-i)
            INTERACTIVE="--interactive"
            shift
            ;;
        --apply|-a)
            # Apply mode (no extra flags needed)
            shift
            ;;
        *)
            INPUT_FILE="$1"
            shift
            ;;
    esac
done

# Check if input file is provided
if [ -z "$INPUT_FILE" ]; then
    echo "❌ Error: No input file provided"
    echo ""
    echo "Usage: bash scripts/import_from_grammarly.sh [options] <edited_file.docx>"
    echo ""
    echo "Options:"
    echo "  --dry-run, -n     Show what would change without applying"
    echo "  --interactive, -i  Ask before applying each change"
    echo "  --apply, -a       Apply all changes automatically"
    echo ""
    echo "Available files:"
    ls -1t 07_Exports/grammarly_edit_*.docx 2>/dev/null | head -5
    exit 1
fi

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: File not found: $INPUT_FILE"
    exit 1
fi

TEMP_MD="07_Exports/temp_imported.md"
TEMP_RESTORED="07_Exports/temp_restored.md"

# Find matching manifest file
MANIFEST_FILE="${INPUT_FILE%.docx}.manifest.json"

echo "📥 Importing from Grammarly-edited document..."
echo "📄 Source: $INPUT_FILE"
echo ""

# Convert Word back to markdown
echo "🔄 Converting Word to markdown..."
pandoc "$INPUT_FILE" \
    -o "$TEMP_MD" \
    --from docx \
    --to markdown \
    --wrap=none \
    --extract-media=.

echo "✅ Conversion complete: $TEMP_MD"

# Restore code blocks if manifest exists
if [ -f "$MANIFEST_FILE" ]; then
    echo ""
    echo "🛡️  Restoring protected code blocks..."
    python3 "$SCRIPT_DIR/protect_code_blocks.py" restore "$TEMP_MD" "$MANIFEST_FILE" "$TEMP_RESTORED"
    mv "$TEMP_RESTORED" "$TEMP_MD"
else
    echo ""
    echo "⚠️  No manifest file found at: $MANIFEST_FILE"
    echo "   Code blocks may be corrupted. Consider re-exporting."
fi

echo ""

# Run the diff applier
echo "🔍 Analyzing changes..."
echo ""

cd "$PROJECT_ROOT"
python3 scripts/apply_grammarly_diff.py "$TEMP_MD" $DRY_RUN $INTERACTIVE --verbose

echo ""
echo "💡 Tips:"
echo "   • Run with --dry-run first to preview changes"
echo "   • Run with --interactive to approve each change"
echo "   • Run with --apply to apply all changes automatically"
