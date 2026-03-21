"""
process_images.py — Convert image placeholders to HTML <img> tags for PDF export.

Supported syntax in Markdown:
    *(imagem: filename.jpg)*
    *(imagem: filename.jpg | Caption text here)*

The placeholder is invisible-ish in the Cafezin Markdown preview (renders as
italic text) but gets converted to a real <img> before WeasyPrint sees it.

Images must be placed in:
    04_Resources/images/<filename>

The generated <img> uses an absolute file:// path so WeasyPrint always
resolves it correctly, regardless of where the temp HTML sits.

Usage:
    python scripts/process_images.py <input_md_file>
    (reads from file, writes processed markdown to stdout)
"""

import re
import os
import sys


def process_images(content: str, images_dir: str) -> str:
    """
    Find *(imagem: ...)* placeholders and replace with HTML <figure> blocks.

    Args:
        content:    Full markdown text (already concatenated manuscript).
        images_dir: Absolute path to 04_Resources/images/.

    Returns:
        Modified markdown string with placeholders replaced by HTML.
    """

    # Pattern: *(imagem: filename.jpg)* or *(imagem: filename.jpg | Caption)*
    # Tolerates spaces around the pipe and optional trailing whitespace.
    pattern = re.compile(
        r'\*\(imagem:\s*([^\)\|]+?)(?:\|\s*([^\)]*?))?\s*\)\*',
        re.IGNORECASE
    )

    def replace_placeholder(match: re.Match) -> str:
        filename = match.group(1).strip()
        caption  = match.group(2).strip() if match.group(2) else None

        image_path = os.path.join(images_dir, filename)

        if not os.path.exists(image_path):
            # Warn but don't crash — keeps the export running even with missing images.
            print(
                f"⚠️  process_images: image not found: {image_path}",
                file=sys.stderr
            )
            # Leave a visible placeholder in the PDF so the author notices.
            return (
                f'<div class="missing-image">'
                f'[IMAGE MISSING: {filename}]'
                f'</div>'
            )

        # Use absolute file:// URI — WeasyPrint resolves these reliably.
        abs_uri = "file://" + image_path

        if caption:
            html = (
                f'<figure class="book-image">'
                f'<img src="{abs_uri}" alt="{caption}">'
                f'<figcaption>{caption}</figcaption>'
                f'</figure>'
            )
        else:
            html = (
                f'<figure class="book-image">'
                f'<img src="{abs_uri}" alt="{filename}">'
                f'</figure>'
            )

        return html

    return pattern.sub(replace_placeholder, content)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python process_images.py <input_md_file>", file=sys.stderr)
        sys.exit(1)

    input_file = sys.argv[1]
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    images_dir   = os.path.join(project_root, "04_Resources", "images")

    with open(input_file, "r", encoding="utf-8") as f:
        content = f.read()

    processed = process_images(content, images_dir)
    print(processed)
