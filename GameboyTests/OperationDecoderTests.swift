//
//  OperationTests.swift
//  GameboyTests
//
//  Created by Brad Feehan on 15/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

import XCTest

class OperationDecoderTests: XCTestCase {
    var gameboy: Gameboy {
        let value = Gameboy()
        value[0x0100] = 0x13
        value[0x0101] = 0x37
        value.cpu.registers.PC = 0x0100
        return value
    }

    func testOperationsRoundTrip() {
        (Instruction.OpCode.min...Instruction.OpCode.max).forEach { opCode in
            testOperationRoundTrip(opCode: opCode, instructionOrSet: InstructionSet[opCode])
        }
    }

    func testOperationRoundTrip(opCode: Instruction.OpCode, instructionOrSet: Instruction.InstructionOrSet) {
        switch instructionOrSet {
        case let .Instruction(instruction):
            testOperationRoundTrip(opCode: opCode, instruction: instruction)
        case let .Set(subInstructions):
            (Instruction.OpCode.min...Instruction.OpCode.max).forEach { subOpCode in
                testOperationRoundTrip(opCode: subOpCode, instructionOrSet: subInstructions[subOpCode])
            }
        }
    }

    func testOperationRoundTrip(opCode: Instruction.OpCode, instruction: Instruction) {
        let gb = gameboy
        let decoder = Operation.Decoder(cpu: gb.cpu)
        let operation = decoder.decode(.Instruction(instruction)).0

        let actual = expectedDefinition(for: operation)
        let expected = instruction.definition

        XCTAssert(actual == expected, "Decoded instruction mismatch: got \(actual), expected \(expected)")
    }

    private func expectedDefinition(for operation: Operation) -> Instruction.Definition {
        switch operation {
        case let .Add(operand1, operand2, carrying):
            return .Add(operand1.definition, operand2.definition, carrying)
        case let .And(operand):
            return .And(operand.definition)
        case let .Call(_, condition):
            return .Call(condition)
        case let .CarryFlag(enabled):
            return .CarryFlag(enabled)
        case let .CompareBit(bit, operand):
            return .CompareBit(bit, operand.definition)
        case let .Compare(operand):
            return .Compare(operand.definition)
        case .Complement:
            return .Complement
        case .DecimalAdjustAccumulator:
            return .DecimalAdjustAccumulator
        case let .DecrementByte(operand):
            return .DecrementByte(operand.definition)
        case let .DecrementWord(registerPairName):
            return .DecrementWord(registerPairName)
        case let .ExclusiveOr(operand):
            return .ExclusiveOr(operand.definition)
        case .Halt:
            return .Halt
        case let .IncrementByte(operand):
            return .IncrementByte(operand.definition)
        case let .IncrementWord(registerPairName):
            return .IncrementWord(registerPairName)
        case let .Interrupts(enabled):
            return .Interrupts(enabled)
        case .Invalid:
            return .Invalid
        case let .Jump(operand, condition):
            return .Jump(operand.definition, condition)
        case let .LoadByte(type, into: destination, from: source):
            return .LoadByte(type, into: destination.definition, from: source.definition)
        case let .LoadWord(type, into: destination, from: source):
            return .LoadWord(type, into: destination.definition, from: source.definition)
        case .NoOp:
            return .NoOp
        case let .Or(operand):
            return .Or(operand.definition)
        case let .Pop(name):
            return .Pop(name)
        case let .Push(name):
            return .Push(name)
        case let .Restart(vector):
            return .Restart(vector)
        case let .ResetBit(bit, operand):
            return .ResetBit(bit, operand.definition)
        case let .Return(condition):
            return .Return(condition)
        case .ReturnFromInterrupt:
            return .ReturnFromInterrupt
        case let .Rotate(direction, operand, carrying, zeroFlagBehaviour):
            return .Rotate(direction, operand.definition, carrying, zeroFlagBehaviour)
        case let .SetBit(bit, operand):
            return .SetBit(bit, operand.definition)
        case let .Shift(direction, operand):
            return .Shift(direction, operand.definition)
        case .Stop:
            return .Stop
        case let .Subtract(operand, carrying):
            return .Subtract(operand.definition, carrying)
        case let .Swap(operand):
            return .Swap(operand.definition)
        }
    }
}

