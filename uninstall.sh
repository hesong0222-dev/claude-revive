#!/bin/bash
# 제거: 훅 삭제, 로그인 실행 해제, 앱·파일 삭제
set -e
settings="$HOME/.claude/settings.json"
if [ -f "$settings" ]; then
  tmp=$(mktemp)
  jq 'if .hooks then .hooks |= (with_entries(.value |= map(select((.hooks | tostring | contains("claude-revive-hook")) | not))) | with_entries(select(.value | length > 0))) else . end' "$settings" > "$tmp" && mv "$tmp" "$settings"
fi
rm -f "$HOME/Library/LaunchAgents/dev.claude-revive.plist"
rm -rf "$HOME/Applications/Claude Revive.app" "$HOME/.claude-revive"
echo "제거 완료."
