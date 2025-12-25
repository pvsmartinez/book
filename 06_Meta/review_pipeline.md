# Review Pipeline & Feedback Loop

**Status:** Active
**Purpose:** To process reviews of exported artifacts (PDFs) without interrupting the reading flow.

## The Workflow

### 1. Export & Read
*   The user exports the current manuscript (or part of it) to PDF.
*   The user reads the PDF on a separate device or window (e.g., tablet, e-reader).

### 2. Capture (The "Reviewer Mode")
*   **Action:** The user takes notes *about* the text, not *in* the text.
*   **Format:**
    *   **Voice Notes:** Dictated observations (e.g., "Chapter 3, paragraph 2 feels clunky. Rewrite to be more punchy.").
    *   **Text Notes:** A simple Markdown file in `08_Feedback/` (e.g., `review_2025-12-25_part1.md`).
*   **Content:**
    *   Typos/Grammar.
    *   Flow/Pacing issues.
    *   "This section is boring."
    *   "Expand on this idea."
    *   "Move this to Chapter X."

### 3. Processing (The "Editor Mode")
*   **Trigger:** User asks AI to "Process the review notes."
*   **AI Role:**
    1.  Read the specified file in `08_Feedback/` (or `00_Inbox` if it was a voice dump).
    2.  Locate the corresponding sections in `03_Manuscript/`.
    3.  Apply the changes or ask for clarification if the note is vague.
    4.  Mark the review items as [Done] in the feedback file.

## File Naming Convention
*   Store feedback in `08_Feedback/`.
*   Format: `YYYY-MM-DD_Review_[Topic/Version].md`
    *   Example: `2025-12-25_Review_Part_III.md`

## Guidelines for AI
*   **Do not** overwrite the manuscript blindly. If a review note says "Rewrite this," propose the rewrite first or apply it if it's a simple fix.
*   **Preserve Context:** When applying changes, ensure the surrounding text still flows.
*   **Track Progress:** If a review file is large, process it in chunks and update the review file to show what has been handled.
