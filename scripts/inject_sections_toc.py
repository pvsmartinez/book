#!/usr/bin/env python3
"""
inject_sections_toc.py — Post-process the manuscript HTML to inject
section entries into the Table of Contents.

The Markdown → HTML pipeline generates a TOC with H1 (Parts) and H2
(Chapters). Sections (Part IV Section A / Section B) live in raw HTML
<div class="section-page"> blocks — the TOC generator never sees them.

This script:
  1. Reads the generated HTML.
  2. Walks the body in document order to build a map of:
       section-page  →  list of chapter h2 ids that follow it (until the
                         next section-page or end of part).
  3. Inserts a styled <li class="toc-section-entry"> before the first
     chapter li in each section group inside the TOC <ul>.
  4. Writes the patched HTML back to the same file.

Usage:
    python scripts/inject_sections_toc.py path/to/output.html
"""

import re
import sys
from html.parser import HTMLParser


# ---------------------------------------------------------------------------
# 1. Parse the HTML body to get the document order of sections and chapters
# ---------------------------------------------------------------------------

class BodyWalker(HTMLParser):
    """
    Walk the HTML and collect, in document order:
      - section entries: {'type': 'section', 'label': 'Section A', 'title': 'The Consequences of Recursion'}
      - chapter entries: {'type': 'chapter', 'id': 'chapter-18-the-compound-effect'}
    """

    def __init__(self):
        super().__init__()
        self.sequence = []          # ordered list of section/chapter events
        self._in_section = False
        self._in_section_label = False
        self._in_section_title = False
        self._section_label = ""
        self._section_title = ""
        self._depth = 0             # generic tag depth counter
        self._section_div_depth = None  # depth at which the section-page div opened

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self._depth += 1

        # Detect <div class="section-page">
        if tag == "div" and "section-page" in attrs.get("class", ""):
            self._in_section = True
            self._section_label = ""
            self._section_title = ""
            self._section_div_depth = self._depth
            return

        if self._in_section:
            classes = attrs.get("class", "")
            if tag == "p" and "section-label" in classes:
                self._in_section_label = True
            elif tag == "h2" and "section-title" in classes:
                self._in_section_title = True

        # Detect <h2 id="..."> chapter headings (NOT section-title)
        if tag == "h2" and "id" in attrs:
            classes = attrs.get("class", "")
            if "section-title" not in classes:
                self.sequence.append({
                    "type": "chapter",
                    "id": attrs["id"]
                })

    def handle_endtag(self, tag):
        if self._in_section:
            if tag == "p" and self._in_section_label:
                self._in_section_label = False
            elif tag == "h2" and self._in_section_title:
                self._in_section_title = False
            elif tag == "div" and self._depth == self._section_div_depth:
                # Closing the section-page div
                self.sequence.append({
                    "type": "section",
                    "label": self._section_label.strip(),
                    "title": self._section_title.strip(),
                })
                self._in_section = False
                self._section_div_depth = None
        self._depth -= 1

    def handle_data(self, data):
        if self._in_section_label:
            self._section_label += data
        elif self._in_section_title:
            self._section_title += data


# ---------------------------------------------------------------------------
# 2. Build a mapping: chapter_id → section info (if inside a section)
# ---------------------------------------------------------------------------

def build_section_map(sequence):
    """
    Returns a dict: chapter_id → {'label': ..., 'title': ...}
    Only chapters that immediately follow a section marker are mapped.
    Once a new section or a new part starts, the mapping changes.
    """
    mapping = {}        # chapter_id → section info
    # We want: for each section, find the first chapter that follows it.
    # That chapter is where we'll insert the section entry in the TOC.
    # We track the "pending" section.
    pending_section = None
    first_chapter_in_section = {}  # section label → first chapter id

    for item in sequence:
        if item["type"] == "section":
            pending_section = item
        elif item["type"] == "chapter":
            if pending_section is not None:
                # This chapter is the first in a new section
                label = pending_section["label"]
                if label not in first_chapter_in_section:
                    first_chapter_in_section[label] = {
                        "chapter_id": item["id"],
                        "label": pending_section["label"],
                        "title": pending_section["title"],
                    }
                pending_section = None  # consumed

    return first_chapter_in_section


# ---------------------------------------------------------------------------
# 3. Inject section entries into the TOC HTML
# ---------------------------------------------------------------------------

def inject_into_toc(html, first_chapter_in_section):
    """
    For each section, find the <li> in the TOC that links to the first chapter
    of that section, and insert a <li class="toc-section-entry"> just before it.
    """
    if not first_chapter_in_section:
        return html

    for sec_info in first_chapter_in_section.values():
        chapter_id = sec_info["chapter_id"]
        label = sec_info["label"]
        title = sec_info["title"]

        # Build the section li HTML
        section_li = (
            f'<li class="toc-section-entry">'
            f'<span class="toc-section-label">{label}</span>'
            f'<span class="toc-section-title">{title}</span>'
            f'</li>\n'
        )

        # Find the <li> that contains a link to #{chapter_id}
        # Pattern: <li><a href="#chapter-18-...">...</a></li>  (may have nested content)
        pattern = re.compile(
            r'(<li>\s*<a\s+href="#' + re.escape(chapter_id) + r'")',
            re.IGNORECASE
        )
        html = pattern.sub(section_li + r'\1', html, count=1)

    return html


# ---------------------------------------------------------------------------
# 4. Main
# ---------------------------------------------------------------------------

def main():
    if len(sys.argv) < 2:
        print("Usage: inject_sections_toc.py <html_file>", file=sys.stderr)
        sys.exit(1)

    html_path = sys.argv[1]
    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()

    # Walk body
    walker = BodyWalker()
    walker.feed(html)
    sequence = walker.sequence

    if not sequence:
        print("   ℹ️  No sections or chapters found — TOC injection skipped.", file=sys.stderr)
        sys.exit(0)

    # Build map
    first_chapter_in_section = build_section_map(sequence)

    if not first_chapter_in_section:
        print("   ℹ️  No section→chapter mappings found — TOC injection skipped.", file=sys.stderr)
        sys.exit(0)

    print(f"   → Injecting {len(first_chapter_in_section)} section(s) into TOC...", file=sys.stderr)
    for sec in first_chapter_in_section.values():
        print(f"      • {sec['label']}: {sec['title']}  (before #{sec['chapter_id']})", file=sys.stderr)

    # Inject
    html = inject_into_toc(html, first_chapter_in_section)

    # Write back
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html)

    print("   ✅ TOC sections injected.", file=sys.stderr)


if __name__ == "__main__":
    main()
