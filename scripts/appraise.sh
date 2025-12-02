#!/bin/bash

# Appraisal Script
# Usage: ./scripts/appraise.sh

echo "=== Project Appraisal ==="
echo "Date: $(date)"
echo ""

echo "--- Git Status ---"
git status -s
echo ""

echo "--- Recent Activity (Last 5 commits) ---"
git log -n 5 --oneline
echo ""

echo "--- File Counts ---"
echo "Inbox: $(find 00_Inbox -type f | wc -l) items"
echo "Seeds: $(find 01_Seeds -type f | wc -l) seeds"
echo "Structure: $(find 02_Structure -type f | wc -l) documents"
echo "Manuscript: $(find 03_Manuscript -type f | wc -l) drafts"
echo ""

echo "--- Todo List (if any) ---"
# Simple grep for TODOs in markdown files
grep -r "TODO" . --include="*.md" | cut -c 1-100
echo ""

echo "=== End Appraisal ==="
