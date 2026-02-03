#!/usr/bin/env python3
"""
Apply Grammarly Diff Tool

This script takes a Grammarly-edited markdown file (converted from .docx),
compares each chapter with the original manuscript files, and applies the changes.

Usage:
    python scripts/apply_grammarly_diff.py <imported_markdown_file>
    python scripts/apply_grammarly_diff.py 07_Exports/temp_imported.md
    python scripts/apply_grammarly_diff.py 07_Exports/temp_imported.md --dry-run
    python scripts/apply_grammarly_diff.py 07_Exports/temp_imported.md --interactive
"""

import re
import os
import sys
import argparse
import difflib
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# ANSI colors for terminal output
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def colorize(text: str, color: str) -> str:
    return f"{color}{text}{Colors.RESET}"

# Directory configuration
MANUSCRIPT_DIR = Path("03_Manuscript")
BACKUP_DIR = Path("07_Exports/backups")

def parse_imported_file(filepath: Path) -> Dict[str, str]:
    """
    Parse the imported markdown file and split by chapters.
    Returns a dict mapping chapter titles to their content.
    """
    content = filepath.read_text(encoding='utf-8')
    
    # Pattern to match chapter headers (## Preface:, ## Chapter X:, ## Interlude:, etc.)
    # Also match sections starting with just ## followed by title
    chapter_pattern = r'^(## (?:Preface|Chapter \d+|Interlude)[^\n]*|^## [A-Z][^\n]*)'
    
    chapters = {}
    
    # Split by chapter headers while keeping the delimiter
    parts = re.split(f'({chapter_pattern})', content, flags=re.MULTILINE)
    
    current_title = None
    current_content = []
    
    for part in parts:
        if not part.strip():
            continue
            
        # Check if this is a chapter header
        if re.match(r'^## ', part):
            # Save previous chapter if exists
            if current_title:
                chapters[current_title] = '\n'.join(current_content).strip()
            
            current_title = part.strip()
            current_content = [part]
        elif current_title:
            current_content.append(part)
    
    # Save last chapter
    if current_title:
        chapters[current_title] = '\n'.join(current_content).strip()
    
    return chapters

def find_manuscript_files() -> Dict[str, Path]:
    """
    Scan manuscript directories and map chapter titles to file paths.
    Returns a dict mapping chapter titles (from ## headers) to file paths.
    """
    files = {}
    
    for part_dir in sorted(MANUSCRIPT_DIR.glob("Part_*")):
        for md_file in sorted(part_dir.glob("*.md")):
            content = md_file.read_text(encoding='utf-8')
            
            # Find the first ## header in the file
            match = re.search(r'^(## [^\n]+)', content, re.MULTILINE)
            if match:
                title = match.group(1).strip()
                files[title] = md_file
    
    return files

def normalize_for_comparison(text: str) -> str:
    """
    Normalize text for comparison by removing formatting artifacts
    that Grammarly/Word might introduce.
    """
    # Remove Windows line endings
    text = text.replace('\r\n', '\n')
    
    # Normalize dashes (Word often converts -- to em dashes)
    text = text.replace('\u2014', '---')  # em dash U+2014
    text = text.replace('\u2013', '--')   # en dash U+2013
    
    # Normalize all quote variants to ASCII
    # Double quotes
    text = text.replace('\u201c', '"')  # U+201C LEFT DOUBLE QUOTATION MARK
    text = text.replace('\u201d', '"')  # U+201D RIGHT DOUBLE QUOTATION MARK
    # Single quotes / apostrophes  
    text = text.replace('\u2018', "'")  # U+2018 LEFT SINGLE QUOTATION MARK
    text = text.replace('\u2019', "'")  # U+2019 RIGHT SINGLE QUOTATION MARK (common apostrophe)
    text = text.replace('`', "'")       # backtick to apostrophe
    
    # Normalize bullet points (Word might change them)
    text = re.sub(r'^[\u2022\u25e6\u25aa] ', '- ', text, flags=re.MULTILINE)
    
    # Fix escaped characters from pandoc
    text = text.replace('\\*', '*')
    text = text.replace('\\>', '>')
    text = text.replace('\\-', '-')
    
    # Fix collapsed bullet lists (pandoc sometimes puts them on one line)
    text = re.sub(r' \* ', '\n* ', text)
    
    # Normalize list markers to consistent style: "- " 
    text = re.sub(r'^\*\s+', '- ', text, flags=re.MULTILINE)
    
    # Normalize horizontal rules (Word makes them long)
    text = re.sub(r'^-{3,}$', '---', text, flags=re.MULTILINE)
    
    # Normalize multiple newlines to max 2
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    # Strip trailing whitespace from each line
    text = '\n'.join(line.rstrip() for line in text.splitlines())
    
    return text.strip()

