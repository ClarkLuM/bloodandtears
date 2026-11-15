#!/bin/sh
# Copies the design system's CSS into the site. Run after `engine.py build` (from the repo root):  sh tools/ds-tokens.sh
# The light theme must win over the dark defaults when the page says data-theme="light", so the dark block is limited to
# pages that aren't set to light (the built file gives both blocks the same priority, and dark comes last).
sed 's/^:root, \[data-theme="dark"\] {/:root:not([data-theme="light"]), [data-theme="dark"] {/' opendesigner/build/css/tokens.css > public/ds-tokens.css
echo "public/ds-tokens.css updated"
