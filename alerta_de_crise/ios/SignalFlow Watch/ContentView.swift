import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("SignalFlow Watch")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Pronto para sessão ao vivo")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
