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

FILENAME="Unified_Selection_Framework_v$VERSION"
TEMP_MD="temp_manuscript.md"
HTML_FILE="$EXPORT_DIR/$FILENAME.html"

echo "Generating $FILENAME..."

# Create Title Page and TOC placeholder
cat << EOM > "$TEMP_MD"
<div class="title-page">
    <h1>The Unified Selection Framework</h1>
    <h2>Iteration, Selection, and the Code of the World</h2>
    <p class="author">Pedro Martinez</p>
    <p class="version">Version $VERSION | $(date +'%B %Y')</p>
</div>

<div style="page-break-after: always;"></div>

# Table of Contents
[TOC]

EOM

# Append all chapters in order, cleaning them up for the book format
for part in Part_I Part_II Part_III Part_IV Part_V; do
    echo "Processing $part..."
    
    # Add Part Page
    case $part in
        Part_I)
            TITLE="Part I: The Observation"
            DESC="Why the world feels like it's vibrating at a higher frequency."
            ;;
        Part_II)
            TITLE="Part II: The Engine"
            DESC="The mechanics of iteration and variance that drive all change."
            ;;
        Part_III)
            TITLE="Part III: The Filter"
            DESC="The invisible judge that decides the direction of evolution."
            ;;
        Part_IV)
            TITLE="Part IV: The Compounder"
            DESC="The power of time and the inevitability of inequality."
            ;;
        Part_V)
            TITLE="Part V: The Designer"
            DESC="Shifting from being a player to being an architect of systems."
            ;;
    esac

    cat << EOM >> "$TEMP_MD"
<div class="part-page">
    <h1>$TITLE</h1>
    <p>$DESC</p>
</div>
EOM

    for file in 03_Manuscript/$part/*.md; do
        echo "Adding $(basename "$file")..."
        # Add a page break before each chapter
        echo -e "\n<div style=\"page-break-before: always;\"></div>\n" >> "$TEMP_MD"
        
        # Clean the file:
        # 1. Remove the <details> block (outline/blocking)
        # 2. Remove "### Draft" headers
        # 3. Remove YAML frontmatter (lines between ---)
        # 4. Convert "## Chapter" to "# Chapter" so they are H1 for the CSS
        sed -e '/<details>/,/<\/details>/d' \
            -e 's/### Draft//g' \
            -e '/^---$/d' \
            -e 's/^## Chapter/# Chapter/g' "$file" >> "$TEMP_MD"
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
$PYTHON_BIN -c "import markdown; print(markdown.markdown(open('$TEMP_MD').read(), extensions=['extra', 'toc']))" >> "$HTML_FILE"

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
