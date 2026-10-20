import Foundation

nonisolated struct RawRun: Sendable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let distance: Double
    let stepCount: Int?
    let averagePower: Double?
    let heartRateSamples: [HeartRateSample]
}
