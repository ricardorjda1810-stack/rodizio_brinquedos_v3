import SwiftUI

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var workoutSessionManager = WorkoutSessionManager()

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

            Divider()

            VStack(spacing: 4) {
                Text("FC atual")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(heartRateText)
                    .font(.title3.monospacedDigit())
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 4) {
                Text("Sessao live")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(workoutSessionManager.state.label)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }

            Text("Updates: \(workoutSessionManager.updateCount)")
                .font(.caption.monospacedDigit())

            Text(timestampText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                Button("Iniciar sessão") {
                    workoutSessionManager.startSession()
                }
                .disabled(workoutSessionManager.state == .running || workoutSessionManager.state == .preparing)

                Button("Encerrar sessão") {
                    workoutSessionManager.stopSession()
                }
                .disabled(workoutSessionManager.state != .running)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var heartRateText: String {
        guard let currentHeartRate = workoutSessionManager.currentHeartRate else {
            return "-- bpm"
        }

        return "\(Int(currentHeartRate.rounded())) bpm"
    }

    private var timestampText: String {
        guard let lastUpdateTimestamp = workoutSessionManager.lastUpdateTimestamp else {
            return "Sem updates"
        }

        return lastUpdateTimestamp.formatted(date: .omitted, time: .standard)
    }
}

#Preview {
    ContentView()
}
