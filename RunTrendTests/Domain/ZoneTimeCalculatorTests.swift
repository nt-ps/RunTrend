import Testing
import Foundation
@testable import RunTrend

@Suite("ZoneTimeCalculator")
struct ZoneTimeCalculatorTests {
    private static let start = Date(timeIntervalSince1970: 0)
    
    private let zones: HeartRateZones
    private let calculator: ZoneTimeCalculator
    
    init() throws {
        self.zones = try #require(HeartRateZones(restingHeartRate: 60, maxHeartRate: 190))
        self.calculator = ZoneTimeCalculator(maxSampleGap: 30)
    }
    
    private static func sample(at seconds: TimeInterval, bpm: Double) -> HeartRateSample {
        HeartRateSample(date: start + seconds, bpm: bpm)
    }
    
    @Test("Результат всегда содержит все зоны", arguments: [
        [],
        [sample(at: 0, bpm: 139)],
        [sample(at: 0, bpm: 139), sample(at: 5, bpm: 145), sample(at: 20, bpm: 178)]
    ])
    func resultContainsAllZones(samples: [HeartRateSample]) {
        let zoneDurations = calculator.zoneDurations(for: samples, zones: zones)
        #expect(HeartRateZone.allCases.allSatisfy { zoneDurations.keys.contains($0) })
    }
    
    @Test("Пустой массив и один сэмпл дают нули во всех зонах", arguments: [
        [],
        [sample(at: 0, bpm: 139)]
    ])
    func emptyAndSingleElementArray(samples: [HeartRateSample]) {
        let zoneDurations = calculator.zoneDurations(for: samples, zones: zones)
        
        #expect(HeartRateZone.allCases.allSatisfy { zoneDurations.keys.contains($0) })
        #expect(zoneDurations.allSatisfy { $0.value == 0 })
    }
    
    @Test("Два сэмпла в одной зоне с интервалом 5 с дают 5 с в этой зоне")
    func twoElementsArray() throws {
        let targetTime = 5.0
        
        let samples = [
            Self.sample(at: 0, bpm: 190),
            Self.sample(at: targetTime, bpm: 195)
        ]
        
        let zoneDurations = calculator.zoneDurations(for: samples, zones: zones)
        
        let bpm = try #require(samples.first?.bpm)
        let zone = zones.zone(for: bpm)

        #expect(zoneDurations[zone] == targetTime)
        #expect(zoneDurations.filter { $0.key != zone }.allSatisfy { $0.value == 0 })
    }
    
    @Test("Переход между зонами: время уходит в зону левой точки")
    func timeTrackingForTheLeftPoint() throws {
        let firstTargetTime = 15.0
        let secondTargetTime = 20.0
        
        let samples = [
            Self.sample(at: 0, bpm: 130),
            Self.sample(at: firstTargetTime, bpm: 140),
            Self.sample(at: firstTargetTime + secondTargetTime, bpm: 170)
        ]

        let zoneDurations = calculator.zoneDurations(for: samples, zones: zones)
        
        let bpms = samples.map { $0.bpm }
        let sampleZones = bpms.map { zones.zone(for: $0) }
        
        try #require(Set(sampleZones).count == sampleZones.count)
        #expect(zoneDurations[sampleZones[0]] == firstTargetTime)
        #expect(zoneDurations[sampleZones[1]] == secondTargetTime)
        #expect(zoneDurations[sampleZones[2]] == 0)
        #expect(zoneDurations.filter { !sampleZones.contains($0.key) }.allSatisfy { $0.value == 0 })
    }
    
    @Test("Разрыв больше maxSampleGap не учитывается, а разрыв ровно maxSampleGap учитывается (проверка границы)")
    func accountingForMaxSampleGap() throws {
        let maxSampleGapTime = calculator.maxSampleGap
        let aboveMaxSampleGapTime = calculator.maxSampleGap + 1
        
        let samples = [
            Self.sample(at: 0, bpm: 130),
            Self.sample(at: maxSampleGapTime, bpm: 130),
            Self.sample(at: maxSampleGapTime + aboveMaxSampleGapTime, bpm: 130)
        ]

        let zoneDurations = calculator.zoneDurations(for: samples, zones: zones)
        
        let bpm = try #require(samples.first?.bpm)
        let zone = zones.zone(for: bpm)
        
        #expect(zoneDurations[zone] == maxSampleGapTime)
        #expect(zoneDurations.filter { $0.key != zone }.allSatisfy { $0.value == 0 })
    }
    
    @Test("Неотсортированный вход даёт тот же результат, что и отсортированный")
    func sortedAndUnsortedSamples() {
        let unsortedSamples = [
            Self.sample(at: 15, bpm: 140),
            Self.sample(at: 10, bpm: 130),
            Self.sample(at: 0, bpm: 130),
            Self.sample(at: 20, bpm: 170),
            Self.sample(at: 5, bpm: 130),
        ]
        let sortedSamples = unsortedSamples.sorted { $0.date < $1.date }
        
        var expectedResult = Dictionary(
            uniqueKeysWithValues: HeartRateZone.allCases.map { ($0, TimeInterval(0)) }
        )
        expectedResult[.one] = 15
        expectedResult[.two] = 5
        
        let zoneDurationsForUnsortedSamples = calculator.zoneDurations(
            for: unsortedSamples,
            zones: zones
        )
        let zoneDurationsForSortedSamples = calculator.zoneDurations(
            for: sortedSamples,
            zones: zones
        )
        
        #expect(zoneDurationsForUnsortedSamples == expectedResult)
        #expect(zoneDurationsForSortedSamples == expectedResult)
        #expect(zoneDurationsForUnsortedSamples == zoneDurationsForSortedSamples)
    }
}
