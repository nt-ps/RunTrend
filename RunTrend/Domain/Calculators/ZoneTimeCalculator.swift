import Foundation

nonisolated struct ZoneTimeCalculator: Sendable {
    let maxSampleGap: TimeInterval
    
    init(maxSampleGap: TimeInterval = 30) {
        self.maxSampleGap = maxSampleGap
    }
    
    func zoneDurations(
        for samples: [HeartRateSample],
        zones: HeartRateZones
    ) -> [HeartRateZone: TimeInterval] {
        let sortedSamples = samples.sorted { $0.date < $1.date }
        
        var result = Dictionary(
            uniqueKeysWithValues: HeartRateZone.allCases.map { ($0, TimeInterval(0)) }
        )

        for (current, next) in zip(sortedSamples, sortedSamples.dropFirst()) {
            let dt = next.date.timeIntervalSince(current.date)
            if dt <= maxSampleGap {
                let zone = zones.zone(for: current.bpm)
                result[zone, default: 0] += dt
            }
        }
        
        return result
    }
}
