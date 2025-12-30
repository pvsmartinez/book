#!/bin/bash

# Directory for exports
EXPORT_DIR="07_Exports"
mkdir -p "$EXPORT_DIR"

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

# Table of Contents
[TOC]

EOM

# Append all chapters in order, cleaning them up for the book format
for part in Part_I Part_II Part_III Part_IV Part_V; do
    echo "Processing $part..."
    
    # Add Part Page
    # Read metadata from 03_Manuscript/book_metadata.md
    METADATA_FILE="03_Manuscript/book_metadata.md"
    
    # Extract Title and Description using sed
    TITLE=$(sed -n "/^## $part$/,/^##/p" "$METADATA_FILE" | grep "^Title: " | sed 's/^Title: //')
    DESC=$(sed -n "/^## $part$/,/^##/p" "$METADATA_FILE" | grep "^Description: " | sed 's/^Description: //')

    cat << EOM >> "$TEMP_MD"
<div class="part-page">
    <h1>$TITLE</h1>
    <p>$DESC</p>
</div>
EOM

    for file in 03_Manuscript/$part/*.md; do
        echo "Adding $(basename "$file")..."
        
        # Check if file is an interlude
        if [[ "$(basename "$file")" == *"interlude"* ]]; then
            echo "<div class=\"interlude\">" >> "$TEMP_MD"
        fi
        
        # Clean the file:
        # 1. Remove the <details> block (outline/blocking)
        # 2. Remove "### Draft" headers
        # 3. Remove YAML frontmatter (lines between ---)
        # 4. Convert "## Chapter" to "# Chapter" so they are H1 for the CSS
        sed -e '/<details>/,/<\/details>/d' \
            -e 's/### Draft//g' \
            -e '/^---$/d' \
            -e 's/^## Chapter/# Chapter/g' "$file" >> "$TEMP_MD"
        
        # Close interlude div if applicable
        if [[ "$(basename "$file")" == *"interlude"* ]]; then
            echo "</div>" >> "$TEMP_MD"
        fi
    done
done

# Convert MD to HTML body using Python's markdown library
echo "Converting Markdown to HTML..."
PYTHON_BIN="/Users/pedromartinez/Dev/book/.venv/bin/python"
WEASYPRINT_BIN="/Users/pedromartinez/Dev/book/.venv/bin/weasyprint"
CSS_FILE="scripts/book_style.css"

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
$PYTHON_BIN -c "import markdown; print(markdown.markdown(open('$TEMP_MD').read(), extensions=['extra', 'toc'], extension_configs={'toc': {'toc_depth': '1'}}))" >> "$HTML_FILE"

cat << EOM >> "$HTML_FILE"
</body>
</html>
EOM

# Save the MD version for reference
cp "$TEMP_MD" "$EXPORT_DIR/$FILENAME.md"

echo "Generating Professional PDF with WeasyPrint..."
$WEASYPRINT_BIN "$HTML_FILE" "$EXPORT_DIR/$FILENAME.pdf"

# Cleanup
rm "$TEMP_MD"

echo "------------------------------------------------"
echo "Success! Professional Book Exported to:"
echo "  - $EXPORT_DIR/$FILENAME.md"
echo "  - $EXPORT_DIR/$FILENAME.html"
echo "  - $EXPORT_DIR/$FILENAME.pdf (Best-Seller Style)"
echo "------------------------------------------------"
