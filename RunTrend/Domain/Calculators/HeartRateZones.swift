import Foundation

nonisolated struct HeartRateZones: Sendable {
    private let zones: [(zone: HeartRateZone, bpm: Double)]
    
    init?(restingHeartRate rest: Double, maxHeartRate: Double) {
        guard rest > 0, maxHeartRate > rest else { return nil }
        
        let hrr = maxHeartRate - rest
        self.zones = HeartRateZone.allCases.reversed().map { zone in
            let percent = Self.lowerBoundPercent(for: zone)
            return (zone, rest + hrr * percent / 100)
        }
    }
    
    func zone(for bpm: Double) -> HeartRateZone {
        zones.first { bpm >= $0.bpm }?.zone ?? .one
    }
    
    private static func lowerBoundPercent(for zone: HeartRateZone) -> Double {
        switch zone {
        case .one: 50
        case .two: 60
        case .three: 70
        case .four: 80
        case .five: 90
        }
    }
}
