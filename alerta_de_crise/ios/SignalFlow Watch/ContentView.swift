import SwiftUI

struct ContentView: View {
    @State private var isSessionReady = false

    var body: some View {
        VStack(spacing: 10) {
            Text("SignalFlow")
                .font(.headline)

            Text(isSessionReady ? "Session ready" : "Watch companion")
                .font(.caption)
                .multilineTextAlignment(.center)

            Button("Start Session") {
                isSessionReady = true
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
