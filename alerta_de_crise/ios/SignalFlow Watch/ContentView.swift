import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some View {
        VStack(spacing: 10) {
            Text("SignalFlow Watch")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Pronto para sessão ao vivo")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 4) {
                Text("Autorizacao HealthKit")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(healthKitManager.authorizationStatus)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 4) {
                Text("Estado")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(healthKitManager.sessionState.label)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            Button("Preparar sessão") {
                healthKitManager.prepareSession()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