def show_diff(original: str, edited: str, title: str) -> Tuple[bool, str]:
    """
    Show a colored diff between original and edited text.
    Returns (has_changes, diff_string).
    """
    orig_lines = original.splitlines(keepends=True)
    edit_lines = edited.splitlines(keepends=True)
    
    diff = list(difflib.unified_diff(
        orig_lines, 
        edit_lines, 
        fromfile=f"original/{title}",
        tofile=f"grammarly/{title}",
        lineterm=''
    ))
    
    if not diff:
        return False, ""
    
    # Colorize the diff output
    colored_lines = []
    for line in diff:
        if line.startswith('+++'):
            colored_lines.append(colorize(line.rstrip(), Colors.BOLD + Colors.GREEN))
        elif line.startswith('---'):
            colored_lines.append(colorize(line.rstrip(), Colors.BOLD + Colors.RED))
        elif line.startswith('@@'):
            colored_lines.append(colorize(line.rstrip(), Colors.CYAN))
        elif line.startswith('+'):
            colored_lines.append(colorize(line.rstrip(), Colors.GREEN))
        elif line.startswith('-'):
            colored_lines.append(colorize(line.rstrip(), Colors.RED))
        else:
            colored_lines.append(line.rstrip())
    
    return True, '\n'.join(colored_lines)

