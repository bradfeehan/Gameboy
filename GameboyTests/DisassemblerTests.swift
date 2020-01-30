//
//  DisassemblerTests.swift
//  GameboyTests
//
//  Created by Brad Feehan on 8/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

import XCTest

class DisassemblerTests: XCTestCase {
    private let disassembler = Disassembler()

    func testInstructionSet() {
        (Instruction.OpCode.min...Instruction.OpCode.max).forEach { opCode in
            testInstruction(opCode: opCode, instructionOrSet: InstructionSet[opCode])
        }
    }

    private func testInstruction(opCode: Instruction.OpCode, instructionOrSet: Instruction.InstructionOrSet) {
        switch instructionOrSet {
        case let .Instruction(instruction):
            testInstruction(opCode: opCode, instruction: instruction)
        case let .Set(subInstructions):
            (Instruction.OpCode.min...Instruction.OpCode.max).forEach { opCode in
                testInstruction(opCode: opCode, instructionOrSet: subInstructions[opCode])
            }
        }
    }

    private func testInstruction(opCode: Instruction.OpCode, instruction: Instruction) {
        let mnemonic = disassembler.disassemble(instruction)
        XCTAssertEqual(mnemonic, instruction.disassembly, "OpCode \(opCode.debugDescription): expected '\(instruction.disassembly)', got '\(mnemonic)'")
    }
}
