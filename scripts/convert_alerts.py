#!/usr/bin/env python3
"""Prints a Markdown file with its GitHub alerts (> [!WARNING] ...) turned into the site's
alert shortcode ({% alert(type="warning") %} ... {% end %}).

Usage: scripts/convert_alerts.py FILE
"""
import re
import sys


def convert_alerts(content):
    def replace_alert(match):
        alert_type = match.group(1).lower()
        body = match.group(2)
        body_clean = re.sub(r"^>\s?", "", body, flags=re.MULTILINE)
        return f'{{% alert(type="{alert_type}") %}}\n{body_clean}{{% end %}}\n'

    pattern = r">\s*\[!(NOTE|TIP|WARNING|IMPORTANT|CAUTION)\]\s*\n((?:>.*\n?)+)"
    return re.sub(pattern, replace_alert, content)


if __name__ == "__main__":
    with open(sys.argv[1], encoding="utf-8") as f:
        sys.stdout.write(convert_alerts(f.read()))
