#!/bin/bash
# ============================================================================
# export_book.sh — Generate the full manuscript PDF with WeasyPrint
#
# Integrates with Cafezin's export system:
#   - CAFEZIN_PROGRESS: reports step-by-step progress to the UI progress bar
#   - CAFEZIN_ARTIFACT: declares the generated PDF so Cafezin can reveal it
#
# Usage:
#   bash scripts/export_book.sh                          # default output: 07_Exports/
#   bash scripts/export_book.sh --no-pdf                 # generate HTML only (skip PDF)
#   OUTPUT_DIR=07_Exports bash scripts/export_book.sh    # explicit output dir
#
# When called by Cafezin's custom export target, OUTPUT_DIR is set automatically
# via the {{output_dir}} placeholder in the target config.
# ============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Output dir: prefer Cafezin's OUTPUT_DIR env var, fallback to 07_Exports
EXPORT_DIR="${OUTPUT_DIR:-07_Exports}"
mkdir -p "$EXPORT_DIR"

# Temp directory — cleaned automatically on exit
TEMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEMP_DIR"
    rm -f "$EXPORT_DIR/_temp_render.html"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
GENERATE_PDF=true

for arg in "$@"; do
    if [ "$arg" == "--no-pdf" ]; then
        GENERATE_PDF=false
    fi
done

# ---------------------------------------------------------------------------
# Version number (auto-increment from existing files)
# ---------------------------------------------------------------------------
LAST_VERSION=$(ls "$EXPORT_DIR" 2>/dev/null | grep -oE 'manuscript_v[0-9]+' | sed 's/manuscript_v//' | sort -n | tail -1)
if [ -z "$LAST_VERSION" ]; then
    VERSION=1
else
    VERSION=$((LAST_VERSION + 1))
fi

FILENAME="manuscript_v$VERSION"
TEMP_MD="$TEMP_DIR/temp_manuscript.md"
TEMP_HTML="$EXPORT_DIR/_temp_render.html"

# ---------------------------------------------------------------------------
# Progress reporting
# ---------------------------------------------------------------------------
TOTAL_STEPS=7
CURRENT_STEP=0

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "CAFEZIN_PROGRESS ${CURRENT_STEP}/${TOTAL_STEPS} $1"
}

# ---------------------------------------------------------------------------
# Python / tools paths
# ---------------------------------------------------------------------------
PYTHON_BIN="$PROJECT_DIR/.venv/bin/python"
WEASYPRINT_BIN="$PROJECT_DIR/.venv/bin/weasyprint"
CSS_FILE="scripts/book_style.css"

# Verify dependencies exist
if [ ! -f "$PYTHON_BIN" ]; then
    echo "❌ Python venv not found at $PYTHON_BIN" >&2
    echo "   Run: python3 -m venv .venv && .venv/bin/pip install weasyprint markdown" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Book metadata
# ---------------------------------------------------------------------------
METADATA_FILE="03_Manuscript/book_metadata.md"
BOOK_TITLE="The Shape of the Game"
BOOK_SUBTITLE="How iteration and selection explain the world"
BOOK_AUTHOR="Pedro Martinez"

# ---------------------------------------------------------------------------
# Step 1: Build title page + concatenate all chapters
# ---------------------------------------------------------------------------
progress "Concatenating chapters..."

cat << EOM > "$TEMP_MD"
<div class="title-page">
    <div class="title-group">
        <h1>${BOOK_TITLE}</h1>
        <h2>${BOOK_SUBTITLE}</h2>
    </div>
    <div class="author-group">
        <p class="author">${BOOK_AUTHOR}</p>
        <p class="version">Version $VERSION | $(date +'%B %Y')</p>
    </div>
</div>

<h1 id="table-of-contents" class="no-toc-header">Table of Contents</h1>
[TOC]

EOM

CHAPTER_COUNT=0

