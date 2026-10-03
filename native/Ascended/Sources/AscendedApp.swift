import SwiftUI

@main
struct AscendedApp: App {
    var body: some Scene {
        WindowGroup {
            AscendedShell()
                .tint(.cyan)
                .preferredColorScheme(.dark)
        }
    }
}
