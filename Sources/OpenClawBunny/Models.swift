import Foundation

enum BotStatus: String, Codable {
    case idle
    case working
    case busy
    case blocked
    case error
}

struct BotState: Codable, Identifiable {
    var id: String { name }
    let name: String
    let status: BotStatus
    let currentKeyword: String?
    let pendingKeywords: [String]
}

struct BunnySnapshot: Codable {
    let updatedAt: String?
    let bots: [BotState]

    static let empty = BunnySnapshot(updatedAt: nil, bots: [])
}
