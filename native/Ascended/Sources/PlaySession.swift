import SwiftUI

struct JungleNavigator: View {
    var body: some View {
        ScrollView {
            if let guide = ArkMap.ragnarok.caveGIFs.first(where: { $0.routeID == "jungle" }) {
                CaveGIFWalkthrough(guide: guide).padding(16)
            }
        }.navigationBarTitleDisplayMode(.inline)
    }
}
