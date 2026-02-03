#!/usr/bin/env python3
"""
Strip <details> blocks from manuscript files.

These blocks contain chapter outlines that are useful during drafting,
but interfere with Grammarly import/export workflow.

The content inside <details> is moved to 99_Compost/chapter_outlines/ for reference.
"""

import re
from pathlib import Path
from datetime import datetime

MANUSCRIPT_DIR = Path("03_Manuscript")
COMPOST_DIR = Path("99_Compost/chapter_outlines")

def extract_details_block(content: str) -> tuple[str, str | None]:
    """
    Extract and remove <details> block from content.
    Returns (cleaned_content, extracted_block).
    """
    # Pattern to match <details>...</details> block including content
    pattern = r'<details>\s*<summary><strong>([^<]+)</strong></summary>\s*(.*?)</details>\s*'
    
    match = re.search(pattern, content, re.DOTALL)
    
    if not match:
        return content, None
    
    summary_title = match.group(1)
    block_content = match.group(2).strip()
    
    # Create a markdown version of the extracted content
    extracted = f"# {summary_title}\n\n{block_content}"
    
    # Remove the details block from original
    cleaned = re.sub(pattern, '', content, flags=re.DOTALL)
    
    # Clean up any excessive newlines at the start
    cleaned = re.sub(r'^\n{3,}', '\n\n', cleaned)
    
    return cleaned, extracted

def main():
    COMPOST_DIR.mkdir(parents=True, exist_ok=True)
    
    print("🧹 Stripping <details> blocks from manuscript files")
    print("=" * 50)
    
    files_processed = 0
    files_with_details = 0
    
    for part_dir in sorted(MANUSCRIPT_DIR.glob("Part_*")):
        for md_file in sorted(part_dir.glob("*.md")):
            content = md_file.read_text(encoding='utf-8')
            
            if '<details>' not in content:
                continue
            
            files_with_details += 1
            
            cleaned, extracted = extract_details_block(content)
            
            if extracted:
                # Save the extracted outline to compost
                outline_file = COMPOST_DIR / f"{md_file.stem}_outline.md"
                outline_file.write_text(extracted, encoding='utf-8')
                print(f"📦 Saved outline: {outline_file.name}")
                
                # Update the original file
                md_file.write_text(cleaned, encoding='utf-8')
                print(f"✅ Cleaned: {md_file}")
                files_processed += 1
    
    print()
    print("=" * 50)
    print(f"📊 Summary:")
    print(f"   Files with <details>: {files_with_details}")
    print(f"   Files cleaned: {files_processed}")
    print(f"   Outlines saved to: {COMPOST_DIR}")

if __name__ == "__main__":
    main()
