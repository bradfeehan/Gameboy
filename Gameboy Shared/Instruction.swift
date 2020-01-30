//
//  Instruction.swift
//  Gameboy
//
//  Created by Brad Feehan on 8/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

struct Instruction {
    typealias OpCode = UInt8

    let opCode: OpCode
    let disassembly: String
    let definition: Definition
    let timing: Instruction.Timing

    var operandLength: UInt8 {
        return definition.operandLength
    }

    init(_ opCode: OpCode, _ disassembly: String, _ definition: Definition, _ timing: Instruction.Timing) {
        self.opCode = opCode
        self.disassembly = disassembly
        self.definition = definition
        self.timing = timing
    }

    enum Timing {
        case Constant(_ cycleCount: CPU.CycleCount)
        case Variable(_ cycleCountIfTaken: CPU.CycleCount, _ cycleCountIfNotTaken: CPU.CycleCount)
    }

    enum InstructionOrSet {
        case Instruction(_ instruction: Instruction)
        case Set(_ subInstructions: Set)

        var operandLength: UInt8 {
            switch self {
            case let .Instruction(instruction):
                return instruction.operandLength
            case let .Set(subInstructions):
                return 1 + subInstructions.maxOperandLength
            }
        }
    }

    struct Set {
        private let instructions: [OpCode: InstructionOrSet]

        var maxOperandLength: UInt8 {
            return instructions.values.map { $0.operandLength }.max() ?? 0
        }

        init(instructions: [OpCode: InstructionOrSet]) {
            Self.assertComplete(Array(instructions.keys))
            self.instructions = instructions
        }

        subscript(opCode: OpCode) -> InstructionOrSet {
            // Safe to unwrap here because we know that all possible OpCodes have a value
            return self.instructions[opCode]!
        }

        static func assertComplete(_ opCodes: [OpCode]) {
            (OpCode.min...OpCode.max).forEach { opCode in
                guard opCodes.contains(opCode) else {
                    fatalError("Incomplete instruction set, missing opcode \(opCode.debugDescription)")
                }
            }
        }
    }

    enum Definition: Equatable {
        // ALU
        case Add(Operand.Definition, Operand.Definition, Carrying = .WithoutCarry)
        case And(Operand.Definition.OneByte), ExclusiveOr(Operand.Definition.OneByte), Or(Operand.Definition.OneByte)
        case CarryFlag(CarryFlagOperation)
        case Compare(Operand.Definition.OneByte)
        case CompareBit(Byte.Bit, Operand.Definition.OneByte)
        case Complement, DecimalAdjustAccumulator
        case IncrementByte(Operand.Definition.OneByte), DecrementByte(Operand.Definition.OneByte)
        case IncrementWord(Register.Pair.Name), DecrementWord(Register.Pair.Name)
        case ResetBit(Byte.Bit, Operand.Definition.OneByte)
        case Rotate(RotateDirection, Operand.Definition.OneByte, Carrying = .WithoutCarry, ZeroFlagBehaviour = .SetIfZero)
        case SetBit(Byte.Bit, Operand.Definition.OneByte)
        case Shift(ShiftDirection, Operand.Definition.OneByte)
        case Subtract(Operand.Definition.OneByte, Carrying = .WithoutCarry)
        case Swap(Operand.Definition.OneByte)

        // Control flow
        case Call(JumpCondition = .Unconditional)
        case Interrupts(Bool)
        case Jump(Operand.Definition, JumpCondition = .Unconditional)
        case Return(JumpCondition = .Unconditional)
        case ReturnFromInterrupt
        case Restart(ResetVector)

        // Data
        case LoadByte(LoadType = .Normal, into: Operand.Definition.OneByte, from: Operand.Definition.OneByte)
        case LoadWord(LoadType = .Normal, into: Operand.Definition.TwoByte, from: Operand.Definition.TwoByte)
        case Pop(Register.Pair.Name)
        case Push(Register.Pair.Name)

        // Misc
        case Halt, NoOp, Stop
        case Invalid

        var operandLength: UInt8 {
            switch self {
            // Definitions which take two operands
            case let .Add(a, b, _):
                return a.length + b.length
            case .LoadByte(_, into: let a, from: let b):
                return a.length + b.length
            case .LoadWord(_, into: let a, from: let b):
                return a.length + b.length
            // Definitions which take a single operand
            case let .DecrementByte(operand), let .IncrementByte(operand):
                return operand.length
            case let .Jump(operand, _):
                return operand.length
            case let .And(operand), let .Compare(operand), let .ExclusiveOr(operand), let .Or(operand), let .Rotate(_, operand, _, _),
                 let .Shift(_, operand), let .Subtract(operand, _):
                return operand.length
            // Definitions which take no operands
            case .CarryFlag, .CompareBit, .Complement, .DecimalAdjustAccumulator, .DecrementWord, .Halt, .IncrementWord, .Invalid,
                 .Interrupts, .NoOp, .Pop, .Push, .Restart, .ResetBit, .Return, .ReturnFromInterrupt, .SetBit, .Stop, .Swap:
                return 0
            // Call -- special case as it always takes an address
            case .Call:
                return Operand.Definition.TwoByte.ExtendedImmediate.length
            }
        }

        enum CarryFlagOperation: Equatable {
            case Complement, Set
        }

        enum Carrying: Equatable {
            case WithCarry, WithoutCarry

            var bool: Bool { return self == .WithCarry }
        }

        enum JumpCondition: String, Equatable {
            case IfCarry, IfNotCarry, IfNonZero, IfZero, Unconditional
        }

        enum LoadType: Equatable {
            case Normal
            case AndDecrement(Register.Pair.Name)
            case AndIncrement(Register.Pair.Name)
        }

        enum ResetVector: Address, Equatable {
            case _00 = 0x0000
            case _08 = 0x0008
            case _10 = 0x0010
            case _18 = 0x0018
            case _20 = 0x0020
            case _28 = 0x0028
            case _30 = 0x0030
            case _38 = 0x0038

            // Interrupt vectors
            case _40 = 0x0040
            case _48 = 0x0048
            case _50 = 0x0050
            case _58 = 0x0058
            case _60 = 0x0060
        }

        enum RotateDirection: Equatable {
            case Left, Right
        }

        enum ShiftDirection: Equatable {
            case LeftArithmetic, RightArithmetic, RightLogical
        }

        enum ZeroFlagBehaviour: Equatable {
            case Clear, SetIfZero
        }
    }
}

extension Instruction.OpCode {
    var debugDescription: String {
        return String(format: "%02X", self)
    }
}
