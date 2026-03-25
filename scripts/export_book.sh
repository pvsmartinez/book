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
<h1 id="table-of-contents" class="no-toc-header">Table of Contents</h1>
[TOC]

EOM

CHAPTER_COUNT=0

# ---------------------------------------------------------------------------
# Helper: strip frontmatter/details/draft from a .md file and append to TEMP_MD
# ---------------------------------------------------------------------------
append_chapter() {
    local file="$1"
    [ -f "$file" ] || return
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
}

# ---------------------------------------------------------------------------
# Helper: read a field (Title/Description) from a metadata block in book_metadata.md
#   read_meta "## Part_IV"  "Title"
#   read_meta "### Section_A" "Title"   (inside Part_IV block)
# ---------------------------------------------------------------------------
read_meta() {
    local header="$1"
    local field="$2"
    awk -v h="$header" -v f="$field" '
        $0 == h { found=1; next }
        found && /^## / { exit }
        found && /^### / && h !~ /^###/ { exit }
        found && $0 ~ "^" f ": " { sub("^" f ": ", ""); print; exit }
    ' "$METADATA_FILE"
}

for part in Part_I Part_II Part_III Part_IV Part_V Part_VI; do
    TITLE=$(read_meta "## $part" "Title")
    DESC=$(read_meta "## $part" "Description")

    # Add Part header (H1 for TOC)
    echo "# $TITLE" >> "$TEMP_MD"

    cat << EOM >> "$TEMP_MD"
<div class="part-page">
    <p>$DESC</p>
</div>
EOM

    # -----------------------------------------------------------------------
    # Special handling for parts that contain sub-sections (Section_A, Section_B …)
    # Order:
    #   1. Loose .md files in the Part root (sorted), that sort BEFORE sections
    #   2. Each Section_* sub-folder in alphabetical order:
    #        - Section page (break-before: recto)
    #        - Chapters inside the section (sorted)
    #   3. Loose .md files in the Part root that sort AFTER sections
    # "Before/after sections" is determined by filename vs the first/last chapter
    # numbers found inside sections — we rely on numeric prefix in filenames.
    # -----------------------------------------------------------------------

    PART_DIR="03_Manuscript/$part"
    HAS_SECTIONS=false
    for sd in "$PART_DIR"/Section_*/; do
        [ -d "$sd" ] && HAS_SECTIONS=true && break
    done

    if [ "$HAS_SECTIONS" = true ]; then
        # Find the lowest chapter number inside any section
        FIRST_SECTION_NUM=9999
        for sd in "$PART_DIR"/Section_*/; do
            for f in "$sd"*.md; do
                [ -f "$f" ] || continue
                num=$(basename "$f" | grep -oE '^[0-9]+')
                [ -n "$num" ] && [ "$num" -lt "$FIRST_SECTION_NUM" ] && FIRST_SECTION_NUM=$num
            done
        done

        # 1. Loose files that come BEFORE the first section chapter
        for file in $(ls "$PART_DIR"/*.md 2>/dev/null | sort); do
            num=$(basename "$file" | grep -oE '^[0-9]+')
            [ -n "$num" ] && [ "$num" -lt "$FIRST_SECTION_NUM" ] && append_chapter "$file"
        done

        # 2. Each section in order
        for sd in $(ls -d "$PART_DIR"/Section_*/ 2>/dev/null | sort); do
            # Derive section key: "Section_A" from the path
            sec_key=$(basename "$sd")
            SEC_TITLE=$(read_meta "### $sec_key" "Title")

            # Derive human-readable label: "Section_A" → "Section A"
            SEC_LABEL=$(echo "$sec_key" | sed 's/_/ /')

            # Section page — injected as raw HTML (won't pollute TOC h2 chapters)
            cat << EOM >> "$TEMP_MD"
<div class="section-page">
    <p class="section-label">$SEC_LABEL</p>
    <h2 class="section-title">$SEC_TITLE</h2>
</div>
EOM

            for file in $(ls "$sd"*.md 2>/dev/null | sort); do
                append_chapter "$file"
            done
        done

        # 3. Loose files that come AFTER the sections
        LAST_SECTION_NUM=0
        for sd in "$PART_DIR"/Section_*/; do
            for f in "$sd"*.md; do
                [ -f "$f" ] || continue
                num=$(basename "$f" | grep -oE '^[0-9]+')
                [ -n "$num" ] && [ "$num" -gt "$LAST_SECTION_NUM" ] && LAST_SECTION_NUM=$num
            done
        done

        for file in $(ls "$PART_DIR"/*.md 2>/dev/null | sort); do
            num=$(basename "$file" | grep -oE '^[0-9]+')
            [ -n "$num" ] && [ "$num" -gt "$LAST_SECTION_NUM" ] && append_chapter "$file"
        done

    else
        # Standard part: no sections, iterate files directly
        for file in $(ls 03_Manuscript/$part/*.md 2>/dev/null | sort); do
            append_chapter "$file"
        done
    fi
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

<!-- Blank page (verso) before title page -->
<div class="blank-page"></div>

<!-- Title / version page (recto) -->
<div class="title-page">
    <p class="title-page-title">${BOOK_TITLE}</p>
    <p class="title-page-subtitle">${BOOK_SUBTITLE}</p>
    <div class="title-page-rule"></div>
    <p class="title-page-author">${BOOK_AUTHOR}</p>
    <p class="title-page-version">Version ${VERSION} &nbsp;&middot;&nbsp; $(date +'%B %Y')</p>
</div>

EOM

$PYTHON_BIN -c "
import markdown
print(markdown.markdown(
    open('$TEMP_MD_IMAGES').read(),
    extensions=['extra', 'toc'],
    extension_configs={'toc': {'toc_depth': '2'}}
))
" >> "$TEMP_HTML"

# Inject section entries into the TOC (post-process the HTML)
$PYTHON_BIN scripts/inject_sections_toc.py "$TEMP_HTML"

cat << EOM >> "$TEMP_HTML"
<div class="colophon">
    <p><em>${BOOK_TITLE}</em></p>
    <p>${BOOK_AUTHOR}</p>
    <p>Version ${VERSION} &nbsp;&middot;&nbsp; $(date +'%B %Y')</p>
</div>

<!-- Blank page at the end -->
<div class="blank-page blank-page--last"></div>

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
# Step 7: Prepend cover page and report artifact
# ---------------------------------------------------------------------------
progress "Export complete!"

if [ "$GENERATE_PDF" = true ]; then
    COVER_PDF="$SCRIPT_DIR/cover.pdf"
    FINAL_PDF="$EXPORT_DIR/$FILENAME.pdf"

    if [ -f "$COVER_PDF" ]; then
        TEMP_MANUSCRIPT_PDF="$TEMP_DIR/manuscript_nocov.pdf"
        mv "$FINAL_PDF" "$TEMP_MANUSCRIPT_PDF"
        if command -v pdfunite &>/dev/null; then
            pdfunite "$COVER_PDF" "$TEMP_MANUSCRIPT_PDF" "$FINAL_PDF"
            echo "   → Cover prepended with pdfunite"
        elif command -v pdftk &>/dev/null; then
            pdftk "$COVER_PDF" "$TEMP_MANUSCRIPT_PDF" cat output "$FINAL_PDF"
            echo "   → Cover prepended with pdftk"
        else
            mv "$TEMP_MANUSCRIPT_PDF" "$FINAL_PDF"
            echo "   ⚠️  Cover PDF found but pdfunite/pdftk not installed — skipping cover merge" >&2
        fi
    else
        echo "   ℹ️  No cover PDF found at $COVER_PDF — skipping cover merge"
    fi

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
