#!/bin/bash
# Install libraries needed for this project
# Runs at SessionStart — only in remote environments

# Only run in remote environments
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi

echo "=== Installing Libraries ==="

# mmk: Magic Meal Kits CLI (YouTube transcript, metadata, etc.)
if command -v mmk >/dev/null 2>&1; then
  echo "mmk       : $(mmk version 2>/dev/null || echo 'installed') (already installed)"
else
  echo "mmk       : installing..."
  npm install -g @magic-meal-kits/cli 2>/dev/null || {
    echo "mmk       : FAILED (npm not available)"
    echo "=== Done ==="
    exit 0
  }
  echo "mmk       : $(mmk version 2>/dev/null || echo 'installed')"
fi

# jq: JSON 파싱 (youtube-fetch, stock-monitor 스킬에서 사용)
if command -v jq >/dev/null 2>&1; then
  echo "jq        : $(jq --version 2>/dev/null || echo 'installed') (already installed)"
else
  echo "jq        : installing..."
  apt-get install -y -qq jq 2>/dev/null || {
    echo "jq        : FAILED (apt-get not available)"
  }
fi

# curl: Slack Webhook 전송용 (기본 설치 여부 확인)
if command -v curl >/dev/null 2>&1; then
  echo "curl      : $(curl --version 2>/dev/null | head -1 | cut -d' ' -f2) (already installed)"
else
  echo "curl      : FAILED (not available)"
fi

# python3: YouTube RSS 파싱용 (기본 설치 여부 확인)
if command -v python3 >/dev/null 2>&1; then
  echo "python3   : $(python3 --version 2>/dev/null | cut -d' ' -f2) (already installed)"
else
  echo "python3   : FAILED (not available)"
fi

echo "=== Done ==="
exit 0