for part in Part_I Part_II Part_III Part_IV Part_V Part_VI; do
    # Read Part metadata (Title & Description) — awk for macOS/Linux compatibility
    TITLE=$(awk -v p="$part" '
        $0 == "## " p { found=1; next }
        found && /^## / { exit }
        found && /^Title: / { sub(/^Title: /, ""); print; exit }
    ' "$METADATA_FILE")
    DESC=$(awk -v p="$part" '
        $0 == "## " p { found=1; next }
        found && /^## / { exit }
        found && /^Description: / { sub(/^Description: /, ""); print; exit }
    ' "$METADATA_FILE")

    # Add Part header (H1 for TOC)
    echo "# $TITLE" >> "$TEMP_MD"

    cat << EOM >> "$TEMP_MD"
<div class="part-page">
    <p>$DESC</p>
</div>
EOM

    for file in 03_Manuscript/$part/*.md; do
        [ -f "$file" ] || continue

        # Strip YAML frontmatter (between --- markers at top of file)
        # Strip <details> blocks
        # Strip Draft markers
        awk '
        BEGIN { in_front=0; in_details=0; first_line=1 }
        first_line && /^---$/ { in_front=1; first_line=0; next }
        in_front && /^---$/ { in_front=0; next }
        in_front { next }
        { first_line=0 }
        /<details>/ { in_details=1; next }
        /<\/details>/ { in_details=0; next }
        in_details { next }
        /^### Draft/ { next }
        { print }
        ' "$file" >> "$TEMP_MD"

        echo -e "\n\n" >> "$TEMP_MD"
        CHAPTER_COUNT=$((CHAPTER_COUNT + 1))
    done
done

echo "   → ${CHAPTER_COUNT} chapters concatenated"

# ---------------------------------------------------------------------------
# Step 2: Process Mermaid diagrams
# ---------------------------------------------------------------------------
progress "Processing Mermaid diagrams..."

TEMP_MD_MERMAID="$TEMP_DIR/temp_manuscript_mermaid.md"
$PYTHON_BIN scripts/process_mermaid.py "$TEMP_MD" > "$TEMP_MD_MERMAID"

# ---------------------------------------------------------------------------
# Step 3: Process Math (LaTeX formulas)
# ---------------------------------------------------------------------------
progress "Processing math formulas..."

TEMP_MD_PROCESSED="$TEMP_DIR/temp_manuscript_processed.md"
$PYTHON_BIN scripts/process_math.py "$TEMP_MD_MERMAID" > "$TEMP_MD_PROCESSED"

# ---------------------------------------------------------------------------
# Step 4: Process inline images (*(imagem: ...)*  placeholders)
# ---------------------------------------------------------------------------
progress "Processing inline images..."

TEMP_MD_IMAGES="$TEMP_DIR/temp_manuscript_images.md"
$PYTHON_BIN scripts/process_images.py "$TEMP_MD_PROCESSED" > "$TEMP_MD_IMAGES"

# ---------------------------------------------------------------------------
# Step 5: Convert Markdown → HTML
# ---------------------------------------------------------------------------
progress "Converting Markdown to HTML..."

cat << EOM > "$TEMP_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${BOOK_TITLE}</title>
    <link rel="stylesheet" href="../$CSS_FILE">
</head>
<body>
EOM

$PYTHON_BIN -c "
import markdown
print(markdown.markdown(
    open('$TEMP_MD_IMAGES').read(),
    extensions=['extra', 'toc'],
    extension_configs={'toc': {'toc_depth': '2'}}
))
" >> "$TEMP_HTML"

cat << EOM >> "$TEMP_HTML"
</body>
</html>
EOM

# ---------------------------------------------------------------------------
# Step 6: Generate PDF with WeasyPrint
# ---------------------------------------------------------------------------
if [ "$GENERATE_PDF" = true ]; then
    progress "Generating PDF with WeasyPrint..."
    $WEASYPRINT_BIN "$TEMP_HTML" "$EXPORT_DIR/$FILENAME.pdf"
else
    progress "Skipping PDF generation (--no-pdf flag)"
fi

# ---------------------------------------------------------------------------
# Step 7: Done — report artifact
# ---------------------------------------------------------------------------
progress "Export complete!"

if [ "$GENERATE_PDF" = true ]; then
    echo "CAFEZIN_ARTIFACT {\"path\":\"${EXPORT_DIR}/${FILENAME}.pdf\",\"label\":\"📖 ${BOOK_TITLE} v${VERSION}\"}"
    echo ""
    echo "================================================"
    echo "  ✅ ${FILENAME}.pdf exported successfully"
    echo "  📂 ${EXPORT_DIR}/${FILENAME}.pdf"
    echo "  📊 ${CHAPTER_COUNT} chapters | Version ${VERSION}"
    echo "================================================"
else
    echo ""
    echo "================================================"
    echo "  ✅ HTML generated (no PDF)"
    echo "  📂 ${TEMP_HTML}"
    echo "================================================"
fi
