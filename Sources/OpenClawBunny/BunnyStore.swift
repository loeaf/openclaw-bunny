import Foundation
import SwiftUI

@MainActor
final class BunnyStore: ObservableObject {
    @Published var snapshot: BunnySnapshot = .empty
    @Published var loadScore: Int = 0
    @Published var menuIcon: String = "🐇💤"

    private var pollTask: Task<Void, Never>?
    private var iconTask: Task<Void, Never>?
    private var frameIndex: Int = 0

    private let idleFrames = ["🐇💤", "🐇"]
    private let workFrames = ["🐇", "🐇💨"]
    private let busyFrames = ["🐇💨", "💨🐇", "🐇⚡️"]

    var statusFilePath: String {
        if let override = ProcessInfo.processInfo.environment["OPENCLAW_BUNNY_STATUS_FILE"], !override.isEmpty {
            return override
        }
        return NSString(string: "~/.openclaw/workspace/openclaw-bunny-status.json").expandingTildeInPath
    }

    func start() {
        guard pollTask == nil else { return }

        pollTask = Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(2))
            }
        }

        iconTask = Task {
            while !Task.isCancelled {
                tickIcon()
                let delay = iconDelay(for: loadScore)
                try? await Task.sleep(for: .milliseconds(delay))
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        iconTask?.cancel()
        pollTask = nil
        iconTask = nil
    }

    func refresh() async {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: statusFilePath))
            let decoded = try JSONDecoder().decode(BunnySnapshot.self, from: data)
            snapshot = decoded
            loadScore = computeLoad(from: decoded)
        } catch {
            snapshot = BunnySnapshot(
                updatedAt: nil,
                bots: [
                    BotState(name: "main", status: .idle, currentKeyword: "상태 파일 대기중", pendingKeywords: [])
                ]
            )
            loadScore = 0
        }
    }

    private func computeLoad(from snapshot: BunnySnapshot) -> Int {
        snapshot.bots.reduce(0) { partial, bot in
            let base: Int
            switch bot.status {
            case .idle: base = 0
            case .working: base = 2
            case .busy: base = 4
            case .blocked, .error: base = 1
            }
            return partial + base + min(bot.pendingKeywords.count, 10)
        }
    }

    private func iconDelay(for score: Int) -> UInt64 {
        if score <= 0 { return 1000 }
        if score <= 3 { return 550 }
        if score <= 8 { return 300 }
        return 160
    }

    private func tickIcon() {
        let frames: [String]
        if loadScore <= 0 {
            frames = idleFrames
        } else if loadScore <= 8 {
            frames = workFrames
        } else {
            frames = busyFrames
        }

        frameIndex = (frameIndex + 1) % frames.count
        menuIcon = frames[frameIndex]
    }
}
