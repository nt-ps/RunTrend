import Foundation

nonisolated struct HeartRateSample: Sendable {
    let date: Date
    let bpm: Double
}
