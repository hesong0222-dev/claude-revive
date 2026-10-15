<p align="center"><img src="assets/mascot.png" width="160"></p>

# Claude Revive

맥이 갑자기 꺼지거나 재시작돼도, **클로드 코드 앱에서 일하던 채팅을 기억했다가 다시 깨워** 하던 일을 이어서 하게 해 주는 작은 도구입니다.

> 🧪 시험판입니다. 동작 확인은 macOS 26 + Claude 데스크톱 앱(Code 탭)에서만 했습니다.

## 어떻게 동작하나요

1. **기록** — 클로드 코드 훅이 "일하는 중"인 채팅을 `~/.claude-revive/busy/`에 적어 두고, 일이 끝나면 지웁니다.
   - 답은 끝났어도 예약 작업(크론·루프)이나 백그라운드 작업이 남아 있으면 계속 "일하는 중"으로 봅니다.
   - `/exit`·`/clear`처럼 직접 끝낸 채팅은 지웁니다. 앱 종료·전원 꺼짐은 남겨 둡니다.
2. **찾기** — 로그인하면 `Claude Revive` 앱이 자동으로 실행되어, 부팅 전에 일하다 끊긴 채팅만 골라냅니다.
3. **깨우기** — 클로드 앱을 켜고 그 채팅들을 하나씩 열어 "재시작돼서 끊겼으니 이어서 진행하세요" 메시지를 보냅니다.

| 상황 | 동작 |
|---|---|
| 강제 종료, 전원 꺼짐, 커널 패닉 | ✅ 다음 로그인 때 깨움 |
| 일하는 중 메뉴에서 재시작·종료 | ✅ 다음 로그인 때 깨움 |
| 일을 다 끝내고 쉬던 채팅 | 깨우지 않음 |
| 맥은 켜진 채 클로드 앱만 튕김 | ❌ 아직 미지원 |

## 설치

필요한 것: macOS, Claude 데스크톱 앱, `jq`(macOS 15 이상 기본 포함), Xcode 명령줄 도구(`swiftc`).

```bash
git clone https://github.com/hesong0222-dev/claude-revive.git
cd claude-revive
./install.sh
```

설치 뒤 **시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용**에서 `Claude Revive`를 켜 주세요(메시지 입력에 필요).
`~/.claude/settings.json`은 `settings.json.bak-claude-revive`로 백업한 뒤 훅만 추가합니다.

## 제거

```bash
./uninstall.sh
```

## 깨울 때 보내는 메시지 바꾸기

`app/main.swift`의 `message`를 고치고 `./install.sh`를 다시 실행하세요.

---

**English:** Claude Revive remembers which Claude Code (desktop app) chats were working when your Mac shut down or crashed, and on next login reopens them and sends a "continue where you left off" message. Experimental; macOS only.

MIT License · 만든 사람: [개발새발자](https://x.com/ComAsNas)
