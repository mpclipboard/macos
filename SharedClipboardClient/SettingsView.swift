import SwiftUI

struct SettingsView: View {
    @State private var text1 = ""
    @State private var text2 = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("First field", text: $text1)
            TextField("Second field", text: $text2)
        }
        .padding()
        .frame(width: 300)
    }
}
