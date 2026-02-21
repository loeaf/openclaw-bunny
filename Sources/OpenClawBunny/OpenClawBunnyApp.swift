import SwiftUI

@main
struct OpenClawBunnyApp: App {
    @StateObject private var store = BunnyStore()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(store)
                .frame(width: 380)
                .onAppear { store.start() }
                .onDisappear { store.stop() }
        } label: {
            Text(store.menuIcon)
        }
        .menuBarExtraStyle(.window)
    }
}
