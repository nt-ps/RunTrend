import Testing
@testable import RunTrend

@Suite("HeartRateZones")
struct HeartRateZonesTests {
    let zones: HeartRateZones
    
    init() throws {
        zones = try #require(HeartRateZones(restingHeartRate: 60, maxHeartRate: 190))
    }

    @Test("Пульс на нижней границе зоны относится к этой зоне", arguments: [
        (125.0, HeartRateZone.one),
        (138.0, .two),
        (151.0, .three),
        (164.0, .four),
        (177.0, .five),
    ])
    func boundaryBelongsToUpperZone(bpm: Double, expected: HeartRateZone) {
        #expect(zones.zone(for: bpm) == expected)
    }

    @Test("Пульс на 1 удар ниже границы относится к предыдущей зоне", arguments: [
        (137.0, HeartRateZone.one),
        (150.0, .two),
        (163.0, .three),
        (176.0, .four),
    ])
    func belowBoundaryBelongsToLowerZone(bpm: Double, expected: HeartRateZone) {
        #expect(zones.zone(for: bpm) == expected)
    }

    @Test("Пульс ниже первой зоны засчитывается в зону 1", arguments: [0.0, 60.0, 124.0])
    func belowFirstZoneIsZoneOne(bpm: Double) {
        #expect(zones.zone(for: bpm) == .one)
    }

    @Test("Пульс выше максимального относится к зоне 5")
    func aboveMaxIsZoneFive() {
        #expect(zones.zone(for: 190) == .five)
        #expect(zones.zone(for: 220) == .five)
    }
    
    @Test("Некорректные настройки не создают зоны", arguments: [
        (190.0, 60.0),
        (60.0, 60.0),
        (0.0, 190.0),
    ])
    func invalidSettings(rest: Double, max: Double) {
        #expect(HeartRateZones(restingHeartRate: rest, maxHeartRate: max) == nil)
    }
}
