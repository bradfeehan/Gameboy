//
//  Disassembler.swift
//  Gameboy
//
//  Created by Brad Feehan on 9/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

struct Disassembler {
    private static let BYTE_FORMAT = "%02X"
    private static let WORD_FORMAT = "%04X"

    func disassemble(_ operation: Operation) -> String? {
        switch operation {
        case let .Add(operand1, operand2, carrying):
            return (carrying.bool ? "ADC" : "ADD") + " \(disassemble(operand1)),\(disassemble(operand2))"
        case let .And(operand):
            return "AND \(disassemble(operand))"
        case let .Call(address, condition):
            if let conditionMnemonic = mnemonic(for: condition) {
                return "CALL \(conditionMnemonic),\(disassemble(address))"
            } else {
                return "CALL \(disassemble(address))"
            }
        case .CarryFlag(.Complement):
            return "CCF"
        case .CarryFlag(.Set):
            return "SCF"
        case let .Compare(operand):
            return "CP \(disassemble(operand))"
        case let .CompareBit(bit, operand):
            return "BIT \(bit.rawValue),\(disassemble(operand))"
        case .Complement:
            return "CPL"
        case .DecimalAdjustAccumulator:
            return "DAA"
        case let .DecrementByte(operand):
            return "DEC \(disassemble(operand))"
        case let .DecrementWord(registerName):
            return "DEC \(registerName)"
        case let .ExclusiveOr(operand):
            return "XOR \(disassemble(operand))"
        case .Halt:
            return "HALT"
        case let .IncrementByte(operand):
            return "INC \(disassemble(operand))"
        case let .IncrementWord(registerName):
            return "INC \(registerName)"
        case .Invalid:
            return "XX"
        case let .Interrupts(enabled):
            return (enabled ? "EI" : "DI")
        case let .Jump(.Relative(value), condition):
            if let conditionMnemonic = mnemonic(for: condition) {
                return "JR \(conditionMnemonic),\(disassemble(.Relative(value)))"
            } else {
                return "JR \(disassemble(.Relative(value)))"
            }
        case let .Jump(operand, condition):
            if let conditionMnemonic = mnemonic(for: condition) {
                return "JP \(conditionMnemonic),\(disassemble(operand))"
            } else {
                return "JP \(disassemble(operand))"
            }
        case let .LoadByte(.Normal, into: into, from: from) where into.definition.isHighAddress || from.definition.isHighAddress:
            return "LDH \(disassemble(into)),\(disassemble(from))"
        case .LoadByte(let type, into: let into, from: let from):
            return "LD\(mnemonic(for: type)) \(disassemble(into)),\(disassemble(from))"
        case .LoadWord(let type, into: let into, from: let from):
            return "LD\(mnemonic(for: type)) \(disassemble(into)),\(disassemble(from))"
        case .NoOp:
            return "NOP"
        case let .Or(operand):
            return "OR \(disassemble(operand))"
        case let .Pop(registerPair):
            return "POP \(registerPair)"
        case let .Push(registerPair):
            return "PUSH \(registerPair)"
        case let .Restart(vector):
            return "RST \(String(format: "%X", vector.rawValue))"
        case let .ResetBit(bit, operand):
            return "RES \(bit.rawValue),\(disassemble(operand))"
        case let .Return(condition):
            if let mnemonic = mnemonic(for: condition) {
                return "RET \(mnemonic)"
            } else {
                return "RET"
            }
        case .ReturnFromInterrupt:
            return "RETI"
        case let .Rotate(direction, operand, carrying, _):
            return "R\(mnemonic(for: direction))\(carrying.bool ? "C": "") \(disassemble(operand))"
        case let .SetBit(bit, operand):
            return "SET \(bit.rawValue),\(disassemble(operand))"
        case let .Shift(direction, operand):
            return "S\(mnemonic(for: direction)) \(disassemble(operand))"
        case .Stop:
            return "STOP"
        case let .Subtract(operand, carrying):
            return (carrying.bool ? "SBC A," : "SUB A,") + disassemble(operand)
        case let .Swap(operand):
            return "SWAP \(disassemble(operand))"
        }
    }

    func sign(_ value: Int8) -> String {
        if value >= 0 {
            return "+"
        } else {
            return "-"
        }
    }

