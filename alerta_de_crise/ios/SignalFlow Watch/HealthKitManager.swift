import Combine
import Foundation
import HealthKit

enum SessionState: String {
    case idle
    case ready
    case authorized
    case unavailable

    var label: String {
        switch self {
        case .idle:
            return "Aguardando preparo"
        case .ready:
            return "Pronto para autorizacao"
        case .authorized:
            return "HealthKit autorizado"
        case .unavailable:
            return "HealthKit indisponivel"
        }
    }
}

@MainActor
final class HealthKitManager: ObservableObject {
    @Published private(set) var sessionState: SessionState = .idle
    @Published private(set) var authorizationStatus = "Nao solicitado"

    private let healthStore = HKHealthStore()

    func prepareSession() {
        sessionState = .ready
        authorizationStatus = "Solicitando HealthKit"
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            sessionState = .unavailable
            authorizationStatus = "HealthKit indisponivel neste dispositivo"
            return
        }

        guard
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
            let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        else {
            sessionState = .unavailable
            authorizationStatus = "Tipos fisiologicos indisponiveis"
            return
        }

        let readTypes: Set<HKObjectType> = [heartRateType, hrvType]
        let shareTypes = Set<HKSampleType>()

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { [weak self] success, error in
            Task { @MainActor in
                guard let self else {
                    return
                }

                if success {
                    self.sessionState = .authorized
                    self.authorizationStatus = "Permissao solicitada para FC e HRV"
                } else {
                    self.sessionState = .unavailable
                    self.authorizationStatus = error?.localizedDescription ?? "Autorizacao HealthKit negada"
                }
            }
        }
    }
}
