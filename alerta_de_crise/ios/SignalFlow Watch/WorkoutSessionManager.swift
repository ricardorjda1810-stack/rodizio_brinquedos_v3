import Combine
import Foundation
import HealthKit

enum LiveSessionState: String {
    case idle
    case preparing
    case running
    case stopped
    case failed

    var label: String {
        switch self {
        case .idle:
            return "Aguardando inicio"
        case .preparing:
            return "Preparando sessao"
        case .running:
            return "Sessao ativa"
        case .stopped:
            return "Sessao encerrada"
        case .failed:
            return "Falha na sessao"
        }
    }
}

final class WorkoutSessionManager: NSObject, ObservableObject {
    @Published private(set) var state: LiveSessionState = .idle
    @Published private(set) var currentHeartRate: Double?
    @Published private(set) var updateCount = 0
    @Published private(set) var lastUpdateTimestamp: Date?
    @Published private(set) var statusMessage = "Sem sessao ativa"

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func startSession() {
        guard HKHealthStore.isHealthDataAvailable() else {
            fail(with: "HealthKit indisponivel neste dispositivo")
            return
        }

        setState(.preparing, message: "Solicitando autorizacao")

        requestAuthorization { [weak self] success, message in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                guard success else {
                    self.fail(with: message)
                    return
                }

                self.startWorkout()
            }
        }
    }

    func stopSession() {
        guard let session else {
            setState(.stopped, message: "Nenhuma sessao ativa")
            return
        }

        setState(.stopped, message: "Encerrando sessao")
        session.end()

        let endDate = Date()
        builder?.endCollection(withEnd: endDate) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error {
                    self?.fail(with: error.localizedDescription)
                    return
                }

                self?.session = nil
                self?.builder = nil
                self?.setState(.stopped, message: "Sessao encerrada")
            }
        }
    }

    private func requestAuthorization(completion: @escaping (Bool, String) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false, "Tipo de frequencia cardiaca indisponivel")
            return
        }

        let readTypes: Set<HKObjectType> = [heartRateType]
        let shareTypes: Set<HKSampleType> = [HKObjectType.workoutType()]

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            completion(success, error?.localizedDescription ?? "Autorizacao concluida")
        }
    }

    private func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .mindAndBody
        configuration.locationType = .unknown

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            fail(with: error.localizedDescription)
            return
        }

        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        let startDate = Date()
        updateCount = 0
        currentHeartRate = nil
        lastUpdateTimestamp = startDate
        setState(.running, message: "Coletando frequencia cardiaca")

        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error {
                    self?.fail(with: error.localizedDescription)
                } else if !success {
                    self?.fail(with: "Nao foi possivel iniciar coleta")
                }
            }
        }
    }

    private func updateHeartRate(from builder: HKLiveWorkoutBuilder) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let statistics = builder.statistics(for: heartRateType)
        let unit = HKUnit.count().unitDivided(by: .minute())

        guard let quantity = statistics?.mostRecentQuantity() else {
            return
        }

        currentHeartRate = quantity.doubleValue(for: unit)
        updateCount += 1
        lastUpdateTimestamp = Date()
        statusMessage = "Update recebido"
    }

    private func setState(_ newState: LiveSessionState, message: String) {
        state = newState
        statusMessage = message
    }

    private func fail(with message: String) {
        session = nil
        builder = nil
        setState(.failed, message: message)
    }
}

extension WorkoutSessionManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.lastUpdateTimestamp = date

            if toState == .ended {
                self?.setState(.stopped, message: "Sessao encerrada")
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.fail(with: error.localizedDescription)
        }
    }
}

extension WorkoutSessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        guard collectedTypes.contains(where: { sampleType in
            sampleType == HKObjectType.quantityType(forIdentifier: .heartRate)
        }) else {
            return
        }

        DispatchQueue.main.async { [weak self, weak workoutBuilder] in
            guard let workoutBuilder else {
                return
            }

            self?.updateHeartRate(from: workoutBuilder)
        }
    }
}