def create_backup(filepath: Path) -> Path:
    """Create a backup of a file before modifying it."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = BACKUP_DIR / timestamp / filepath.relative_to(Path.cwd())
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    
    import shutil
    shutil.copy2(filepath, backup_path)
    return backup_path

def apply_changes(filepath: Path, new_content: str, dry_run: bool = False) -> bool:
    """
    Apply changes to a manuscript file.
    Returns True if changes were applied.
    """
    if dry_run:
        print(f"  {colorize('[DRY RUN]', Colors.YELLOW)} Would update: {filepath}")
        return False
    
    # Create backup first
    backup = create_backup(filepath)
    print(f"  {colorize('📦 Backup:', Colors.BLUE)} {backup}")
    
    # Write new content
    filepath.write_text(new_content, encoding='utf-8')
    print(f"  {colorize('✅ Updated:', Colors.GREEN)} {filepath}")
    return True

def main():
    parser = argparse.ArgumentParser(
        description='Apply Grammarly edits back to manuscript files'
    )
    parser.add_argument('input_file', help='The imported markdown file from Grammarly')
    parser.add_argument('--dry-run', '-n', action='store_true', 
                        help='Show what would be changed without applying')
    parser.add_argument('--interactive', '-i', action='store_true',
                        help='Ask before applying each change')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Show full diffs')
    
    args = parser.parse_args()
    
    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f"{colorize('❌ Error:', Colors.RED)} File not found: {input_path}")
        sys.exit(1)
    
    print(f"\n{colorize('🔍 Grammarly Diff Applier', Colors.BOLD + Colors.CYAN)}")
    print("=" * 50)
    print(f"📄 Input: {input_path}")
    print(f"📁 Manuscript: {MANUSCRIPT_DIR}")
    if args.dry_run:
        print(f"{colorize('⚠️  DRY RUN MODE - No changes will be made', Colors.YELLOW)}")
    print()
    
    # Parse the imported file
    print(f"{colorize('📖 Parsing imported file...', Colors.BLUE)}")
    imported_chapters = parse_imported_file(input_path)
    print(f"   Found {len(imported_chapters)} chapters/sections")
    
    # Find manuscript files
    print(f"{colorize('📂 Scanning manuscript files...', Colors.BLUE)}")
    manuscript_files = find_manuscript_files()
    print(f"   Found {len(manuscript_files)} chapter files")
    print()
    
    # Match and compare
    matches = 0
    changes = 0
    applied = 0
    skipped = 0
    
    print(f"{colorize('🔄 Comparing chapters...', Colors.BOLD)}\n")
    
    for title, imported_content in imported_chapters.items():
        # Try to find matching manuscript file
        if title not in manuscript_files:
            # Try fuzzy matching - the title might be slightly different
            best_match = None
            best_ratio = 0
            for ms_title in manuscript_files.keys():
                ratio = difflib.SequenceMatcher(None, title, ms_title).ratio()
                if ratio > best_ratio and ratio > 0.7:
                    best_ratio = ratio
                    best_match = ms_title
            
            if best_match:
                print(f"{colorize('⚠️', Colors.YELLOW)} Fuzzy match: '{title}' → '{best_match}'")
                title = best_match
            else:
                print(f"{colorize('❓', Colors.YELLOW)} No match found for: {title[:50]}...")
                skipped += 1
                continue
        
        matches += 1
        filepath = manuscript_files[title]
        original_content = filepath.read_text(encoding='utf-8')
        
        # Normalize both for comparison
        norm_original = normalize_for_comparison(original_content)
        norm_imported = normalize_for_comparison(imported_content)
        
        # Check for actual content differences
        has_changes, diff_output = show_diff(norm_original, norm_imported, title)
        
        if not has_changes:
            print(f"{colorize('✓', Colors.GREEN)} {title[:50]}... {colorize('(no changes)', Colors.BLUE)}")
            continue
        
        changes += 1
        print(f"\n{colorize('📝', Colors.YELLOW)} {colorize(title, Colors.BOLD)}")
        print(f"   File: {filepath}")
        
        if args.verbose:
            print(f"\n{diff_output}\n")
        else:
            # Show summary of changes
            orig_lines = norm_original.splitlines()
            edit_lines = norm_imported.splitlines()
            added = len([l for l in edit_lines if l not in orig_lines])
            removed = len([l for l in orig_lines if l not in edit_lines])
            print(f"   {colorize(f'+{added}', Colors.GREEN)} / {colorize(f'-{removed}', Colors.RED)} lines changed")
        
        # Interactive mode
        should_apply = True
        if args.interactive:
            if not args.verbose:
                # Show diff if not already shown
                print(f"\n{diff_output}\n")
            
            while True:
                response = input(f"   Apply changes? [y/n/v(view full)/q(quit)]: ").lower().strip()
                if response == 'y':
                    should_apply = True
                    break
                elif response == 'n':
                    should_apply = False
                    break
                elif response == 'v':
                    print(f"\n{diff_output}\n")
                elif response == 'q':
                    print("\n👋 Quitting...")
                    sys.exit(0)
        
        if should_apply:
            if apply_changes(filepath, norm_imported + '\n', args.dry_run):
                applied += 1
    
    # Summary
    print(f"\n{'=' * 50}")
    print(f"{colorize('📊 Summary:', Colors.BOLD)}")
    print(f"   Chapters matched: {matches}")
    print(f"   Chapters with changes: {changes}")
    print(f"   Changes applied: {applied}")
    print(f"   Skipped (no match): {skipped}")
    
    if args.dry_run and changes > 0:
        print(f"\n{colorize('💡 Tip:', Colors.CYAN)} Run without --dry-run to apply changes")
        print(f"   Or use --interactive to review each change")
    
    if applied > 0:
        print(f"\n{colorize('✅ Done!', Colors.GREEN)} Backups saved to: {BACKUP_DIR}")

if __name__ == "__main__":
    main()