    func disassemble(_ operand: Operand) -> String {
        switch operand {
        case let .Relative(value):
            let absValue = abs(value)
            let signValue = sign(value)
            return String(format: "\(signValue)\(Self.BYTE_FORMAT)", absValue)
        case let .Byte(op):
            return disassemble(op)
        case let .Word(op):
            return disassemble(op)
        }
    }

    func disassemble(_ operand: Operand.OneByte) -> String {
        switch operand {
        case let .Address(address: address, value: value):
            return String(format: "(\(Self.WORD_FORMAT))=\(Self.BYTE_FORMAT)", address, value)
        case let .HighAddress(address: address, value: value):
            return String(format: "(\(Self.BYTE_FORMAT))=\(Self.BYTE_FORMAT)", address.lowByte, value)
        case let .Immediate(value):
            return String(format: Self.BYTE_FORMAT, value)
        case let .Register(name: name, value: value):
            return String(format: "\(name.rawValue)=\(Self.BYTE_FORMAT)", value)
        case let .RegisterIndirect(name: name, address: address, value: value):
            return String(format: "(\(name.rawValue)=\(Self.WORD_FORMAT))=\(Self.BYTE_FORMAT)", address, value)
        case let .RegisterIndirectHigh(name: name, address: address, value: value):
            return String(format: "\(name.rawValue)=\(Self.BYTE_FORMAT)=>\(Self.BYTE_FORMAT)", address, value)
        }
    }

    func disassemble(_ operand: Operand.TwoByte) -> String {
        switch operand {
        case let .Address(address: address, value: value):
            return String(format: "(\(Self.WORD_FORMAT))=\(Self.WORD_FORMAT)", address, value)
        case let .ExtendedImmediate(value):
            return String(format: Self.WORD_FORMAT, value)
        case let .RegisterExtended(name: name, value: value):
            return String(format: "\(name.rawValue)=\(Self.BYTE_FORMAT)", value)
        case let .RegisterIndexed(name: name, address: address, index: index, value: value):
            let formatString = "(\(name.rawValue)=\(Self.WORD_FORMAT),\(sign(index))\(Self.BYTE_FORMAT))=\(Self.WORD_FORMAT)"
            return String(format: formatString, address, abs(index), value)
        }
    }

    func disassemble(_ address: Address) -> String {
        return String(format: Self.WORD_FORMAT, address)
    }

    func disassemble(_ instruction: Instruction) -> String {
        return disassemble(instruction.definition)
    }

