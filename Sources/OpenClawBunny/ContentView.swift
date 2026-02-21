import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: BunnyStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            Divider()

            if store.snapshot.bots.isEmpty {
                Text("봇 정보 없음")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.snapshot.bots) { bot in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(bot.name)
                                .font(.headline)
                            Spacer()
                            Text(statusLabel(bot.status))
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(statusColor(bot.status).opacity(0.2))
                                .clipShape(Capsule())
                        }

                        Text("처리중: \(bot.currentKeyword ?? "-")")
                            .font(.caption)

                        Text("대기 \(bot.pendingKeywords.count)개")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        if !bot.pendingKeywords.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(bot.pendingKeywords.prefix(8), id: \.self) { item in
                                        Text(item)
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Divider()

            HStack {
                Text("상태 파일: \(store.statusFilePath)")
                    .font(.caption2)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button("새로고침") {
                    Task { await store.refresh() }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(12)
    }

    private var header: some View {
        HStack {
            Text("OpenClaw Bunny")
                .font(.title3.bold())
            Spacer()
            Text("load \(store.loadScore)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func statusLabel(_ status: BotStatus) -> String {
        switch status {
        case .idle: return "쉬는중"
        case .working: return "작업중"
        case .busy: return "바쁨"
        case .blocked: return "대기/막힘"
        case .error: return "오류"
        }
    }

    private func statusColor(_ status: BotStatus) -> Color {
        switch status {
        case .idle: return .gray
        case .working: return .blue
        case .busy: return .orange
        case .blocked: return .purple
        case .error: return .red
        }
    }
}
