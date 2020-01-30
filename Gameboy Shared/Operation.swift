//
//  Operation.swift
//  Gameboy
//
//  Created by Brad Feehan on 12/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

enum Operation {
    // ALU
    case Add(Operand, Operand, Instruction.Definition.Carrying = .WithoutCarry)
    case And(Operand.OneByte), ExclusiveOr(Operand.OneByte), Or(Operand.OneByte), Swap(Operand.OneByte)
    case CarryFlag(Instruction.Definition.CarryFlagOperation)
    case Compare(Operand.OneByte)
    case CompareBit(Byte.Bit, Operand.OneByte)
    case Complement, DecimalAdjustAccumulator
    case IncrementByte(Operand.OneByte), DecrementByte(Operand.OneByte)
    case IncrementWord(Register.Pair.Name), DecrementWord(Register.Pair.Name)
    case ResetBit(Byte.Bit, Operand.OneByte)
    case Rotate(Instruction.Definition.RotateDirection, Operand.OneByte, Instruction.Definition.Carrying = .WithoutCarry,
        Instruction.Definition.ZeroFlagBehaviour = .SetIfZero)
    case SetBit(Byte.Bit, Operand.OneByte)
    case Shift(Instruction.Definition.ShiftDirection, Operand.OneByte)
    case Subtract(Operand.OneByte, Instruction.Definition.Carrying = .WithoutCarry)

    // Control flow
    case Call(Address, Instruction.Definition.JumpCondition = .Unconditional)
    case Interrupts(Bool)
    case Jump(Operand, Instruction.Definition.JumpCondition = .Unconditional)
    case Return(Instruction.Definition.JumpCondition = .Unconditional)
    case ReturnFromInterrupt
    case Restart(Instruction.Definition.ResetVector)

    // Data
    case LoadByte(Instruction.Definition.LoadType = .Normal, into: Operand.OneByte, from: Operand.OneByte)
    case LoadWord(Instruction.Definition.LoadType = .Normal, into: Operand.TwoByte, from: Operand.TwoByte)
    case Pop(Register.Pair.Name)
    case Push(Register.Pair.Name)

    // Misc
    case Halt, NoOp, Stop
    case Invalid(address: Address, opCode: Instruction.OpCode)

    var operandLength: UInt8 {
        switch self {
        // Definitions which take two operands
        case let .Add(a, b, _):
            return a.length + b.length
        case let .LoadByte(_, into: a, from: b):
            return a.length + b.length
        case let .LoadWord(_, into: a, from: b):
            return a.length + b.length
        // Definitions which take a single operand
        case let .DecrementByte(operand), let .IncrementByte(operand):
            return operand.length
        case let .Jump(operand, _):
            return operand.length
        case let .And(operand), let .Compare(operand), let .ExclusiveOr(operand), let .Or(operand), let .Rotate(_, operand, _, .Clear),
             let .Subtract(operand, _):
            return operand.length
        // 0xCB needs one extra
        case .Rotate, .Shift, .Swap, .CompareBit, .SetBit, .ResetBit:
            return 1
        // Definitions which take no operands
        case .CarryFlag, .Complement, .DecimalAdjustAccumulator, .DecrementWord, .Halt, .IncrementWord, .Invalid, .Interrupts, .NoOp, .Pop,
             .Push, .Restart, .Return, .ReturnFromInterrupt, .Stop:
            return 0
        // Call -- special case as it always takes an address
        case .Call:
            return Operand.Definition.TwoByte.ExtendedImmediate.length
        }
    }
}
