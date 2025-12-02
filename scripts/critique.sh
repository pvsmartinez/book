#!/bin/bash

# Persona Critique Script
# Usage: ./scripts/critique.sh <persona_name> <file_path>
# Example: ./scripts/critique.sh skeptic 01_Seeds/my_idea.md

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./scripts/critique.sh <persona_name> <file_path>"
    echo "Available personas:"
    ls 05_Personas | sed 's/\.md//'
    exit 1
fi

PERSONA_NAME="$1"
FILE_PATH="$2"
PERSONA_FILE="05_Personas/${PERSONA_NAME}.md"

if [ ! -f "$PERSONA_FILE" ]; then
    echo "Error: Persona '$PERSONA_NAME' not found in 05_Personas/."
    exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' not found."
    exit 1
fi

echo "=== AI Critique Request ==="
echo "Please act as the following persona to critique the file '$FILE_PATH'."
echo ""
echo "--- Persona Profile ---"
cat "$PERSONA_FILE"
echo ""
echo "--- Content to Critique ---"
cat "$FILE_PATH"
echo ""
echo "=== End Request ==="
echo ""
echo "(Copy the output above and paste it into the AI chat to get the critique)"
