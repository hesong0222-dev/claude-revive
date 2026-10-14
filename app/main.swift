// Claude Revive: 로그인할 때 실행되어, 맥이 꺼지기 전에 일하던 클로드 앱 채팅에 "이어서 진행" 메시지를 보낸다.
import AppKit
import ApplicationServices

let message = "맥이 재시작되어 이 채팅의 작업이 중간에 끊겼습니다. 끊기기 전에 하던 작업을 확인하고 그대로 이어서 진행하세요. 예약 작업(크론·루프)이나 백그라운드 작업이 있었다면 다시 걸어 주세요."
let base = NSHomeDirectory() + "/.claude-revive"

func log(_ text: String) {
    let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let line = "\(f.string(from: Date())) \(text)\n"
    if let h = FileHandle(forWritingAtPath: base + "/revive.log") {
        h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); h.closeFile()
    } else {
        try? line.write(toFile: base + "/revive.log", atomically: true, encoding: .utf8)
    }
}

func shell(_ command: String) -> String {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/bin/bash")
    p.arguments = ["-c", command]
    let out = Pipe(); p.standardOutput = out
    try? p.run(); p.waitUntilExit()
    return String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
}

func press(_ key: CGKeyCode, command: Bool = false) {
    let src = CGEventSource(stateID: .hidSystemState)
    for down in [true, false] {
        let e = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: down)
        if command { e?.flags = .maskCommand }
        e?.post(tap: .cghidEventTap)
    }
}

let found = shell("\"\(base)/bin/claude-revive-find\"").split(separator: "\n").map(String.init)
if found.isEmpty { exit(0) }
log("끊긴 채팅 \(found.count)개")

// 손쉬운 사용 권한이 없으면 macOS 허용 창을 띄우고 멈춘다(허용 뒤 다음 로그인부터 동작).
let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
if !AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary) {
    log("손쉬운 사용 권한이 없어 중단. 기록은 revived/ 에 있음")
    exit(1)
}

// 네트워크가 잡힐 때까지 최대 5분 기다린 뒤 클로드 앱을 켠다.
_ = shell("for i in $(seq 60); do curl -s -m 3 -o /dev/null https://api.anthropic.com && break; sleep 5; done; open -a Claude")
sleep(15)

let pasteboard = NSPasteboard.general
let saved = pasteboard.string(forType: .string)
for sid in found {
    _ = shell("open 'claude://code/continue?session=\(sid)'")
    sleep(5)
    NSRunningApplication.runningApplications(withBundleIdentifier: "com.anthropic.claudefordesktop").first?.activate()
    usleep(500_000)
    pasteboard.clearContents(); pasteboard.setString(message, forType: .string)
    press(9, command: true)   // Cmd+V
    usleep(500_000)
    press(36)                 // Return
    log("깨움: \(sid)")
    sleep(3)
}
if let saved { pasteboard.clearContents(); pasteboard.setString(saved, forType: .string) }
