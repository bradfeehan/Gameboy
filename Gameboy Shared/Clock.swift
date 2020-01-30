//
//  Clock.swift
//  Gameboy
//
//  Created by Brad Feehan on 22/1/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

class Clock {
    var machineCycles: UInt64 = 0
    var clockPeriods: UInt64 = 0

    func reset() {
        self.machineCycles = 0
        self.clockPeriods = 0
    }

    func tick(_ timing: Timing) {
        self.clockPeriods += UInt64(timing.clockPeriods)
    }

    typealias CycleCount: UInt64

    struct Timing {
        let clockPeriods: UInt8
    }
}
