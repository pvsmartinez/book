#!/usr/bin/env python3
"""
Code Block Protector for Grammarly Workflow

This script handles code blocks (mermaid, math, etc.) that Word/Grammarly would corrupt:
- On EXPORT: Replaces code blocks with placeholders
- On IMPORT: Restores code blocks from the placeholder markers

Usage:
    python scripts/protect_code_blocks.py strip <input.md> <output.md>
    python scripts/protect_code_blocks.py restore <edited.md> <original.md> <output.md>
"""

import re
import sys
import json
import hashlib
from pathlib import Path

def generate_placeholder(content: str, index: int) -> str:
    """Generate a unique placeholder for a code block."""
    # Create a short hash for identification
    short_hash = hashlib.md5(content.encode()).hexdigest()[:8]
    return f"[CODE_BLOCK_{index}_{short_hash}]"

def strip_code_blocks(content: str) -> tuple[str, dict]:
    """
    Replace code blocks with placeholders.
    Returns (modified_content, block_map).
    """
    # Pattern for fenced code blocks (```language ... ```)
    pattern = r'(```\w*\n.*?\n```)'
    
    blocks = {}
    index = 0
    
    def replacer(match):
        nonlocal index
        block = match.group(1)
        placeholder = generate_placeholder(block, index)
        blocks[placeholder] = block
        index += 1
        return f"\n{placeholder}\n"
    
    modified = re.sub(pattern, replacer, content, flags=re.DOTALL)
    return modified, blocks

def strip_math_blocks(content: str) -> tuple[str, dict]:
    """
    Replace display math blocks ($$...$$) with placeholders.
    Returns (modified_content, block_map).
    """
    # Pattern for display math ($$...$$)
    pattern = r'(\$\$[^$]+\$\$)'
    
    blocks = {}
    index = 0
    
    def replacer(match):
        nonlocal index
        block = match.group(1)
        placeholder = f"[MATH_BLOCK_{index}]"
        blocks[placeholder] = block
        index += 1
        return f" {placeholder} "
    
    modified = re.sub(pattern, replacer, content, flags=re.DOTALL)
    return modified, blocks

def strip_all_blocks(input_path: Path, output_path: Path, manifest_path: Path):
    """Strip all code and math blocks, save manifest for restoration."""
    content = input_path.read_text(encoding='utf-8')
    
    # Strip code blocks first
    content, code_blocks = strip_code_blocks(content)
    
    # Strip math blocks
    content, math_blocks = strip_math_blocks(content)
    
    # Combine manifests
    manifest = {
        'code_blocks': code_blocks,
        'math_blocks': math_blocks
    }
    
    # Write output
    output_path.write_text(content, encoding='utf-8')
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    
    total = len(code_blocks) + len(math_blocks)
    print(f"✅ Stripped {len(code_blocks)} code blocks and {len(math_blocks)} math blocks")
    print(f"📄 Output: {output_path}")
    print(f"📋 Manifest: {manifest_path}")
    return total

def restore_blocks(edited_path: Path, manifest_path: Path, output_path: Path):
    """Restore code and math blocks from manifest."""
    content = edited_path.read_text(encoding='utf-8')
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    
    restored_count = 0
    
    # Restore code blocks
    for placeholder, block in manifest.get('code_blocks', {}).items():
        # Try original placeholder first
        if placeholder in content:
            content = content.replace(placeholder, block)
            restored_count += 1
        else:
            # Word/pandoc escapes brackets: [X] becomes \[X\]
            escaped_placeholder = placeholder.replace('[', '\\[').replace(']', '\\]')
            if escaped_placeholder in content:
                content = content.replace(escaped_placeholder, block)
                restored_count += 1
            else:
                print(f"⚠️  Warning: Placeholder not found: {placeholder[:50]}...")
    
    # Restore math blocks
    for placeholder, block in manifest.get('math_blocks', {}).items():
        if placeholder in content:
            content = content.replace(placeholder, block)
            restored_count += 1
        else:
            # Try escaped version
            escaped_placeholder = placeholder.replace('[', '\\[').replace(']', '\\]')
            if escaped_placeholder in content:
                content = content.replace(escaped_placeholder, block)
                restored_count += 1
            else:
                print(f"⚠️  Warning: Math placeholder not found: {placeholder}")
    
    output_path.write_text(content, encoding='utf-8')
    
    total = len(manifest.get('code_blocks', {})) + len(manifest.get('math_blocks', {}))
    print(f"✅ Restored {restored_count}/{total} blocks")
    print(f"📄 Output: {output_path}")
    return restored_count

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    action = sys.argv[1]
    
    if action == 'strip':
        if len(sys.argv) < 4:
            print("Usage: python protect_code_blocks.py strip <input.md> <output.md>")
            sys.exit(1)
        input_path = Path(sys.argv[2])
        output_path = Path(sys.argv[3])
        manifest_path = output_path.with_suffix('.manifest.json')
        strip_all_blocks(input_path, output_path, manifest_path)
    
    elif action == 'restore':
        if len(sys.argv) < 5:
            print("Usage: python protect_code_blocks.py restore <edited.md> <manifest.json> <output.md>")
            sys.exit(1)
        edited_path = Path(sys.argv[2])
        manifest_path = Path(sys.argv[3])
        output_path = Path(sys.argv[4])
        restore_blocks(edited_path, manifest_path, output_path)
    
    else:
        print(f"Unknown action: {action}")
        print("Use 'strip' or 'restore'")
        sys.exit(1)

if __name__ == "__main__":
    main()
