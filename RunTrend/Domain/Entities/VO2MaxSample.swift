import Foundation

nonisolated struct VO2MaxSample: Sendable {
    let id: UUID
    let date: Date
    let value: Double
}
