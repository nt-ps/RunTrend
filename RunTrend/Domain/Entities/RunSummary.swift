import Foundation

nonisolated struct RunSummary: Sendable {
    let id: UUID
    let startDate: Date
    let duration: TimeInterval
    let distance: Double
    let averageHeartRate: Double?
    let stepCount: Int?
    let averagePower: Double?
    let zoneDurations: [HeartRateZone: TimeInterval]
}
