#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Trimmy
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Text Utils
# @raycast.icon ✂️

# Arguments:
# @raycast.argument1 { "type": "text", "placeholder": "Mode: unwrap | deindent | single | both", "optional": true }

# MODE controls how the clipboard is cleaned:
#   unwrap   (default)  -> de-indent, then join soft-wrapped lines while preserving lists/paragraphs
#   deindent            -> remove common leading indentation, keep line breaks
#   single              -> flatten everything into one line
#   both                -> de-indent, then flatten into one line
MODE="${1:-unwrap}"

python3 - "$MODE" <<'PY'
import sys
import re
import subprocess

# ----------------------------
# Trimmy clipboard cleaner
# ----------------------------
#
# Modes:
#   unwrap   (default):
#       - Removes common indentation from all non-empty lines
#       - Joins "broken" / soft-wrapped lines (common in terminal/email output)
#       - Preserves blank lines (paragraphs) and list/header structure
#
#   deindent:
#       - Removes common indentation from all non-empty lines
#       - Preserves line breaks
#
#   single:
#       - Converts tabs/newlines to spaces
#       - Collapses repeated spaces
#       - Returns a single clean line
#
#   both:
#       - Runs deindent first
#       - Then flattens to a single line (like single, but after de-indenting)
#
# Behavior notes:
#   - Reads from macOS clipboard via pbpaste
#   - Writes result back to clipboard via pbcopy
#   - Designed for terminal output, copied logs, emails, and wrapped text

mode = (sys.argv[1] if len(sys.argv) > 1 else "unwrap").strip().lower()
if mode not in {"deindent", "single", "both", "unwrap"}:
    mode = "unwrap"

# Read clipboard directly (avoids stdin conflicts with heredoc scripts)
text = subprocess.run(["pbpaste"], capture_output=True, text=True).stdout

# Normalize line endings (Windows/macOS -> Unix)
text = text.replace("\r\n", "\n").replace("\r", "\n")


def flatten(s: str) -> str:
    """
    Flatten all text into a single line:
    - tabs -> spaces
    - newlines -> spaces
    - collapse repeated spaces
    - trim ends
    """
    s = s.replace("\t", " ").replace("\n", " ")
    return re.sub(r"[ ]+", " ", s).strip()


def deindent(s: str) -> str:
    """
    Remove common leading whitespace from all non-empty lines.

    Example:
        "    a\n    b\n    c" -> "a\nb\nc"

    Blank lines are preserved.
    Trailing whitespace on each line is removed.
    3+ blank lines are collapsed to 2.
    """
    lines = s.split("\n")

    # Find the smallest indentation shared by all non-empty lines
    indents = []
    for line in lines:
        if line.strip():
            m = re.match(r"^[ \t]*", line)
            indents.append(len(m.group(0)))

    common = min(indents) if indents else 0

    out = []
    for line in lines:
        if not line.strip():
            out.append("")
        else:
            out.append(line[common:].rstrip())

    # Preserve paragraph spacing, but avoid giant gaps
    return re.sub(r"\n{3,}", "\n\n", "\n".join(out))


def is_list_or_header(line: str) -> bool:
    """
    Heuristic for lines that should remain separate when unwrapping:
    - bullet lists: -, *, •
    - numbered lists: 1. / 1)
    - alpha lists: a. / a)
    - headings ending with ':'
    """
    s = line.lstrip()
    return bool(re.match(r"^([-*•]|\d+[.)]|[A-Za-z][.)])\s+", s)) or s.endswith(":")


def unwrap_lines(s: str) -> str:
    """
    Join soft-wrapped lines while preserving true structure.

    Rules:
    - Keep blank lines as paragraph breaks
    - Keep list items / headers on separate lines
    - Join lines when previous line does NOT end with sentence punctuation
      (., !, ?, :, ;)
    - Normalize spaces after joining
    """
    lines = s.split("\n")
    out = []

    for line in lines:
        cur = line.rstrip()

        if not out:
            out.append(cur)
            continue

        prev = out[-1]

        # Preserve paragraph breaks
        if prev.strip() == "" or cur.strip() == "":
            out.append(cur)
            continue

        # Preserve list/header structure
        if is_list_or_header(cur) or is_list_or_header(prev):
            out.append(cur)
            continue

        # If previous line does not look like a sentence end, treat as wrapped text
        if not re.search(r'[.!?:;]\s*$', prev):
            out[-1] = prev + " " + cur.lstrip()
        else:
            out.append(cur)

    # Final whitespace cleanup
    result = "\n".join(out)
    result = re.sub(r"[ \t]+", " ", result)
    result = re.sub(r" *\n *", "\n", result)
    result = re.sub(r"\n{3,}", "\n\n", result)
    return result.strip("\n")


# Dispatch by mode
if mode == "single":
    result = flatten(text)
elif mode == "both":
    result = flatten(deindent(text))
elif mode == "unwrap":
    result = unwrap_lines(deindent(text))
else:  # deindent
    result = deindent(text)

# Write cleaned text back to clipboard
subprocess.run(["pbcopy"], input=result, text=True)
PY