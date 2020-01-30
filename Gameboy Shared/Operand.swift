//
//  Operand.swift
//  Gameboy iOS
//
//  Created by Brad Feehan on 14/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

enum Operand {
    case Relative(Int8)
    case Byte(OneByte)
    case Word(TwoByte)

    enum OneByte {
        case Address(address: Address, value: Byte)
        case HighAddress(address: Address, value: Byte)
        case Immediate(Byte)
        case Register(name: Register.Name, value: Register)
        case RegisterIndirect(name: Register.Pair.Name, address: Address, value: Byte)
        case RegisterIndirectHigh(name: Register.Name, address: Address, value: Byte)

        var definition: Definition.OneByte {
            switch self {
            case .Address: return .Address
            case .HighAddress: return .HighAddress
            case .Immediate: return .Immediate
            case let .Register(name: name, value: _): return .Register(name)
            case let .RegisterIndirect(name: name, address: _, value: _): return .RegisterIndirect(name)
            case let .RegisterIndirectHigh(name: name, address: _, value: _): return .RegisterIndirectHigh(name)
            }
        }

        var length: UInt8 {
            switch self {
            case .Address:
                return 2
            case .HighAddress, .Immediate:
                return 1
            case .Register, .RegisterIndirect, .RegisterIndirectHigh:
                return 0
            }
        }

        var value: Byte {
            switch self {
            case let .Address(address: _, value: value): return value
            case let .HighAddress(address: _, value: value): return value
            case let .Immediate(value): return value
            case let .Register(name: _, value: value): return value
            case let .RegisterIndirect(name: _, address: _, value: value): return value
            case let .RegisterIndirectHigh(name: _, address: _, value: value): return value
            }
        }
    }

    enum TwoByte {
        case Address(address: Address, value: Word)
        case ExtendedImmediate(Word)
        case RegisterExtended(name: Register.Pair.Name, value: Register.Pair)
        case RegisterIndexed(name: Register.Pair.Name, address: Address, index: Int8, value: Word)

        var definition: Definition.TwoByte {
            switch self {
            case .Address: return .Address
            case .ExtendedImmediate: return .ExtendedImmediate
            case let .RegisterExtended(name: name, value: _): return .RegisterExtended(name)
            case let .RegisterIndexed(name: name, address: _, index: _, value: _): return .RegisterIndexed(name)
            }
        }

        var length: UInt8 {
            switch self {
            case .Address, .ExtendedImmediate:
                return 2
            case .RegisterIndexed:
                return 1
            case .RegisterExtended:
                return 0
            }
        }

        var value: Word {
            switch self {
            case let .Address(address: _, value: value): return value
            case let .ExtendedImmediate(value): return value
            case let .RegisterExtended(name: _, value: value): return value
            case let .RegisterIndexed(name: _, address: _, index: _, value: value): return value
            }
        }
    }

    var definition: Definition {
        switch self {
        case .Relative: return .Relative
        case let .Byte(operand): return .Byte(operand.definition)
        case let .Word(operand): return .Word(operand.definition)
        }
    }

    var length: UInt8 {
        switch self {
        case .Relative: return 1
        case let .Byte(operand): return operand.length
        case let .Word(operand): return operand.length
        }
    }

    enum Definition: Equatable {
        case Relative
        case Byte(OneByte)
        case Word(TwoByte)

        enum OneByte: Equatable {
            case Address, HighAddress, Immediate
            case Register(Register.Name)
            case RegisterIndirect(Register.Pair.Name)
            case RegisterIndirectHigh(Register.Name)

            var length: UInt8 {
                switch self {
                case .Address:
                    return 2
                case .HighAddress, .Immediate:
                    return 1
                case .Register, .RegisterIndirect, .RegisterIndirectHigh:
                    return 0
                }
            }

            var isHighAddress: Bool {
                switch self {
                case .HighAddress, .RegisterIndirectHigh:
                    return true
                default:
                    return false
                }
            }
        }

        enum TwoByte: Equatable {
            case Address, ExtendedImmediate
            case RegisterExtended(Register.Pair.Name)
            case RegisterIndexed(Register.Pair.Name)

            var length: UInt8 {
                switch self {
                case .Address, .ExtendedImmediate:
                    return 2
                case .RegisterIndexed:
                    return 1
                case .RegisterExtended:
                    return 0
                }
            }
        }

        var length: UInt8 {
            switch self {
            case .Relative:
                return 1
            case let .Byte(operand):
                return operand.length
            case let .Word(operand):
                return operand.length
            }
        }
    }
}
