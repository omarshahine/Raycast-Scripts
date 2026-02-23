#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clean Clipboard (Single Line)
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Text Utils
# @raycast.icon ✂️

pbpaste | python3 - <<'PY' | pbcopy
import sys
import re

text = sys.stdin.read()

# Normalize line endings
text = text.replace('\r\n', '\n').replace('\r', '\n')

# Replace all line breaks/tabs with spaces, collapse repeated whitespace, trim
text = text.replace('\n', ' ').replace('\t', ' ')
text = re.sub(r'[ ]+', ' ', text).strip()

sys.stdout.write(text)
PY