    func disassemble(_ definition: Instruction.Definition) -> String {
        switch definition {
        case let .Add(operand1, operand2, carrying):
            return (carrying.bool ? "ADC" : "ADD") + " \(disassemble(operand1)),\(disassemble(operand2))"
        case let .And(operand):
            return "AND \(disassemble(operand))"
        case let .Call(condition):
            if let conditionMnemonic = mnemonic(for: condition) {
                return "CALL \(conditionMnemonic),\(disassemble(Operand.Definition.TwoByte.ExtendedImmediate))"
            } else {
                return "CALL \(disassemble(Operand.Definition.TwoByte.ExtendedImmediate))"
            }
        case .CarryFlag(.Complement):
            return "CCF"
        case .CarryFlag(.Set):
            return "SCF"
        case let .Compare(operand):
            return "CP \(disassemble(operand))"
        case let .CompareBit(bit, operand):
            return "BIT \(bit.rawValue),\(disassemble(operand))"
        case .Complement:
            return "CPL"
        case .DecimalAdjustAccumulator:
            return "DAA"
        case let .DecrementByte(operand):
            return "DEC \(disassemble(operand))"
        case let .DecrementWord(registerName):
            return "DEC \(registerName)"
        case let .ExclusiveOr(operand):
            return "XOR \(disassemble(operand))"
        case .Halt:
            return "HALT"
        case let .IncrementByte(operand):
            return "INC \(disassemble(operand))"
        case let .IncrementWord(registerName):
            return "INC \(registerName)"
        case .Invalid:
            return "XX"
        case let .Interrupts(enabled):
            return (enabled ? "EI" : "DI")
        case let .Jump(.Relative, condition):
            if let conditionMnemonic = mnemonic(for: condition) {
                return "JR \(conditionMnemonic),\(disassemble(Operand.Definition.Relative))"
            } else {
                return "JR \(disassemble(Operand.Definition.Relative))"
            }
        case let .Jump(operand, condition):
            if let conditionMnemonic = mnemonic(for: condition) {
                return "JP \(conditionMnemonic),\(disassemble(operand))"
            } else {
                return "JP \(disassemble(operand))"
            }
        case let .LoadByte(.Normal, into: into, from: from) where into.isHighAddress || from.isHighAddress:
            return "LDH \(disassemble(into)),\(disassemble(from))"
        case .LoadByte(let type, into: let into, from: let from):
            return "LD\(mnemonic(for: type)) \(disassemble(into)),\(disassemble(from))"
        case .LoadWord(let type, into: let into, from: let from):
            return "LD\(mnemonic(for: type)) \(disassemble(into)),\(disassemble(from))"
        case .NoOp:
            return "NOP"
        case let .Or(operand):
            return "OR \(disassemble(operand))"
        case let .Pop(registerPair):
            return "POP \(registerPair)"
        case let .Push(registerPair):
            return "PUSH \(registerPair)"
        case let .Restart(vector):
            return "RST \(String(format: "%X", vector.rawValue))"
        case let .ResetBit(bit, operand):
            return "RES \(bit.rawValue),\(disassemble(operand))"
        case let .Return(condition):
            if let mnemonic = mnemonic(for: condition) {
                return "RET \(mnemonic)"
            } else {
                return "RET"
            }
        case .ReturnFromInterrupt:
            return "RETI"
        case let .Rotate(direction, operand, carrying, _):
            return "R\(mnemonic(for: direction))\(carrying.bool ? "C": "") \(disassemble(operand))"
        case let .SetBit(bit, operand):
            return "SET \(bit.rawValue),\(disassemble(operand))"
        case let .Shift(direction, operand):
            return "S\(mnemonic(for: direction)) \(disassemble(operand))"
        case .Stop:
            return "STOP"
        case let .Subtract(operand, carrying):
            return (carrying.bool ? "SBC A," : "SUB A,") + disassemble(operand)
        case let .Swap(operand):
            return "SWAP \(disassemble(operand))"
        }
    }

    func disassemble(_ operand: Operand.Definition) -> String {
        switch operand {
        case .Relative:
            return "% +03X"
        case let .Byte(value):
            return disassemble(value)
        case let .Word(value):
            return disassemble(value)
        }
    }

    func disassemble(_ operand: Operand.Definition.OneByte) -> String {
        switch operand {
        case .Address:
            return disassemble(Operand.Definition.TwoByte.Address)
        case .HighAddress:
            return "(\(disassemble(Operand.Definition.OneByte.Immediate)))"
        case .Immediate:
            return Self.BYTE_FORMAT
        case let .Register(register):
            return register.rawValue
        case let .RegisterIndirect(registerPair):
            return "(\(registerPair))"
        case let .RegisterIndirectHigh(register):
            return "(\(register))"
        }
    }

    func disassemble(_ operand: Operand.Definition.TwoByte) -> String {
        switch operand {
        case .Address:
            return "(\(disassemble(Operand.Definition.TwoByte.ExtendedImmediate)))"
        case .ExtendedImmediate:
            return Self.WORD_FORMAT
        case let .RegisterExtended(registerPair):
            return registerPair.rawValue
        case let .RegisterIndexed(registerPair):
            return "\(registerPair),\(disassemble(Operand.Definition.Relative))"
        }
    }

    private func mnemonic(for condition: Instruction.Definition.JumpCondition) -> String? {
        switch condition {
        case .IfCarry: return "C"
        case .IfNotCarry: return "NC"
        case .IfNonZero: return "NZ"
        case .IfZero: return "Z"
        case .Unconditional: return .none
        }
    }

    private func mnemonic(for loadType: Instruction.Definition.LoadType) -> String {
        switch loadType {
        case .Normal: return ""
        case .AndDecrement: return "D"
        case .AndIncrement: return "I"
        }
    }

    private func mnemonic(for direction: Instruction.Definition.RotateDirection) -> String {
        switch direction {
        case .Left: return "L"
        case .Right: return "R"
        }
    }

    private func mnemonic(for shiftType: Instruction.Definition.ShiftDirection) -> String {
        switch shiftType {
        case .LeftArithmetic: return "LA"
        case .RightArithmetic: return "RA"
        case .RightLogical: return "RL"
        }
    }
}
