//
//  Register.swift
//  Gameboy
//
//  Created by Brad Feehan on 9/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

@propertyWrapper
struct ZeroLowNibble {
    private var value: Register.Pair = 0
    var wrappedValue: Register.Pair {
        get { value & 0xfff0 }
        set { value = newValue & 0xfff0 }
    }
}

typealias Register = Byte

extension Register {
    typealias Pair = Word

    enum Name: String {
        case A, B, C, D, E, F, H, L
    }
}

extension Register.Pair {
    enum Name: String {
        case AF, BC, DE, HL, SP, PC
    }
}

extension Register {
    class Set: Equatable {
        enum Flag: UInt8 {
            typealias Value = Byte.Bit.Value

            case Z = 7
            case N = 6
            case H = 5
            case C = 4

            var bitNumber: Byte.Bit {
                switch self {
                case .Z: return ._7
                case .N: return ._6
                case .H: return ._5
                case .C: return ._4
                }
            }
        }

        @ZeroLowNibble var AF: Register.Pair
        var BC: Register.Pair = 0
        var DE: Register.Pair = 0
        var HL: Register.Pair = 0
        var SP: Address = 0xfffe
        var PC: Address = 0

        func reset() {
            self.AF = 0
            self.BC = 0
            self.DE = 0
            self.HL = 0
            self.SP = 0xfffe
            self.PC = 0
        }

        var A: Register {
            get { AF.highByte }
            set { AF.highByte = newValue }
        }
        var F: Register {
            get { AF.lowByte }
            set { AF.lowByte = newValue }
        }
        var B: Register {
            get { BC.highByte }
            set { BC.highByte = newValue }
        }
        var C: Register {
            get { BC.lowByte }
            set { BC.lowByte = newValue }
        }
        var D: Register {
            get { DE.highByte }
            set { DE.highByte = newValue }
        }
        var E: Register {
            get { DE.lowByte }
            set { DE.lowByte = newValue }
        }
        var H: Register {
            get { HL.highByte }
            set { HL.highByte = newValue }
        }
        var L: Register {
            get { HL.lowByte }
            set { HL.lowByte = newValue }
        }

        func get(flag: Flag) -> Flag.Value {
            return flag.bitNumber.read(from: self.F)
        }

        func set(flag: Flag, value: Flag.Value) {
            flag.bitNumber.write(value, to: &self.F)
        }

        static func == (lhs: UInt8.Set, rhs: UInt8.Set) -> Bool {
            return lhs.AF == rhs.AF
                && lhs.BC == rhs.BC
                && lhs.DE == rhs.DE
                && lhs.HL == rhs.HL
                && lhs.SP == rhs.SP
                && lhs.PC == rhs.PC
        }

        subscript(_ name: Register.Name) -> Register {
            get {
                switch name {
                case .A: return A
                case .B: return B
                case .C: return C
                case .D: return D
                case .E: return E
                case .F: return F
                case .H: return H
                case .L: return L
                }
            }
            set {
                switch name {
                case .A: A = newValue
                case .B: B = newValue
                case .C: C = newValue
                case .D: D = newValue
                case .E: E = newValue
                case .F: F = newValue
                case .H: H = newValue
                case .L: L = newValue
                }
            }
        }

        subscript(_ name: Register.Pair.Name) -> Word {
            get {
                switch name {
                case .AF: return AF
                case .BC: return BC
                case .DE: return DE
                case .HL: return HL
                case .SP: return SP
                case .PC: return PC
                }
            }
            set {
                switch name {
                case .AF: AF = newValue
                case .BC: BC = newValue
                case .DE: DE = newValue
                case .HL: HL = newValue
                case .SP: SP = newValue
                case .PC: PC = newValue
                }
            }
        }
    }

    typealias Interrupt = Register
}

extension Register.Interrupt {
    var vblank: Bool {
        get { Byte.Bit._0.read(from: self) }
        set { Byte.Bit._0.write(newValue, to: &self) }
    }

    var lcdstat: Bool {
        get { Byte.Bit._1.read(from: self) }
        set { Byte.Bit._1.write(newValue, to: &self) }
    }

    var timer: Bool {
        get { Byte.Bit._2.read(from: self) }
        set { Byte.Bit._2.write(newValue, to: &self) }
    }

    var serial: Bool {
        get { Byte.Bit._3.read(from: self) }
        set { Byte.Bit._3.write(newValue, to: &self) }
    }

    var joypad: Bool {
        get { Byte.Bit._4.read(from: self) }
        set { Byte.Bit._4.write(newValue, to: &self) }
    }
}
