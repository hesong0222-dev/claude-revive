#!/bin/bash
# 설치: 스크립트 복사 → ~/.claude/settings.json 에 훅 추가 → "Claude Revive" 앱 만들기 → 로그인 때 실행 등록
set -e
command -v jq >/dev/null || { echo "jq가 필요합니다: brew install jq"; exit 1; }

src=$(cd "$(dirname "$0")" && pwd)
base="$HOME/.claude-revive"
settings="$HOME/.claude/settings.json"
app="$HOME/Applications/Claude Revive.app"
label="dev.claude-revive"
plist="$HOME/Library/LaunchAgents/$label.plist"

mkdir -p "$base/bin" "$HOME/.claude" "$HOME/Applications" "$HOME/Library/LaunchAgents"
cp "$src/bin/claude-revive-hook" "$src/bin/claude-revive-find" "$base/bin/"
chmod +x "$base/bin/"*

[ -f "$settings" ] || echo '{}' > "$settings"
cp "$settings" "$settings.bak-claude-revive"
jq --arg cmd "$base/bin/claude-revive-hook" '
  .hooks //= {} |
  reduce ("UserPromptSubmit", "Stop", "SessionEnd") as $e (.;
    .hooks[$e] = ((.hooks[$e] // []) | map(select((.hooks | tostring | contains("claude-revive-hook")) | not)))
                 + [{"hooks": [{"type": "command", "command": $cmd, "timeout": 5}]}])
' "$settings.bak-claude-revive" > "$settings"

rm -rf "$app"
"$src/app/build.sh" "$app"

cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key><array><string>/usr/bin/open</string><string>-a</string><string>$app</string></array>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
PLIST

echo "설치 완료. 다음 로그인부터 끊긴 채팅을 자동으로 깨웁니다."
echo "처음 한 번은 시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용에서 'Claude Revive'를 허용해 주세요."
echo "설정 백업: $settings.bak-claude-revive"
