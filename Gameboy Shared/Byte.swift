//
//  Addressable.swift
//  Gameboy
//
//  Created by Brad Feehan on 14/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

typealias Byte = UInt8
typealias Word = UInt16

extension Byte {
    var highNibble: Byte {
        return (self & 0xf0) >> 4
    }

    var lowNibble: Byte {
        return self & 0x0f
    }

    var swapped: Byte {
        return Byte(self.lowNibble << 4 | self.highNibble)
    }

    enum Bit: UInt8, Equatable {
        typealias Value = Bool

        case _0 = 0
        case _1 = 1
        case _2 = 2
        case _3 = 3
        case _4 = 4
        case _5 = 5
        case _6 = 6
        case _7 = 7

        var mask: Byte {
            return Byte(1 << self.rawValue)
        }

        func read(from register: Byte) -> Value {
            return (register & mask > 0)
        }

        func set(_ newValue: Value, on register: Byte) -> Byte {
            if newValue {
                return register | mask
            } else {
                return register & ~mask
            }
        }

        func write(_ newValue: Value, to register: inout Byte) {
            register = set(newValue, on: register)
        }
    }
}

extension Word {
    init(_ highByte: Register, _ lowByte: Register) {
        self.init(integerLiteral: (Self(highByte) << 8) | Self(lowByte))
    }

    var highByte: Register {
        get { return Register(truncatingIfNeeded: self >> 8) }
        set(newValue) { self = Self(newValue, lowByte) }
    }

    var lowByte: Register {
        get { return Register(truncatingIfNeeded: self & 0xFF) }
        set(newValue) { self = Self(highByte, newValue) }
    }

    mutating func offset(by offset: Int8) {
        self = self.withOffset(by: offset)
    }

    func withOffset(by offset: Int8) -> Word {
        if offset >= 0 {
            return self &+ UInt16(abs(offset))
        } else {
            return self &- UInt16(abs(offset))
        }
    }
}
