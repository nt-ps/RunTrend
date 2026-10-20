import Foundation

nonisolated struct ProgressPoint: Sendable {
    let periodStart: Date
    let value: Double?
    let runCount: Int
}
