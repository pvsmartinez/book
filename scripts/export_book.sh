#!/bin/bash

# Directory for exports
EXPORT_DIR="07_Exports"
mkdir -p "$EXPORT_DIR"

# Parse arguments
GENERATE_PDF=true
for arg in "$@"; do
    if [ "$arg" == "--no-pdf" ]; then
        GENERATE_PDF=false
    fi
done

# Determine the next version number
LAST_VERSION=$(ls "$EXPORT_DIR" | grep -oE 'v[0-9]+' | grep -oE '[0-9]+' | sort -n | tail -1)
if [ -z "$LAST_VERSION" ]; then
    VERSION=1
else
    VERSION=$((LAST_VERSION + 1))
fi

FILENAME="manuscript_v$VERSION"
TEMP_MD="temp_manuscript.md"
HTML_FILE="$EXPORT_DIR/$FILENAME.html"

echo "Generating $FILENAME..."

# Create Title Page and TOC placeholder
cat << EOM > "$TEMP_MD"
<div class="title-page">
    <h1>The Invisible Pattern</h1>
    <h2>Iteration, Selection, and the Code of the World</h2>
    <p class="author">Pedro Martinez</p>
    <p class="version">Version $VERSION | $(date +'%B %Y')</p>
</div>

<h1 id="table-of-contents" class="no-toc-header">Table of Contents</h1>
[TOC]

EOM

# Append all chapters in order, cleaning them up for the book format
for part in Part_I Part_II Part_III Part_IV Part_V Part_VI; do
    echo "Processing $part..."
    
    # Add Part Page
    # Read metadata from 03_Manuscript/book_metadata.md
    METADATA_FILE="03_Manuscript/book_metadata.md"
    
    # Extract Title and Description using sed
    TITLE=$(sed -n "/^## $part$/,/^##/p" "$METADATA_FILE" | grep "^Title: " | sed 's/^Title: //')
    DESC=$(sed -n "/^## $part$/,/^##/p" "$METADATA_FILE" | grep "^Description: " | sed 's/^Description: //')

    # Add hidden markdown header for TOC, then the HTML display
    # We use a span with strictly specific class to maybe hide it in PDF if we only want it in TOC?
    # Or just let it appear as a Part Header.
    # To act as a "divisor", we want it in the TOC.
    # We add it as a Markdown H1 so it gets picked up.
    echo "# $TITLE" >> "$TEMP_MD"
    
    cat << EOM >> "$TEMP_MD"
<div class="part-page">
    <p>$DESC</p>
</div>
EOM

    for file in 03_Manuscript/$part/*.md; do
        echo "Adding $(basename "$file")..."
        
        sed -e '/<details>/,/<\/details>/d' \
            -e 's/### Draft//g' \
            -e '/^---$/d' \
            "$file" >> "$TEMP_MD"
            
        # Add two blank lines to ensure separation between file content and next chapter
        echo -e "\n\n" >> "$TEMP_MD"
    done
done

# Define Python and WeasyPrint paths
PYTHON_BIN="/Users/pedromartinez/Dev/book/.venv/bin/python"
WEASYPRINT_BIN="/Users/pedromartinez/Dev/book/.venv/bin/weasyprint"
CSS_FILE="scripts/book_style.css"

# Process Mermaid Diagrams
echo "Processing Mermaid Diagrams..."
TEMP_MD_MERMAID="temp_manuscript_mermaid.md"
$PYTHON_BIN scripts/process_mermaid.py "$TEMP_MD" > "$TEMP_MD_MERMAID"

# Process Math Formulas (LaTeX)
echo "Processing Math Formulas..."
TEMP_MD_PROCESSED="temp_manuscript_processed.md"
$PYTHON_BIN scripts/process_math.py "$TEMP_MD_MERMAID" > "$TEMP_MD_PROCESSED"

# Convert MD to HTML body using Python's markdown library
echo "Converting Markdown to HTML..."

# Generate the full HTML with the professional CSS linked
cat << EOM > "$HTML_FILE"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$FILENAME</title>
    <link rel="stylesheet" href="../$CSS_FILE">
</head>
<body>
EOM

# Append Content from MD
$PYTHON_BIN -c "import markdown; print(markdown.markdown(open('$TEMP_MD_PROCESSED').read(), extensions=['extra', 'toc'], extension_configs={'toc': {'toc_depth': '2'}}))" >> "$HTML_FILE"

cat << EOM >> "$HTML_FILE"
</body>
</html>
EOM

# Save the MD version for reference
cp "$TEMP_MD_PROCESSED" "$EXPORT_DIR/$FILENAME.md"

if [ "$GENERATE_PDF" = true ]; then
    echo "Generating Professional PDF with WeasyPrint..."
    $WEASYPRINT_BIN "$HTML_FILE" "$EXPORT_DIR/$FILENAME.pdf"
else
    echo "Skipping PDF generation (--no-pdf flag detected)."
fi

# Cleanup
rm "$TEMP_MD"
rm "$TEMP_MD_MERMAID"
rm "$TEMP_MD_PROCESSED"

echo "------------------------------------------------"
echo "Success! Professional Book Exported to:"
echo "  - $EXPORT_DIR/$FILENAME.md"
echo "  - $EXPORT_DIR/$FILENAME.html"
if [ "$GENERATE_PDF" = true ]; then
    echo "  - $EXPORT_DIR/$FILENAME.pdf (Best-Seller Style)"
fi
echo "------------------------------------------------"
