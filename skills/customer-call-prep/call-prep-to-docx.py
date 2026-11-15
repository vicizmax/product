"""Generate a customer call prep DOCX from a JSON payload.

Usage:
    uv run --with python-docx python call-prep-to-docx.py <input.json> <output.docx>

Or pass JSON via stdin and output path as the only argument:
    cat brief.json | uv run --with python-docx python call-prep-to-docx.py - <output.docx>

The output DOCX uploads cleanly to Google Drive — right-click → "Open with Google Docs"
preserves headings, tables, lists, bold, and italic formatting.

JSON schema (all fields optional; missing sections are skipped):
{
  "company": "Acme Corp",
  "meeting_date": "Monday, 1 June 2026, 14:00 CET",
  "call_type": "Quarterly business review",
  "attendees": {
    "internal": ["Name (Role)", ...],
    "customer": ["Name (Role)", ...]
  },
  "account_snapshot": {
    "fields": [["Size", "..."], ["Plan", "..."], ...],
    "health_pill": "At risk"  // optional, appears as a bracketed label after section title
  },
  "usage": ["bullet 1", "bullet 2", ...],
  "relationship_history": {
    "past_calls": [["YYYY-MM-DD", "summary"], ...],
    "email_threads": ["subject — sender, when", ...],
    "jira_tickets": ["KEY title status", ...]
  },
  "what_we_know": ["bullet 1", ...],
  "hypotheses": ["hypothesis 1", "hypothesis 2", ...],
  "open_questions": ["question 1", "question 2", ...],
  "interview_arc": [["Opening (3 min)", "description"], ...],
  "handle_with_care": "single paragraph",
  "sources": {
    "pulled": ["Glean", "Zoom", ...],
    "missing": ["Mixpanel", ...]
  }
}
"""

from __future__ import annotations

import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

from docx import Document
from docx.shared import Pt, RGBColor


# --- styling helpers --------------------------------------------------------

def add_heading_with_pill(doc, text, pill_text=None, pill_color_hex="C00000"):
    h = doc.add_heading(text, level=2)
    if pill_text:
        run = h.add_run(f"  [{pill_text}]")
        run.bold = True
        run.font.color.rgb = RGBColor.from_string(pill_color_hex)
        run.font.size = Pt(11)


def add_kv_table(doc, rows):
    """Two-column key-value table."""
    if not rows:
        return
    table = doc.add_table(rows=len(rows), cols=2)
    table.style = "Light Grid Accent 1"
    for i, (key, val) in enumerate(rows):
        cells = table.rows[i].cells
        cells[0].text = str(key)
        for run in cells[0].paragraphs[0].runs:
            run.bold = True
        cells[1].text = str(val)


def add_bullets(doc, items, style="List Bullet"):
    for item in items:
        doc.add_paragraph(str(item), style=style)


def add_numbered(doc, items):
    add_bullets(doc, items, style="List Number")


# --- main generator ---------------------------------------------------------

