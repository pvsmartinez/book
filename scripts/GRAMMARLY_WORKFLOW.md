# Grammarly Workflow Guide

## Overview
This workflow allows you to use Grammarly to improve your manuscript while keeping your source markdown files as the source of truth.

## Prerequisites

**1. Install Pandoc** (converts between document formats):
```bash
brew install pandoc
```

**2. Install Grammarly Browser Extension** (Free):
- Chrome: [Grammarly for Chrome](https://chrome.google.com/webstore/detail/grammarly-for-chrome/kbfnbcaeplbcioakkpcpgfkobkghlhen)
- Safari: [Grammarly for Safari](https://apps.apple.com/app/grammarly-for-safari/id1462114288)
- Firefox: [Grammarly for Firefox](https://addons.mozilla.org/en-US/firefox/addon/grammarly-1/)

**3. Google Account** (Free) - for Google Docs

## The Workflow

### Step 1: Export for Grammarly
```bash
bash scripts/export_for_grammarly.sh
```

This will:
- Combine all your manuscript chapters into one Word document
- Save it to `07_Exports/grammarly_edit_[timestamp].docx`
- The file is ready for Grammarly

### Step 2: Edit with Grammarly

**Option A: Google Docs (Free, Recommended)**
1. Go to [Google Drive](https://drive.google.com)
2. Upload the exported `.docx` file
3. Right-click the file → "Open with" → "Google Docs"
4. Grammarly browser extension will automatically work (make sure it's installed)
5. Review and accept Grammarly's suggestions
6. **File** → **Download** → **Microsoft Word (.docx)**
7. Save with the same filename

**Option B: Microsoft Word (Paid)**
1. Open the exported `.docx` file in Microsoft Word
2. Grammarly will automatically analyze it (if you have the extension installed)
3. Review and accept Grammarly's suggestions
4. **Save the file** (keep the same filename)

### Step 3: Import Changes Back
```bash
bash scripts/smart_import_grammarly.sh 07_Exports/grammarly_edit_[timestamp].docx
```

This will:
- Convert the edited Word document back to markdown
- Create a backup of your current manuscript
- Provide you with the converted file for comparison

### Step 4: Review and Apply Changes
The script will show you how to compare files. Use VS Code's compare feature:

**Option A: VS Code Compare**
1. Open your original chapter (e.g., `12_the_competitors_meta.md`)
2. Right-click → "Select for Compare"
3. Open the converted file
4. Right-click → "Compare with Selected"
5. Review changes side-by-side
6. Copy the grammar improvements you want

**Option B: Command Line Diff**
```bash
diff -u 03_Manuscript/Part_III/12_the_competitors_meta.md 07_Exports/temp_import_*/converted.md
```

## What Grammarly Typically Fixes
✅ **Good changes to adopt:**
- Comma placement and punctuation
- Subject-verb agreement
- Awkward phrasing
- Word choice improvements
- Clarity enhancements

⚠️ **Be careful with:**
- Structural changes (Grammarly might reorder things)
- Markdown formatting (may get corrupted)
- Intentional stylistic choices (your conversational voice)
- Technical terms (Grammarly might not understand game design vocabulary)

## Safety Features
- **Automatic backups**: Every import creates a backup in `07_Exports/backups_[timestamp]/`
- **Manual review**: Changes are NOT automatically applied - you choose what to keep
- **Git tracking**: All changes can be reviewed with `git diff`

## Tips
1. **Export frequently**: Do small batches (one part at a time) rather than the whole book
2. **Focus on grammar**: Accept punctuation and clarity fixes, but preserve your voice
3. **Keep structure**: If Grammarly suggests restructuring, ignore it - the structure is intentional
4. **Use git**: Commit before importing so you can easily revert if needed

## Alternative: Export Single Chapters

To export just one chapter:
```bash
pandoc 03_Manuscript/Part_III/12_the_competitors_meta.md -o 07_Exports/chapter_12.docx
```

Edit it, then:
```bash
pandoc 07_Exports/chapter_12.docx -o 07_Exports/chapter_12_edited.md --wrap=none
code --diff 03_Manuscript/Part_III/12_the_competitors_meta.md 07_Exports/chapter_12_edited.md
```

## Troubleshooting

**"pandoc: command not found"**
- Install: `brew install pandoc`

**"File not found"**
- Make sure you're running from the book's root directory
- Check that the filename matches exactly

**Markdown formatting is broken**
- This is expected - Word doesn't perfectly preserve markdown
- Focus on text improvements, not formatting
- Use the diff view to s (Google Docs)
```bash
# 1. Export
bash scripts/export_for_grammarly.sh
# Output: 07_Exports/grammarly_edit_20260130_143022.docx

# 2. Upload to Google Drive
# - Go to drive.google.com
# - Click "New" → "File upload"
# - Upload: 07_Exports/grammarly_edit_20260130_143022.docx

# 3. Edit in Google Docs
# - Right-click file → "Open with" → "Google Docs"
# - Grammarly will highlight suggestions automatically
# - Review and apply changes
# - File → Download → Microsoft Word (.docx)
# - Save to: 07_Exports/grammarly_edit_20260130_143022.docx (same name)

# 4. Import back
bash scripts/smart_import_grammarly.sh 07_Exports/grammarly_edit_20260130_143022.docx

# 5. Review in VS Code
code --diff 03_Manuscript/Part_III/12_the_competitors_meta.md 07_Exports/temp_import_*/converted.md

# 6. Manually copy the good changes

# 7h scripts/smart_import_grammarly.sh 07_Exports/grammarly_edit_20260130_143022.docx

# 4. Review in VS Code
code --diff 03_Manuscript/Part_III/12_the_competitors_meta.md 07_Exports/temp_import_*/converted.md

# 5. Manually copy the good changes

# 6. Commit
git add .
git commit -m "Apply Grammarly grammar improvements to Part III"
```
