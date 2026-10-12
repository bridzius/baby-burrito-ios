import Foundation
import SwiftData

@Model
public final class LocalBaby {
    @Attribute(.unique) public private(set) var zoneName: String
    public private(set) var name: String
    public private(set) var birthDate: Date
    public private(set) var feedingIntervalMinutes: Int

    init(baby: Baby, zoneName: String) {
        self.zoneName               = zoneName
        self.name                   = baby.name
        self.birthDate              = baby.birthDate
        self.feedingIntervalMinutes = baby.feedingIntervalMinutes
    }

    public var baby: Baby {
        Baby(name: name, birthDate: birthDate, feedingIntervalMinutes: feedingIntervalMinutes)
    }

    func apply(_ baby: Baby) {
        name                   = baby.name
        birthDate              = baby.birthDate
        feedingIntervalMinutes = baby.feedingIntervalMinutes
    }
}