def build_doc(data: dict, output_path: str):
    doc = Document()

    # --- Title block ---
    company = data.get("company", "[Customer]")
    doc.add_heading(f"Customer Call Prep — {company}", level=1)

    meta_lines = []
    if data.get("meeting_date"):
        meta_lines.append(("Date", data["meeting_date"]))
    if data.get("call_type"):
        meta_lines.append(("Call type", data["call_type"]))
    attendees = data.get("attendees") or {}
    if attendees.get("internal"):
        meta_lines.append(("Attendees (internal)", ", ".join(attendees["internal"])))
    if attendees.get("customer"):
        meta_lines.append(("Attendees (customer)", ", ".join(attendees["customer"])))
    if meta_lines:
        meta_p = doc.add_paragraph()
        for i, (label, value) in enumerate(meta_lines):
            if i > 0:
                meta_p.add_run("\n")
            meta_p.add_run(f"{label}: ").bold = True
            meta_p.add_run(str(value))

    # --- 1. Account snapshot ---
    snapshot = data.get("account_snapshot") or {}
    if snapshot.get("fields"):
        add_heading_with_pill(
            doc, "1. Account snapshot",
            pill_text=snapshot.get("health_pill"),
        )
        add_kv_table(doc, snapshot["fields"])

    # --- 2. Usage at a glance ---
    if data.get("usage"):
        doc.add_heading("2. Usage at a glance", level=2)
        add_bullets(doc, data["usage"])

    # --- 3. Relationship history ---
    rel = data.get("relationship_history") or {}
    if rel.get("past_calls") or rel.get("email_threads") or rel.get("jira_tickets"):
        doc.add_heading("3. Relationship history", level=2)

        if rel.get("past_calls"):
            doc.add_heading("Past calls", level=3)
            for date, summary in rel["past_calls"]:
                p = doc.add_paragraph(style="List Bullet")
                p.add_run(str(date)).bold = True
                p.add_run(f" — {summary}")

        if rel.get("email_threads"):
            doc.add_heading("Recent email threads", level=3)
            add_bullets(doc, rel["email_threads"])

        if rel.get("jira_tickets"):
            doc.add_heading("Jira tickets", level=3)
            add_bullets(doc, rel["jira_tickets"])

    # --- 4. What we already know ---
    if data.get("what_we_know"):
        doc.add_heading("4. What we already know", level=2)
        add_bullets(doc, data["what_we_know"])

    # --- 5. Hypotheses ---
    if data.get("hypotheses"):
        doc.add_heading("5. Hypotheses going in", level=2)
        add_numbered(doc, data["hypotheses"])

    # --- 6. Open questions ---
    if data.get("open_questions"):
        doc.add_heading("6. Open questions to probe", level=2)
        add_bullets(doc, data["open_questions"])

    # --- 7. Suggested interview arc ---
    if data.get("interview_arc"):
        doc.add_heading("7. Suggested interview arc", level=2)
        for label, text in data["interview_arc"]:
            p = doc.add_paragraph(style="List Bullet")
            p.add_run(f"{label}:").bold = True
            p.add_run(f" {text}")

    # --- 8. Handle with care ---
    if data.get("handle_with_care"):
        doc.add_heading("8. Handle with care", level=2)
        p = doc.add_paragraph()
        run = p.add_run(str(data["handle_with_care"]))
        run.italic = True

    # --- Footer: sources ---
    sources = data.get("sources") or {}
    if sources.get("pulled") or sources.get("missing"):
        doc.add_paragraph("─" * 60)
        footer = doc.add_paragraph()
        parts = []
        if sources.get("pulled"):
            parts.append(f"Sources pulled: {', '.join(sources['pulled'])}.")
        if sources.get("missing"):
            parts.append(f"Missing / empty: {', '.join(sources['missing'])}.")
        run = footer.add_run(" ".join(parts))
        run.italic = True
        run.font.size = Pt(9)

    # Atomic write: save to a temp file on local disk, then move to the final
    # destination. python-docx writes a ZIP (the .docx) in streaming fashion —
    # entries first, central directory last. Writing directly into a Google
    # Drive-synced folder can produce a truncated ZIP (missing End-of-Central-
    # Directory record) because Drive sync may snapshot partial bytes before
    # save() finishes. Saving to /tmp and then moving guarantees Drive only
    # ever sees a complete file.
    tmp_fd, tmp_path = tempfile.mkstemp(suffix=".docx", prefix="call-prep-", dir="/tmp")
    os.close(tmp_fd)
    try:
        doc.save(tmp_path)
        shutil.move(tmp_path, output_path)
    finally:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)


def main():
    if len(sys.argv) < 3:
        print(
            "Usage: python call-prep-to-docx.py <input.json|-> <output.docx>",
            file=sys.stderr,
        )
        sys.exit(2)

    input_arg = sys.argv[1]
    output_path = sys.argv[2]

    if input_arg == "-":
        data = json.load(sys.stdin)
    else:
        with open(input_arg, "r", encoding="utf-8") as f:
            data = json.load(f)

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    build_doc(data, output_path)
    print(f"DOCX saved: {output_path}")


if __name__ == "__main__":
    main()
