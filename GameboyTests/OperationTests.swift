//
//  OperationTests.swift
//  GameboyTests
//
//  Created by Brad Feehan on 17/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

import XCTest

class OperationTests: XCTestCase {
    var gameboy = Gameboy()
    var expectedRegisters = Register.Set()

    override func setUp() {
        self.gameboy = Gameboy()
        self.expectedRegisters = gameboy.cpu.registers
    }

    // ####################################################################################################################################
    // ##  OPERATIONS  ####################################################################################################################
    // ####################################################################################################################################

    // - MARK: 0x00
    func testNoOp() {
        gameboy.cpu.execute(.NoOp)
        assertRegistersMatch()
    }

    // - MARK: 0x01
    func testLoadBCFromImmediate() {
        testLoadRegisterPairFromImmediate(.BC)
    }

    // - MARK: 0x02
    func testLoadBCIndirectFromA() {
        testLoadRegisterIndirectFromA(.BC)
    }

    // - MARK: 0x03
    func testIncBC() {
        testInc(.BC)
    }

    // - MARK: 0x04
    func testIncB() {
        testIncWithoutFlags(.B)
    }

    func testIncBWithHalfCarry() {
        testIncWithHalfCarry(.B)
    }

    func testIncBWithHalfCarryAndZero() {
        testIncWithHalfCarryAndZero(.B)
    }

    // - MARK: 0x05
    func testDecB() {
        testDecWithoutFlags(.B)
    }

    func testDecBWithHalfCarry() {
        testDecWithHalfCarry(.B)
    }

    func testDecBWithZero() {
        testDecWithZero(.B)
    }

    // - MARK: 0x06
    func testLoadBFromImmediate() {
        testLoadRegisterFromImmediate(.B)
    }

    // - MARK: 0x07
    func testRotateLeftWithCarryA() {
        testRotateLeftWithCarryRegister(.A)
    }

    func testRotateLeftWithCarryAWithCarry() {
        testRotateLeftWithCarryRegisterWithCarry(.A)
    }

    func testRotateLeftWithCarryAWithCarrySetWithCarry() {
        testRotateLeftWithCarryRegisterWithCarrySetWithCarry(.A)
    }

    func testRotateLeftWithCarryAWithCarrySet() {
        testRotateLeftWithCarryRegisterWithCarrySet(.A)
    }

    func testRotateLeftWithCarryAWithZero() {
        testRotateLeftWithCarryRegisterWithZero(.A)
    }

    func testRotateLeftWithCarryAWithZeroWithCarry() {
        testRotateLeftWithCarryRegisterWithZeroWithCarry(.A)
    }

    // - MARK: 0x08
    func testLoadAddressFromSP() {
        gameboy.cpu.execute(.LoadWord(into: .Address(address: 0x8765, value: 0x00), from: .RegisterExtended(name: .SP, value: 0xa5a5)))
        assertRegistersMatch()
        let expectedWord = Word(gameboy[0x8765], gameboy[0x8766])
        assertMatch(expectedWord, 0xa5a5, 0x8765)
    }

    // - MARK: 0x09
    func testAddHLBC() {
        testAddHL(.BC)
    }

    func testAddHLBCWithHalfCarry() {
        testAddHLWithHalfCarry(.BC)
    }

    func testAddHLBCWithCarry() {
        testAddHLWithCarry(.BC)
    }

    func testAddHLBCWithCarryAndHalfCarry() {
        testAddHLWithCarryAndHalfCarry(.BC)
    }

    // - MARK: 0x0A
    func testLoadAFromBCIndirect() {
        testLoadAFromRegisterIndirect(.BC)
    }

    // - MARK: 0x0B
    func testDecBC() {
        testDec(.BC)
    }

    // - MARK: 0x0C
    func testIncC() {
        testIncWithoutFlags(.C)
    }

    func testIncCWithHalfCarry() {
        testIncWithHalfCarry(.C)
    }

    func testIncCWithHalfCarryAndZero() {
        testIncWithHalfCarryAndZero(.C)
    }

    // - MARK: 0x0D
    func testDecC() {
        testDecWithoutFlags(.C)
    }

    func testDecCWithHalfCarry() {
        testDecWithHalfCarry(.C)
    }

    func testDecCWithZero() {
        testDecWithZero(.C)
    }

    // - MARK: 0x0E
    func testLoadCFromImmediate() {
        testLoadRegisterFromImmediate(.C)
    }

    // - MARK: 0x0F
    func testRotateRightWithCarryA() {
        testRotateRightWithCarryRegister(.A)
    }

    func testRotateRightWithCarryAWithCarrySet() {
        testRotateRightWithCarryRegisterWithCarrySet(.A)
    }

    // - MARK: 0x10
    func testStop() {
        gameboy.cpu.execute(.Stop)
        assertRegistersMatch()
        XCTAssert(gameboy.cpu.stopped, "Expected CPU to be stopped but was not stopped")
    }

    // - MARK: 0x11
    func testLoadDEFromImmediate() {
        testLoadRegisterPairFromImmediate(.DE)
    }

    // - MARK: 0x12
    func testLoadDEIndirectFromA() {
        testLoadRegisterIndirectFromA(.DE)
    }

    // - MARK: 0x13
    func testIncDE() {
        testInc(.DE)
    }

    // - MARK: 0x14
    func testIncD() {
        testIncWithoutFlags(.D)
    }

    func testIncDWithHalfCarry() {
        testIncWithHalfCarry(.D)
    }

    func testIncDWithHalfCarryAndZero() {
        testIncWithHalfCarryAndZero(.D)
    }

    // - MARK: 0x15
    func testDecD() {
        testDecWithoutFlags(.D)
    }

    func testDecDWithHalfCarry() {
        testDecWithHalfCarry(.D)
    }

    func testDecDWithZero() {
        testDecWithZero(.D)
    }

    // - MARK: 0x16
    func testLoadDFromImmediate() {
        testLoadRegisterFromImmediate(.D)
    }

    // - MARK: 0x17
    func testRotateLeftA() {
        testRotateLeftRegister(.A)
    }

    func testRotateLeftAWithCarry() {
        testRotateLeftRegisterWithCarry(.A)
    }

    func testRotateLeftAWithCarrySetWithCarry() {
        testRotateLeftRegisterWithCarrySetWithCarry(.A)
    }

    func testRotateLeftAWithCarrySet() {
        testRotateLeftRegisterWithCarrySet(.A)
    }

    func testRotateLeftAWithZero() {
        testRotateLeftRegisterWithZero(.A)
    }

    func testRotateLeftAWithZeroWithCarry() {
        testRotateLeftRegisterWithZeroWithCarry(.A)
    }

    // - MARK: 0x18
    func testJumpRelativeForwards() {
        gameboy.cpu.registers.PC = 0x1000
        expectedRegisters.PC = 0x1030
        gameboy.cpu.execute(.Jump(.Relative(0x30)))
        assertRegistersMatch()
    }

    func testJumpRelativeBackwards() {
        gameboy.cpu.registers.PC = 0x1000
        expectedRegisters.PC = 0x0F90
        gameboy.cpu.execute(.Jump(.Relative(-0x70)))
        assertRegistersMatch()
    }

    // - MARK: 0x19
    func testAddHLDE() {
        testAddHL(.DE)
    }

    func testAddHLDEWithHalfCarry() {
        testAddHLWithHalfCarry(.DE)
    }

    func testAddHLDEWithCarry() {
        testAddHLWithCarry(.DE)
    }

    func testAddHLDEWithCarryAndHalfCarry() {
        testAddHLWithCarryAndHalfCarry(.DE)
    }

    // - MARK: 0x1A
    func testLoadAFromDEIndirect() {
        testLoadAFromRegisterIndirect(.DE)
    }

    // - MARK: 0x1B
    func testDecDE() {
        testDec(.DE)
    }

    // - MARK: 0x1C
    func testIncE() {
        testIncWithoutFlags(.E)
    }

    func testIncEWithHalfCarry() {
        testIncWithHalfCarry(.E)
    }

    func testIncEWithHalfCarryAndZero() {
        testIncWithHalfCarryAndZero(.E)
    }

    // - MARK: 0x1D
    func testDecE() {
        testDecWithoutFlags(.E)
    }

    func testDecEWithHalfCarry() {
        testDecWithHalfCarry(.E)
    }

    func testDecEWithZero() {
        testDecWithZero(.E)
    }

    // - MARK: 0x1E
    func testLoadEFromImmediate() {
        testLoadRegisterFromImmediate(.E)
    }

    // - MARK: 0x1F
    func testRotateRightA() {
        testRotateRightRegister(.A)
    }

    func testRotateRightAWithCarrySet() {
        testRotateRightRegisterWithCarrySet(.A)
    }

    // - MARK: 0x20
    func testJumpRelativeIfNonZeroTakenForwards() {
        gameboy.cpu.registers.PC = 0x1000
        expectedRegisters.PC = 0x1030
        gameboy.cpu.execute(.Jump(.Relative(0x30), .IfNonZero))
        assertRegistersMatch()
    }

    func testJumpRelativeIfNonZeroTakenBackwards() {
        gameboy.cpu.registers.PC = 0x1000
        expectedRegisters.PC = 0x0F90
        gameboy.cpu.execute(.Jump(.Relative(-0x70), .IfNonZero))
        assertRegistersMatch()
    }

    func testJumpRelativeIfNonZeroNotTakenForwards() {
        gameboy.cpu.registers.PC = 0x1000
        gameboy.cpu.registers.set(flag: .Z, value: true)
        expectedRegisters.PC = 0x1000
        expectedRegisters.set(flag: .Z, value: true)
        gameboy.cpu.execute(.Jump(.Relative(0x30), .IfNonZero))
        assertRegistersMatch()
    }

    func testJumpRelativeIfNonZeroNotTakenBackwards() {
        gameboy.cpu.registers.PC = 0x1000
        gameboy.cpu.registers.set(flag: .Z, value: true)
        expectedRegisters.PC = 0x1000
        expectedRegisters.set(flag: .Z, value: true)
        gameboy.cpu.execute(.Jump(.Relative(-0x70), .IfNonZero))
        assertRegistersMatch()
    }

    // - MARK: 0x21
    func testLoadHLFromImmediate() {
        testLoadRegisterPairFromImmediate(.HL)
    }

    // - MARK: 0x22
    func testLoadAndIncrementHLIndirectFromA() {
        testLoadRegisterIndirectFromA(.HL, type: .AndIncrement(.HL))
    }

    // - MARK: 0x23
    func testIncHL() {
        testInc(.HL)
    }

    // - MARK: 0x24
    func testIncH() {
        testIncWithoutFlags(.H)
    }

    func testIncHWithHalfCarry() {
        testIncWithHalfCarry(.H)
    }

    func testIncHWithHalfCarryAndZero() {
        testIncWithHalfCarryAndZero(.H)
    }

    // - MARK: 0x25
    func testDecH() {
        testDecWithoutFlags(.H)
    }

    func testDecHWithHalfCarry() {
        testDecWithHalfCarry(.H)
    }

    func testDecHWithZero() {
        testDecWithZero(.H)
    }

    // - MARK: 0x26
    func testLoadHFromImmediate() {
        testLoadRegisterFromImmediate(.H)
    }

    // - MARK: 0x27
    func testDecimalAdjustAccumulatorAdd() {
        testDecimalAdjustAccumulatorAdd(.WithoutCarry)
    }

    func testDecimalAdjustAccumulatorAddWithCarryWithoutCarrySet() {
        testDecimalAdjustAccumulatorAdd(.WithCarry)
    }

    func testDecimalAdjustAccumulatorAddWithCarryWithCarrySet() {
        testDecimalAdjustAccumulatorAdd(.WithCarry, carrySet: true)
    }

    func testDecimalAdjustAccumulatorInc() {
        (0...99).forEach { oldValue in
            let newValue = oldValue + 1

            let bcdOldValue = ((oldValue / 10) << 4) | (oldValue % 10)
            let bcdNewValue = ((((newValue % 100) / 10) << 4) | (newValue % 10)) & 0xff

            gameboy.cpu.registers.A = Byte(bcdOldValue)
            gameboy.cpu.registers.set(flag: .C, value: false)

            expectedRegisters.A = Byte(bcdNewValue)
            expectedRegisters.set(flag: .Z, value: bcdNewValue == 0)
            expectedRegisters.set(flag: .C, value: newValue > 99)

            gameboy.cpu.execute(.IncrementByte(.Register(name: .A, value: Byte(bcdOldValue))))
            gameboy.cpu.execute(.DecimalAdjustAccumulator)

            assertRegistersMatch(description: "INC(\(oldValue))")
        }
    }

    // TODO: testDecimalAdjustAccumulatorSubtract
    // TODO: testDecimalAdjustAccumulatorSubtractWithCarryWithoutCarrySet
    // TODO: testDecimalAdjustAccumulatorSubtractWithCarryWithCarrySet

    func testDecimalAdjustAccumulatorDec() {
        (0...99).forEach { oldValue in
            let newValue = (oldValue == 0 ? 99 : oldValue - 1)

            let bcdOldValue = ((oldValue / 10) << 4) | (oldValue % 10)
            let bcdNewValue = ((((newValue % 100) / 10) << 4) | (newValue % 10)) & 0xff

            gameboy.cpu.registers.A = Byte(bcdOldValue)
            gameboy.cpu.registers.set(flag: .C, value: false)

            expectedRegisters.A = Byte(bcdNewValue)
            expectedRegisters.set(flag: .Z, value: bcdNewValue == 0)
            expectedRegisters.set(flag: .N, value: true)
            expectedRegisters.set(flag: .C, value: oldValue == 0)

            gameboy.cpu.execute(.DecrementByte(.Register(name: .A, value: Byte(bcdOldValue))))
            gameboy.cpu.execute(.DecimalAdjustAccumulator)

            assertRegistersMatch(description: "DEC(\(oldValue))")
        }
    }

    // - MARK: 0x28
    func testJumpRelativeIfZeroTakenForwards() {
        gameboy.cpu.registers.PC = 0x1000
        gameboy.cpu.registers.set(flag: .Z, value: true)
        expectedRegisters.PC = 0x1030
        expectedRegisters.set(flag: .Z, value: true)
        gameboy.cpu.execute(.Jump(.Relative(0x30), .IfZero))
        assertRegistersMatch()
    }

    func testJumpRelativeIfZeroTakenBackwards() {
        gameboy.cpu.registers.PC = 0x1000
        gameboy.cpu.registers.set(flag: .Z, value: true)
        expectedRegisters.PC = 0x0F90
        expectedRegisters.set(flag: .Z, value: true)
        gameboy.cpu.execute(.Jump(.Relative(-0x70), .IfZero))
        assertRegistersMatch()
    }

    func testJumpRelativeIfZeroNotTakenForwards() {
        gameboy.cpu.registers.PC = 0x1000
        expectedRegisters.PC = 0x1000
        gameboy.cpu.execute(.Jump(.Relative(0x30), .IfZero))
        assertRegistersMatch()
    }

    func testJumpRelativeIfZeroNotTakenBackwards() {
        gameboy.cpu.registers.PC = 0x1000
        expectedRegisters.PC = 0x1000
        gameboy.cpu.execute(.Jump(.Relative(-0x70), .IfZero))
        assertRegistersMatch()
    }

    // - MARK: 0x29
    func testAddHLHL() {
        testAddHL(.HL)
    }

    func testAddHLHLWithHalfCarry() {
        testAddHLWithHalfCarry(.HL)
    }

    func testAddHLHLWithCarry() {
        testAddHLWithCarry(.HL)
    }

    func testAddHLHLWithCarryAndHalfCarry() {
        testAddHLWithCarryAndHalfCarry(.HL)
    }

    // - MARK: 0x2A
    func testLoadAFromHLIndirectAndIncrement() {
        testLoadAFromRegisterIndirect(.HL, type: .AndIncrement(.HL))
    }

    // - MARK: 0x2B
    func testDecHL() {
        testDec(.HL)
    }

    // - MARK: 0x2C
    func testIncL() {
        testIncWithoutFlags(.L)
    }

    func testIncLWithHalfCarry() {
        testIncWithHalfCarry(.L)
    }

    func testIncLWithHalfCarryAndZero() {
        testIncWithHalfCarryAndZero(.L)
    }

    // - MARK: 0x2D
    func testDecL() {
        testDecWithoutFlags(.L)
    }

    func testDecLWithHalfCarry() {
        testDecWithHalfCarry(.L)
    }

    func testDecLWithZero() {
        testDecWithZero(.L)
    }

    // - MARK: 0x2E
    func testLoadLFromImmediate() {
        testLoadRegisterFromImmediate(.L)
    }

    // - MARK: 0x2F
    func testComplement() {
        gameboy.cpu.registers.A = 0xAA
        expectedRegisters.A = 0x55
        expectedRegisters.set(flag: .N, value: true)
        expectedRegisters.set(flag: .H, value: true)
        gameboy.cpu.execute(.Complement)
        assertRegistersMatch()
    }




    // - MARK: 0x30
//    0x30: .Instruction(Instruction(0x30, "JR NC,% +03X", .Jump(.Relative, .IfNotCarry))),
//    0x31: .Instruction(Instruction(0x31, "LD SP,%04X", .LoadWord(into: .RegisterExtended(.SP), from: .ExtendedImmediate))),
//    0x32: .Instruction(Instruction(0x32, "LDD (HL),A", .LoadByte(.AndDecrement(.HL), into: .RegisterIndirect(.HL), from: .Register(.A)))),
//    0x33: .Instruction(Instruction(0x33, "INC SP", .IncrementWord(.SP))),
//    0x34: .Instruction(Instruction(0x34, "INC (HL)", .IncrementByte(.RegisterIndirect(.HL)))),
//    0x35: .Instruction(Instruction(0x35, "DEC (HL)", .DecrementByte(.RegisterIndirect(.HL)))),
//    0x36: .Instruction(Instruction(0x36, "LD (HL),%02X", .LoadByte(into: .RegisterIndirect(.HL), from: .Immediate))),
//    0x37: .Instruction(Instruction(0x37, "SCF", .CarryFlag(.Set))),
//    0x38: .Instruction(Instruction(0x38, "JR C,% +03X", .Jump(.Relative, .IfCarry))),
//    0x39: .Instruction(Instruction(0x39, "ADD HL,SP", .Add(.Word(.RegisterExtended(.HL)), .Word(.RegisterExtended(.SP))))),
//    0x3A: .Instruction(Instruction(0x3A, "LDD A,(HL)", .LoadByte(.AndDecrement(.HL), into: .Register(.A), from: .RegisterIndirect(.HL)))),
//    0x3B: .Instruction(Instruction(0x3B, "DEC SP", .DecrementWord(.SP))),
//    0x3C: .Instruction(Instruction(0x3C, "INC A", .IncrementByte(.Register(.A)))),
//    0x3D: .Instruction(Instruction(0x3D, "DEC A", .DecrementByte(.Register(.A)))),
//    0x3E: .Instruction(Instruction(0x3E, "LD A,%02X", .LoadByte(into: .Register(.A), from: .Immediate))),
//    0x3F: .Instruction(Instruction(0x3F, "CCF", .CarryFlag(.Complement))),
//
    // - MARK: 0x40
//    0x40: .Instruction(Instruction(0x40, "LD B,B", .LoadByte(into: .Register(.B), from: .Register(.B)))),
//    0x41: .Instruction(Instruction(0x41, "LD B,C", .LoadByte(into: .Register(.B), from: .Register(.C)))),
//    0x42: .Instruction(Instruction(0x42, "LD B,D", .LoadByte(into: .Register(.B), from: .Register(.D)))),
//    0x43: .Instruction(Instruction(0x43, "LD B,E", .LoadByte(into: .Register(.B), from: .Register(.E)))),
//    0x44: .Instruction(Instruction(0x44, "LD B,H", .LoadByte(into: .Register(.B), from: .Register(.H)))),
//    0x45: .Instruction(Instruction(0x45, "LD B,L", .LoadByte(into: .Register(.B), from: .Register(.L)))),
//    0x46: .Instruction(Instruction(0x46, "LD B,(HL)", .LoadByte(into: .Register(.B), from: .RegisterIndirect(.HL)))),
//    0x47: .Instruction(Instruction(0x47, "LD B,A", .LoadByte(into: .Register(.B), from: .Register(.A)))),
//    0x48: .Instruction(Instruction(0x48, "LD C,B", .LoadByte(into: .Register(.C), from: .Register(.B)))),
//    0x49: .Instruction(Instruction(0x49, "LD C,C", .LoadByte(into: .Register(.C), from: .Register(.C)))),
//    0x4A: .Instruction(Instruction(0x4A, "LD C,D", .LoadByte(into: .Register(.C), from: .Register(.D)))),
//    0x4B: .Instruction(Instruction(0x4B, "LD C,E", .LoadByte(into: .Register(.C), from: .Register(.E)))),
//    0x4C: .Instruction(Instruction(0x4C, "LD C,H", .LoadByte(into: .Register(.C), from: .Register(.H)))),
//    0x4D: .Instruction(Instruction(0x4D, "LD C,L", .LoadByte(into: .Register(.C), from: .Register(.L)))),
//    0x4E: .Instruction(Instruction(0x4E, "LD C,(HL)", .LoadByte(into: .Register(.C), from: .RegisterIndirect(.HL)))),
//    0x4F: .Instruction(Instruction(0x4F, "LD C,A", .LoadByte(into: .Register(.C), from: .Register(.A)))),
//
    // - MARK: 0x50
//    0x50: .Instruction(Instruction(0x50, "LD D,B", .LoadByte(into: .Register(.D), from: .Register(.B)))),
//    0x51: .Instruction(Instruction(0x51, "LD D,C", .LoadByte(into: .Register(.D), from: .Register(.C)))),
//    0x52: .Instruction(Instruction(0x52, "LD D,D", .LoadByte(into: .Register(.D), from: .Register(.D)))),
//    0x53: .Instruction(Instruction(0x53, "LD D,E", .LoadByte(into: .Register(.D), from: .Register(.E)))),
//    0x54: .Instruction(Instruction(0x54, "LD D,H", .LoadByte(into: .Register(.D), from: .Register(.H)))),
//    0x55: .Instruction(Instruction(0x55, "LD D,L", .LoadByte(into: .Register(.D), from: .Register(.L)))),
//    0x56: .Instruction(Instruction(0x56, "LD D,(HL)", .LoadByte(into: .Register(.D), from: .RegisterIndirect(.HL)))),
//    0x57: .Instruction(Instruction(0x57, "LD D,A", .LoadByte(into: .Register(.D), from: .Register(.A)))),
//    0x58: .Instruction(Instruction(0x58, "LD E,B", .LoadByte(into: .Register(.E), from: .Register(.B)))),
//    0x59: .Instruction(Instruction(0x59, "LD E,C", .LoadByte(into: .Register(.E), from: .Register(.C)))),
//    0x5A: .Instruction(Instruction(0x5A, "LD E,D", .LoadByte(into: .Register(.E), from: .Register(.D)))),
//    0x5B: .Instruction(Instruction(0x5B, "LD E,E", .LoadByte(into: .Register(.E), from: .Register(.E)))),
//    0x5C: .Instruction(Instruction(0x5C, "LD E,H", .LoadByte(into: .Register(.E), from: .Register(.H)))),
//    0x5D: .Instruction(Instruction(0x5D, "LD E,L", .LoadByte(into: .Register(.E), from: .Register(.L)))),
//    0x5E: .Instruction(Instruction(0x5E, "LD E,(HL)", .LoadByte(into: .Register(.E), from: .RegisterIndirect(.HL)))),
//    0x5F: .Instruction(Instruction(0x5F, "LD E,A", .LoadByte(into: .Register(.E), from: .Register(.A)))),
//
    // - MARK: 0x60
//    0x60: .Instruction(Instruction(0x60, "LD H,B", .LoadByte(into: .Register(.H), from: .Register(.B)))),
//    0x61: .Instruction(Instruction(0x61, "LD H,C", .LoadByte(into: .Register(.H), from: .Register(.C)))),
//    0x62: .Instruction(Instruction(0x62, "LD H,D", .LoadByte(into: .Register(.H), from: .Register(.D)))),
//    0x63: .Instruction(Instruction(0x63, "LD H,E", .LoadByte(into: .Register(.H), from: .Register(.E)))),
//    0x64: .Instruction(Instruction(0x64, "LD H,H", .LoadByte(into: .Register(.H), from: .Register(.H)))),
//    0x65: .Instruction(Instruction(0x65, "LD H,L", .LoadByte(into: .Register(.H), from: .Register(.L)))),
//    0x66: .Instruction(Instruction(0x66, "LD H,(HL)", .LoadByte(into: .Register(.H), from: .RegisterIndirect(.HL)))),
//    0x67: .Instruction(Instruction(0x67, "LD H,A", .LoadByte(into: .Register(.H), from: .Register(.A)))),
//    0x68: .Instruction(Instruction(0x68, "LD L,B", .LoadByte(into: .Register(.L), from: .Register(.B)))),
//    0x69: .Instruction(Instruction(0x69, "LD L,C", .LoadByte(into: .Register(.L), from: .Register(.C)))),
//    0x6A: .Instruction(Instruction(0x6A, "LD L,D", .LoadByte(into: .Register(.L), from: .Register(.D)))),
//    0x6B: .Instruction(Instruction(0x6B, "LD L,E", .LoadByte(into: .Register(.L), from: .Register(.E)))),
//    0x6C: .Instruction(Instruction(0x6C, "LD L,H", .LoadByte(into: .Register(.L), from: .Register(.H)))),
//    0x6D: .Instruction(Instruction(0x6D, "LD L,L", .LoadByte(into: .Register(.L), from: .Register(.L)))),
//    0x6E: .Instruction(Instruction(0x6E, "LD L,(HL)", .LoadByte(into: .Register(.L), from: .RegisterIndirect(.HL)))),
//    0x6F: .Instruction(Instruction(0x6F, "LD L,A", .LoadByte(into: .Register(.L), from: .Register(.A)))),
//
    // - MARK: 0x70
//    0x70: .Instruction(Instruction(0x70, "LD (HL),B", .LoadByte(into: .RegisterIndirect(.HL), from: .Register(.B)))),
//    0x71: .Instruction(Instruction(0x71, "LD (HL),C", .LoadByte(into: .RegisterIndirect(.HL), from: .Register(.C)))),
//    0x72: .Instruction(Instruction(0x72, "LD (HL),D", .LoadByte(into: .RegisterIndirect(.HL), from: .Register(.D)))),
//    0x73: .Instruction(Instruction(0x73, "LD (HL),E", .LoadByte(into: .RegisterIndirect(.HL), from: .Register(.E)))),
//    0x74: .Instruction(Instruction(0x74, "LD (HL),H", .LoadByte(into: .RegisterIndirect(.HL), from: .Register(.H)))),
//    0x75: .Instruction(Instruction(0x75, "LD (HL),L", .LoadByte(into: .RegisterIndirect(.HL), from: .Register(.L)))),
//    0x76: .Instruction(Instruction(0x76, "HALT", .Halt)),
//    0x77: .Instruction(Instruction(0x77, "LD (HL),A", .LoadByte(into: .RegisterIndirect(.HL), from: .Register(.A)))),
//    0x78: .Instruction(Instruction(0x78, "LD A,B", .LoadByte(into: .Register(.A), from: .Register(.B)))),
//    0x79: .Instruction(Instruction(0x79, "LD A,C", .LoadByte(into: .Register(.A), from: .Register(.C)))),
//    0x7A: .Instruction(Instruction(0x7A, "LD A,D", .LoadByte(into: .Register(.A), from: .Register(.D)))),
//    0x7B: .Instruction(Instruction(0x7B, "LD A,E", .LoadByte(into: .Register(.A), from: .Register(.E)))),
//    0x7C: .Instruction(Instruction(0x7C, "LD A,H", .LoadByte(into: .Register(.A), from: .Register(.H)))),
//    0x7D: .Instruction(Instruction(0x7D, "LD A,L", .LoadByte(into: .Register(.A), from: .Register(.L)))),
//    0x7E: .Instruction(Instruction(0x7E, "LD A,(HL)", .LoadByte(into: .Register(.A), from: .RegisterIndirect(.HL)))),
//    0x7F: .Instruction(Instruction(0x7F, "LD A,A", .LoadByte(into: .Register(.A), from: .Register(.A)))),
//
    // - MARK: 0x80
//    0x80: .Instruction(Instruction(0x80, "ADD A,B", .Add(.Byte(.Register(.A)), .Byte(.Register(.B))))),
//    0x81: .Instruction(Instruction(0x81, "ADD A,C", .Add(.Byte(.Register(.A)), .Byte(.Register(.C))))),
//    0x82: .Instruction(Instruction(0x82, "ADD A,D", .Add(.Byte(.Register(.A)), .Byte(.Register(.D))))),
//    0x83: .Instruction(Instruction(0x83, "ADD A,E", .Add(.Byte(.Register(.A)), .Byte(.Register(.E))))),
//    0x84: .Instruction(Instruction(0x84, "ADD A,H", .Add(.Byte(.Register(.A)), .Byte(.Register(.H))))),
//    0x85: .Instruction(Instruction(0x85, "ADD A,L", .Add(.Byte(.Register(.A)), .Byte(.Register(.L))))),
//    0x86: .Instruction(Instruction(0x86, "ADD A,(HL)", .Add(.Byte(.Register(.A)), .Byte(.RegisterIndirect(.HL))))),
//    0x87: .Instruction(Instruction(0x87, "ADD A,A", .Add(.Byte(.Register(.A)), .Byte(.Register(.A))))),
//    0x88: .Instruction(Instruction(0x88, "ADC A,B", .Add(.Byte(.Register(.A)), .Byte(.Register(.B)), .WithCarry))),
//    0x89: .Instruction(Instruction(0x89, "ADC A,C", .Add(.Byte(.Register(.A)), .Byte(.Register(.C)), .WithCarry))),
//    0x8A: .Instruction(Instruction(0x8A, "ADC A,D", .Add(.Byte(.Register(.A)), .Byte(.Register(.D)), .WithCarry))),
//    0x8B: .Instruction(Instruction(0x8B, "ADC A,E", .Add(.Byte(.Register(.A)), .Byte(.Register(.E)), .WithCarry))),
//    0x8C: .Instruction(Instruction(0x8C, "ADC A,H", .Add(.Byte(.Register(.A)), .Byte(.Register(.H)), .WithCarry))),
//    0x8D: .Instruction(Instruction(0x8D, "ADC A,L", .Add(.Byte(.Register(.A)), .Byte(.Register(.L)), .WithCarry))),
//    0x8E: .Instruction(Instruction(0x8E, "ADC A,(HL)", .Add(.Byte(.Register(.A)), .Byte(.RegisterIndirect(.HL)), .WithCarry))),
//    0x8F: .Instruction(Instruction(0x8F, "ADC A,A", .Add(.Byte(.Register(.A)), .Byte(.Register(.A)), .WithCarry))),
//
    // - MARK: 0x90
//    0x90: .Instruction(Instruction(0x90, "SUB A,B", .Subtract(.Register(.B)))),
//    0x91: .Instruction(Instruction(0x91, "SUB A,C", .Subtract(.Register(.C)))),
//    0x92: .Instruction(Instruction(0x92, "SUB A,D", .Subtract(.Register(.D)))),
//    0x93: .Instruction(Instruction(0x93, "SUB A,E", .Subtract(.Register(.E)))),
//    0x94: .Instruction(Instruction(0x94, "SUB A,H", .Subtract(.Register(.H)))),
//    0x95: .Instruction(Instruction(0x95, "SUB A,L", .Subtract(.Register(.L)))),
//    0x96: .Instruction(Instruction(0x96, "SUB A,(HL)", .Subtract(.RegisterIndirect(.HL)))),
//    0x97: .Instruction(Instruction(0x97, "SUB A,A", .Subtract(.Register(.A)))),
//    0x98: .Instruction(Instruction(0x98, "SBC A,B", .Subtract(.Register(.B), .WithCarry))),
//    0x99: .Instruction(Instruction(0x99, "SBC A,C", .Subtract(.Register(.C), .WithCarry))),
//    0x9A: .Instruction(Instruction(0x9A, "SBC A,D", .Subtract(.Register(.D), .WithCarry))),
//    0x9B: .Instruction(Instruction(0x9B, "SBC A,E", .Subtract(.Register(.E), .WithCarry))),
//    0x9C: .Instruction(Instruction(0x9C, "SBC A,H", .Subtract(.Register(.H), .WithCarry))),
//    0x9D: .Instruction(Instruction(0x9D, "SBC A,L", .Subtract(.Register(.L), .WithCarry))),
//    0x9E: .Instruction(Instruction(0x9E, "SBC A,(HL)", .Subtract(.RegisterIndirect(.HL), .WithCarry))),
//    0x9F: .Instruction(Instruction(0x9F, "SBC A,A", .Subtract(.Register(.A), .WithCarry))),
//
    // - MARK: 0xA0
//    0xA0: .Instruction(Instruction(0xA0, "AND B", .And(.Register(.B)))),
//    0xA1: .Instruction(Instruction(0xA1, "AND C", .And(.Register(.C)))),
//    0xA2: .Instruction(Instruction(0xA2, "AND D", .And(.Register(.D)))),
//    0xA3: .Instruction(Instruction(0xA3, "AND E", .And(.Register(.E)))),
//    0xA4: .Instruction(Instruction(0xA4, "AND H", .And(.Register(.H)))),
//    0xA5: .Instruction(Instruction(0xA5, "AND L", .And(.Register(.L)))),
//    0xA6: .Instruction(Instruction(0xA6, "AND (HL)", .And(.RegisterIndirect(.HL)))),
//    0xA7: .Instruction(Instruction(0xA7, "AND A", .And(.Register(.A)))),
//    0xA8: .Instruction(Instruction(0xA8, "XOR B", .ExclusiveOr(.Register(.B)))),
//    0xA9: .Instruction(Instruction(0xA9, "XOR C", .ExclusiveOr(.Register(.C)))),
//    0xAA: .Instruction(Instruction(0xAA, "XOR D", .ExclusiveOr(.Register(.D)))),
//    0xAB: .Instruction(Instruction(0xAB, "XOR E", .ExclusiveOr(.Register(.E)))),
//    0xAC: .Instruction(Instruction(0xAC, "XOR H", .ExclusiveOr(.Register(.H)))),
//    0xAD: .Instruction(Instruction(0xAD, "XOR L", .ExclusiveOr(.Register(.L)))),
//    0xAE: .Instruction(Instruction(0xAE, "XOR (HL)", .ExclusiveOr(.RegisterIndirect(.HL)))),
//    0xAF: .Instruction(Instruction(0xAF, "XOR A", .ExclusiveOr(.Register(.A)))),
//
    // - MARK: 0xB0
//    0xB0: .Instruction(Instruction(0xB0, "OR B", .Or(.Register(.B)))),
//    0xB1: .Instruction(Instruction(0xB1, "OR C", .Or(.Register(.C)))),
//    0xB2: .Instruction(Instruction(0xB2, "OR D", .Or(.Register(.D)))),
//    0xB3: .Instruction(Instruction(0xB3, "OR E", .Or(.Register(.E)))),
//    0xB4: .Instruction(Instruction(0xB4, "OR H", .Or(.Register(.H)))),
//    0xB5: .Instruction(Instruction(0xB5, "OR L", .Or(.Register(.L)))),
//    0xB6: .Instruction(Instruction(0xB6, "OR (HL)", .Or(.RegisterIndirect(.HL)))),
//    0xB7: .Instruction(Instruction(0xB7, "OR A", .Or(.Register(.A)))),
//    0xB8: .Instruction(Instruction(0xB8, "CP B", .Compare(.Register(.B)))),
//    0xB9: .Instruction(Instruction(0xB9, "CP C", .Compare(.Register(.C)))),
//    0xBA: .Instruction(Instruction(0xBA, "CP D", .Compare(.Register(.D)))),
//    0xBB: .Instruction(Instruction(0xBB, "CP E", .Compare(.Register(.E)))),
//    0xBC: .Instruction(Instruction(0xBC, "CP H", .Compare(.Register(.H)))),
//    0xBD: .Instruction(Instruction(0xBD, "CP L", .Compare(.Register(.L)))),
//    0xBE: .Instruction(Instruction(0xBE, "CP (HL)", .Compare(.RegisterIndirect(.HL)))),
//    0xBF: .Instruction(Instruction(0xBF, "CP A", .Compare(.Register(.A)))),
//
    // - MARK: 0xC0
//    0xC0: .Instruction(Instruction(0xC0, "RET NZ", .Return(.IfNonZero))),
//    0xC1: .Instruction(Instruction(0xC1, "POP BC", .Pop(.BC))),
//    0xC2: .Instruction(Instruction(0xC2, "JP NZ,%04X", .Jump(.Word(.ExtendedImmediate), .IfNonZero))),
//    0xC3: .Instruction(Instruction(0xC3, "JP %04X", .Jump(.Word(.ExtendedImmediate)))),
//    0xC4: .Instruction(Instruction(0xC4, "CALL NZ,%04X", .Call(.IfNonZero))),
//    0xC5: .Instruction(Instruction(0xC5, "PUSH BC", .Push(.BC))),
//    0xC6: .Instruction(Instruction(0xC6, "ADD A,%02X", .Add(.Byte(.Register(.A)), .Byte(.Immediate)))),
//    0xC7: .Instruction(Instruction(0xC7, "RST 0", .Restart(._00))),
//    0xC8: .Instruction(Instruction(0xC8, "RET Z", .Return(.IfZero))),
//    0xC9: .Instruction(Instruction(0xC9, "RET", .Return())),
//    0xCA: .Instruction(Instruction(0xCA, "JP Z,%04X", .Jump(.Word(.ExtendedImmediate), .IfZero))),
//    0xCB: .Set(Instruction.Set(instructions: [
    // - MARK: 0xCB00
//        0x00: .Instruction(Instruction(0x00, "RLC B", .Rotate(.Left, .Register(.B), .WithCarry))),
//        0x01: .Instruction(Instruction(0x01, "RLC C", .Rotate(.Left, .Register(.C), .WithCarry))),
//        0x02: .Instruction(Instruction(0x02, "RLC D", .Rotate(.Left, .Register(.D), .WithCarry))),
//        0x03: .Instruction(Instruction(0x03, "RLC E", .Rotate(.Left, .Register(.E), .WithCarry))),
//        0x04: .Instruction(Instruction(0x04, "RLC H", .Rotate(.Left, .Register(.H), .WithCarry))),
//        0x05: .Instruction(Instruction(0x05, "RLC L", .Rotate(.Left, .Register(.L), .WithCarry))),
//        0x06: .Instruction(Instruction(0x06, "RLC (HL)", .Rotate(.Left, .RegisterIndirect(.HL), .WithCarry))),
//        0x07: .Instruction(Instruction(0x07, "RLC A", .Rotate(.Left, .Register(.A), .WithCarry))),
//        0x08: .Instruction(Instruction(0x08, "RRC B", .Rotate(.Right, .Register(.B), .WithCarry))),
//        0x09: .Instruction(Instruction(0x09, "RRC C", .Rotate(.Right, .Register(.C), .WithCarry))),
//        0x0A: .Instruction(Instruction(0x0A, "RRC D", .Rotate(.Right, .Register(.D), .WithCarry))),
//        0x0B: .Instruction(Instruction(0x0B, "RRC E", .Rotate(.Right, .Register(.E), .WithCarry))),
//        0x0C: .Instruction(Instruction(0x0C, "RRC H", .Rotate(.Right, .Register(.H), .WithCarry))),
//        0x0D: .Instruction(Instruction(0x0D, "RRC L", .Rotate(.Right, .Register(.L), .WithCarry))),
//        0x0E: .Instruction(Instruction(0x0E, "RRC (HL)", .Rotate(.Right, .RegisterIndirect(.HL), .WithCarry))),
//        0x0F: .Instruction(Instruction(0x0F, "RRC A", .Rotate(.Right, .Register(.A), .WithCarry))),
//
    // - MARK: 0xCB10
//        0x10: .Instruction(Instruction(0x10, "RL B", .Rotate(.Left, .Register(.B)))),
//        0x11: .Instruction(Instruction(0x11, "RL C", .Rotate(.Left, .Register(.C)))),
//        0x12: .Instruction(Instruction(0x12, "RL D", .Rotate(.Left, .Register(.D)))),
//        0x13: .Instruction(Instruction(0x13, "RL E", .Rotate(.Left, .Register(.E)))),
//        0x14: .Instruction(Instruction(0x14, "RL H", .Rotate(.Left, .Register(.H)))),
//        0x15: .Instruction(Instruction(0x15, "RL L", .Rotate(.Left, .Register(.L)))),
//        0x16: .Instruction(Instruction(0x16, "RL (HL)", .Rotate(.Left, .RegisterIndirect(.HL)))),
//        0x17: .Instruction(Instruction(0x17, "RL A", .Rotate(.Left, .Register(.A)))),
//        0x18: .Instruction(Instruction(0x18, "RR B", .Rotate(.Right, .Register(.B)))),
//        0x19: .Instruction(Instruction(0x19, "RR C", .Rotate(.Right, .Register(.C)))),
//        0x1A: .Instruction(Instruction(0x1A, "RR D", .Rotate(.Right, .Register(.D)))),
//        0x1B: .Instruction(Instruction(0x1B, "RR E", .Rotate(.Right, .Register(.E)))),
//        0x1C: .Instruction(Instruction(0x1C, "RR H", .Rotate(.Right, .Register(.H)))),
//        0x1D: .Instruction(Instruction(0x1D, "RR L", .Rotate(.Right, .Register(.L)))),
//        0x1E: .Instruction(Instruction(0x1E, "RR (HL)", .Rotate(.Right, .RegisterIndirect(.HL)))),
//        0x1F: .Instruction(Instruction(0x1F, "RR A", .Rotate(.Right, .Register(.A)))),
//
    // - MARK: 0xCB20
//        0x20: .Instruction(Instruction(0x20, "SLA B", .Shift(.LeftArithmetic, .Register(.B)))),
//        0x21: .Instruction(Instruction(0x21, "SLA C", .Shift(.LeftArithmetic, .Register(.C)))),
//        0x22: .Instruction(Instruction(0x22, "SLA D", .Shift(.LeftArithmetic, .Register(.D)))),
//        0x23: .Instruction(Instruction(0x23, "SLA E", .Shift(.LeftArithmetic, .Register(.E)))),
//        0x24: .Instruction(Instruction(0x24, "SLA H", .Shift(.LeftArithmetic, .Register(.H)))),
//        0x25: .Instruction(Instruction(0x25, "SLA L", .Shift(.LeftArithmetic, .Register(.L)))),
//        0x26: .Instruction(Instruction(0x26, "SLA (HL)", .Shift(.LeftArithmetic, .RegisterIndirect(.HL)))),
//        0x27: .Instruction(Instruction(0x27, "SLA A", .Shift(.LeftArithmetic, .Register(.A)))),
//        0x28: .Instruction(Instruction(0x28, "SRA B", .Shift(.RightArithmetic, .Register(.B)))),
//        0x29: .Instruction(Instruction(0x29, "SRA C", .Shift(.RightArithmetic, .Register(.C)))),
//        0x2A: .Instruction(Instruction(0x2A, "SRA D", .Shift(.RightArithmetic, .Register(.D)))),
//        0x2B: .Instruction(Instruction(0x2B, "SRA E", .Shift(.RightArithmetic, .Register(.E)))),
//        0x2C: .Instruction(Instruction(0x2C, "SRA H", .Shift(.RightArithmetic, .Register(.H)))),
//        0x2D: .Instruction(Instruction(0x2D, "SRA L", .Shift(.RightArithmetic, .Register(.L)))),
//        0x2E: .Instruction(Instruction(0x2E, "SRA (HL)", .Shift(.RightArithmetic, .RegisterIndirect(.HL)))),
//        0x2F: .Instruction(Instruction(0x2F, "SRA A", .Shift(.RightArithmetic, .Register(.A)))),
//
    // - MARK: 0xCB30
//        0x30: .Instruction(Instruction(0x30, "SWAP B", .Swap(.Register(.B)))),
//        0x31: .Instruction(Instruction(0x31, "SWAP C", .Swap(.Register(.C)))),
//        0x32: .Instruction(Instruction(0x32, "SWAP D", .Swap(.Register(.D)))),
//        0x33: .Instruction(Instruction(0x33, "SWAP E", .Swap(.Register(.E)))),
//        0x34: .Instruction(Instruction(0x34, "SWAP H", .Swap(.Register(.H)))),
//        0x35: .Instruction(Instruction(0x35, "SWAP L", .Swap(.Register(.L)))),
//        0x36: .Instruction(Instruction(0x36, "SWAP (HL)", .Swap(.RegisterIndirect(.HL)))),
//        0x37: .Instruction(Instruction(0x37, "SWAP A", .Swap(.Register(.A)))),
//        0x38: .Instruction(Instruction(0x38, "SRL B", .Shift(.RightLogical, .Register(.B)))),
//        0x39: .Instruction(Instruction(0x39, "SRL C", .Shift(.RightLogical, .Register(.C)))),
//        0x3A: .Instruction(Instruction(0x3A, "SRL D", .Shift(.RightLogical, .Register(.D)))),
//        0x3B: .Instruction(Instruction(0x3B, "SRL E", .Shift(.RightLogical, .Register(.E)))),
//        0x3C: .Instruction(Instruction(0x3C, "SRL H", .Shift(.RightLogical, .Register(.H)))),
//        0x3D: .Instruction(Instruction(0x3D, "SRL L", .Shift(.RightLogical, .Register(.L)))),
//        0x3E: .Instruction(Instruction(0x3E, "SRL (HL)", .Shift(.RightLogical, .RegisterIndirect(.HL)))),
//        0x3F: .Instruction(Instruction(0x3F, "SRL A", .Shift(.RightLogical, .Register(.A)))),
//
    // - MARK: 0xCB40
//        0x40: .Instruction(Instruction(0x40, "BIT 0,B", .CompareBit(._0, .Register(.B)))),
//        0x41: .Instruction(Instruction(0x41, "BIT 0,C", .CompareBit(._0, .Register(.C)))),
//        0x42: .Instruction(Instruction(0x42, "BIT 0,D", .CompareBit(._0, .Register(.D)))),
//        0x43: .Instruction(Instruction(0x43, "BIT 0,E", .CompareBit(._0, .Register(.E)))),
//        0x44: .Instruction(Instruction(0x44, "BIT 0,H", .CompareBit(._0, .Register(.H)))),
//        0x45: .Instruction(Instruction(0x45, "BIT 0,L", .CompareBit(._0, .Register(.L)))),
//        0x46: .Instruction(Instruction(0x46, "BIT 0,(HL)", .CompareBit(._0, .RegisterIndirect(.HL)))),
//        0x47: .Instruction(Instruction(0x47, "BIT 0,A", .CompareBit(._0, .Register(.A)))),
//        0x48: .Instruction(Instruction(0x48, "BIT 1,B", .CompareBit(._1, .Register(.B)))),
//        0x49: .Instruction(Instruction(0x49, "BIT 1,C", .CompareBit(._1, .Register(.C)))),
//        0x4A: .Instruction(Instruction(0x4A, "BIT 1,D", .CompareBit(._1, .Register(.D)))),
//        0x4B: .Instruction(Instruction(0x4B, "BIT 1,E", .CompareBit(._1, .Register(.E)))),
//        0x4C: .Instruction(Instruction(0x4C, "BIT 1,H", .CompareBit(._1, .Register(.H)))),
//        0x4D: .Instruction(Instruction(0x4D, "BIT 1,L", .CompareBit(._1, .Register(.L)))),
//        0x4E: .Instruction(Instruction(0x4E, "BIT 1,(HL)", .CompareBit(._1, .RegisterIndirect(.HL)))),
//        0x4F: .Instruction(Instruction(0x4F, "BIT 1,A", .CompareBit(._1, .Register(.A)))),
//
    // - MARK: 0xCB50
//        0x50: .Instruction(Instruction(0x50, "BIT 2,B", .CompareBit(._2, .Register(.B)))),
//        0x51: .Instruction(Instruction(0x51, "BIT 2,C", .CompareBit(._2, .Register(.C)))),
//        0x52: .Instruction(Instruction(0x52, "BIT 2,D", .CompareBit(._2, .Register(.D)))),
//        0x53: .Instruction(Instruction(0x53, "BIT 2,E", .CompareBit(._2, .Register(.E)))),
//        0x54: .Instruction(Instruction(0x54, "BIT 2,H", .CompareBit(._2, .Register(.H)))),
//        0x55: .Instruction(Instruction(0x55, "BIT 2,L", .CompareBit(._2, .Register(.L)))),
//        0x56: .Instruction(Instruction(0x56, "BIT 2,(HL)", .CompareBit(._2, .RegisterIndirect(.HL)))),
//        0x57: .Instruction(Instruction(0x57, "BIT 2,A", .CompareBit(._2, .Register(.A)))),
//        0x58: .Instruction(Instruction(0x58, "BIT 3,B", .CompareBit(._3, .Register(.B)))),
//        0x59: .Instruction(Instruction(0x59, "BIT 3,C", .CompareBit(._3, .Register(.C)))),
//        0x5A: .Instruction(Instruction(0x5A, "BIT 3,D", .CompareBit(._3, .Register(.D)))),
//        0x5B: .Instruction(Instruction(0x5B, "BIT 3,E", .CompareBit(._3, .Register(.E)))),
//        0x5C: .Instruction(Instruction(0x5C, "BIT 3,H", .CompareBit(._3, .Register(.H)))),
//        0x5D: .Instruction(Instruction(0x5D, "BIT 3,L", .CompareBit(._3, .Register(.L)))),
//        0x5E: .Instruction(Instruction(0x5E, "BIT 3,(HL)", .CompareBit(._3, .RegisterIndirect(.HL)))),
//        0x5F: .Instruction(Instruction(0x5F, "BIT 3,A", .CompareBit(._3, .Register(.A)))),
//
    // - MARK: 0xCB60
//        0x60: .Instruction(Instruction(0x60, "BIT 4,B", .CompareBit(._4, .Register(.B)))),
//        0x61: .Instruction(Instruction(0x61, "BIT 4,C", .CompareBit(._4, .Register(.C)))),
//        0x62: .Instruction(Instruction(0x62, "BIT 4,D", .CompareBit(._4, .Register(.D)))),
//        0x63: .Instruction(Instruction(0x63, "BIT 4,E", .CompareBit(._4, .Register(.E)))),
//        0x64: .Instruction(Instruction(0x64, "BIT 4,H", .CompareBit(._4, .Register(.H)))),
//        0x65: .Instruction(Instruction(0x65, "BIT 4,L", .CompareBit(._4, .Register(.L)))),
//        0x66: .Instruction(Instruction(0x66, "BIT 4,(HL)", .CompareBit(._4, .RegisterIndirect(.HL)))),
//        0x67: .Instruction(Instruction(0x67, "BIT 4,A", .CompareBit(._4, .Register(.A)))),
//        0x68: .Instruction(Instruction(0x68, "BIT 5,B", .CompareBit(._5, .Register(.B)))),
//        0x69: .Instruction(Instruction(0x69, "BIT 5,C", .CompareBit(._5, .Register(.C)))),
//        0x6A: .Instruction(Instruction(0x6A, "BIT 5,D", .CompareBit(._5, .Register(.D)))),
//        0x6B: .Instruction(Instruction(0x6B, "BIT 5,E", .CompareBit(._5, .Register(.E)))),
//        0x6C: .Instruction(Instruction(0x6C, "BIT 5,H", .CompareBit(._5, .Register(.H)))),
//        0x6D: .Instruction(Instruction(0x6D, "BIT 5,L", .CompareBit(._5, .Register(.L)))),
//        0x6E: .Instruction(Instruction(0x6E, "BIT 5,(HL)", .CompareBit(._5, .RegisterIndirect(.HL)))),
//        0x6F: .Instruction(Instruction(0x6F, "BIT 5,A", .CompareBit(._5, .Register(.A)))),
//
    // - MARK: 0xCB70
//        0x70: .Instruction(Instruction(0x70, "BIT 6,B", .CompareBit(._6, .Register(.B)))),
//        0x71: .Instruction(Instruction(0x71, "BIT 6,C", .CompareBit(._6, .Register(.C)))),
//        0x72: .Instruction(Instruction(0x72, "BIT 6,D", .CompareBit(._6, .Register(.D)))),
//        0x73: .Instruction(Instruction(0x73, "BIT 6,E", .CompareBit(._6, .Register(.E)))),
//        0x74: .Instruction(Instruction(0x74, "BIT 6,H", .CompareBit(._6, .Register(.H)))),
//        0x75: .Instruction(Instruction(0x75, "BIT 6,L", .CompareBit(._6, .Register(.L)))),
//        0x76: .Instruction(Instruction(0x76, "BIT 6,(HL)", .CompareBit(._6, .RegisterIndirect(.HL)))),
//        0x77: .Instruction(Instruction(0x77, "BIT 6,A", .CompareBit(._6, .Register(.A)))),
//        0x78: .Instruction(Instruction(0x78, "BIT 7,B", .CompareBit(._7, .Register(.B)))),
//        0x79: .Instruction(Instruction(0x79, "BIT 7,C", .CompareBit(._7, .Register(.C)))),
//        0x7A: .Instruction(Instruction(0x7A, "BIT 7,D", .CompareBit(._7, .Register(.D)))),
//        0x7B: .Instruction(Instruction(0x7B, "BIT 7,E", .CompareBit(._7, .Register(.E)))),
//        0x7C: .Instruction(Instruction(0x7C, "BIT 7,H", .CompareBit(._7, .Register(.H)))),
//        0x7D: .Instruction(Instruction(0x7D, "BIT 7,L", .CompareBit(._7, .Register(.L)))),
//        0x7E: .Instruction(Instruction(0x7E, "BIT 7,(HL)", .CompareBit(._7, .RegisterIndirect(.HL)))),
//        0x7F: .Instruction(Instruction(0x7F, "BIT 7,A", .CompareBit(._7, .Register(.A)))),
//
    // - MARK: 0xCB80
//        0x80: .Instruction(Instruction(0x80, "RES 0,B", .ResetBit(._0, .Register(.B)))),
//        0x81: .Instruction(Instruction(0x81, "RES 0,C", .ResetBit(._0, .Register(.C)))),
//        0x82: .Instruction(Instruction(0x82, "RES 0,D", .ResetBit(._0, .Register(.D)))),
//        0x83: .Instruction(Instruction(0x83, "RES 0,E", .ResetBit(._0, .Register(.E)))),
//        0x84: .Instruction(Instruction(0x84, "RES 0,H", .ResetBit(._0, .Register(.H)))),
//        0x85: .Instruction(Instruction(0x85, "RES 0,L", .ResetBit(._0, .Register(.L)))),
//        0x86: .Instruction(Instruction(0x86, "RES 0,(HL)", .ResetBit(._0, .RegisterIndirect(.HL)))),
//        0x87: .Instruction(Instruction(0x87, "RES 0,A", .ResetBit(._0, .Register(.A)))),
//        0x88: .Instruction(Instruction(0x88, "RES 1,B", .ResetBit(._1, .Register(.B)))),
//        0x89: .Instruction(Instruction(0x89, "RES 1,C", .ResetBit(._1, .Register(.C)))),
//        0x8A: .Instruction(Instruction(0x8A, "RES 1,D", .ResetBit(._1, .Register(.D)))),
//        0x8B: .Instruction(Instruction(0x8B, "RES 1,E", .ResetBit(._1, .Register(.E)))),
//        0x8C: .Instruction(Instruction(0x8C, "RES 1,H", .ResetBit(._1, .Register(.H)))),
//        0x8D: .Instruction(Instruction(0x8D, "RES 1,L", .ResetBit(._1, .Register(.L)))),
//        0x8E: .Instruction(Instruction(0x8E, "RES 1,(HL)", .ResetBit(._1, .RegisterIndirect(.HL)))),
//        0x8F: .Instruction(Instruction(0x8F, "RES 1,A", .ResetBit(._1, .Register(.A)))),
//
    // - MARK: 0xCB90
//        0x90: .Instruction(Instruction(0x90, "RES 2,B", .ResetBit(._2, .Register(.B)))),
//        0x91: .Instruction(Instruction(0x91, "RES 2,C", .ResetBit(._2, .Register(.C)))),
//        0x92: .Instruction(Instruction(0x92, "RES 2,D", .ResetBit(._2, .Register(.D)))),
//        0x93: .Instruction(Instruction(0x93, "RES 2,E", .ResetBit(._2, .Register(.E)))),
//        0x94: .Instruction(Instruction(0x94, "RES 2,H", .ResetBit(._2, .Register(.H)))),
//        0x95: .Instruction(Instruction(0x95, "RES 2,L", .ResetBit(._2, .Register(.L)))),
//        0x96: .Instruction(Instruction(0x96, "RES 2,(HL)", .ResetBit(._2, .RegisterIndirect(.HL)))),
//        0x97: .Instruction(Instruction(0x97, "RES 2,A", .ResetBit(._2, .Register(.A)))),
//        0x98: .Instruction(Instruction(0x98, "RES 3,B", .ResetBit(._3, .Register(.B)))),
//        0x99: .Instruction(Instruction(0x99, "RES 3,C", .ResetBit(._3, .Register(.C)))),
//        0x9A: .Instruction(Instruction(0x9A, "RES 3,D", .ResetBit(._3, .Register(.D)))),
//        0x9B: .Instruction(Instruction(0x9B, "RES 3,E", .ResetBit(._3, .Register(.E)))),
//        0x9C: .Instruction(Instruction(0x9C, "RES 3,H", .ResetBit(._3, .Register(.H)))),
//        0x9D: .Instruction(Instruction(0x9D, "RES 3,L", .ResetBit(._3, .Register(.L)))),
//        0x9E: .Instruction(Instruction(0x9E, "RES 3,(HL)", .ResetBit(._3, .RegisterIndirect(.HL)))),
//        0x9F: .Instruction(Instruction(0x9F, "RES 3,A", .ResetBit(._3, .Register(.A)))),
//
    // - MARK: 0xCBA0
//        0xA0: .Instruction(Instruction(0xA0, "RES 4,B", .ResetBit(._4, .Register(.B)))),
//        0xA1: .Instruction(Instruction(0xA1, "RES 4,C", .ResetBit(._4, .Register(.C)))),
//        0xA2: .Instruction(Instruction(0xA2, "RES 4,D", .ResetBit(._4, .Register(.D)))),
//        0xA3: .Instruction(Instruction(0xA3, "RES 4,E", .ResetBit(._4, .Register(.E)))),
//        0xA4: .Instruction(Instruction(0xA4, "RES 4,H", .ResetBit(._4, .Register(.H)))),
//        0xA5: .Instruction(Instruction(0xA5, "RES 4,L", .ResetBit(._4, .Register(.L)))),
//        0xA6: .Instruction(Instruction(0xA6, "RES 4,(HL)", .ResetBit(._4, .RegisterIndirect(.HL)))),
//        0xA7: .Instruction(Instruction(0xA7, "RES 4,A", .ResetBit(._4, .Register(.A)))),
//        0xA8: .Instruction(Instruction(0xA8, "RES 5,B", .ResetBit(._5, .Register(.B)))),
//        0xA9: .Instruction(Instruction(0xA9, "RES 5,C", .ResetBit(._5, .Register(.C)))),
//        0xAA: .Instruction(Instruction(0xAA, "RES 5,D", .ResetBit(._5, .Register(.D)))),
//        0xAB: .Instruction(Instruction(0xAB, "RES 5,E", .ResetBit(._5, .Register(.E)))),
//        0xAC: .Instruction(Instruction(0xAC, "RES 5,H", .ResetBit(._5, .Register(.H)))),
//        0xAD: .Instruction(Instruction(0xAD, "RES 5,L", .ResetBit(._5, .Register(.L)))),
//        0xAE: .Instruction(Instruction(0xAE, "RES 5,(HL)", .ResetBit(._5, .RegisterIndirect(.HL)))),
//        0xAF: .Instruction(Instruction(0xAF, "RES 5,A", .ResetBit(._5, .Register(.A)))),
//
    // - MARK: 0xCBB0
//        0xB0: .Instruction(Instruction(0xB0, "RES 6,B", .ResetBit(._6, .Register(.B)))),
//        0xB1: .Instruction(Instruction(0xB1, "RES 6,C", .ResetBit(._6, .Register(.C)))),
//        0xB2: .Instruction(Instruction(0xB2, "RES 6,D", .ResetBit(._6, .Register(.D)))),
//        0xB3: .Instruction(Instruction(0xB3, "RES 6,E", .ResetBit(._6, .Register(.E)))),
//        0xB4: .Instruction(Instruction(0xB4, "RES 6,H", .ResetBit(._6, .Register(.H)))),
//        0xB5: .Instruction(Instruction(0xB5, "RES 6,L", .ResetBit(._6, .Register(.L)))),
//        0xB6: .Instruction(Instruction(0xB6, "RES 6,(HL)", .ResetBit(._6, .RegisterIndirect(.HL)))),
//        0xB7: .Instruction(Instruction(0xB7, "RES 6,A", .ResetBit(._6, .Register(.A)))),
//        0xB8: .Instruction(Instruction(0xB8, "RES 7,B", .ResetBit(._7, .Register(.B)))),
//        0xB9: .Instruction(Instruction(0xB9, "RES 7,C", .ResetBit(._7, .Register(.C)))),
//        0xBA: .Instruction(Instruction(0xBA, "RES 7,D", .ResetBit(._7, .Register(.D)))),
//        0xBB: .Instruction(Instruction(0xBB, "RES 7,E", .ResetBit(._7, .Register(.E)))),
//        0xBC: .Instruction(Instruction(0xBC, "RES 7,H", .ResetBit(._7, .Register(.H)))),
//        0xBD: .Instruction(Instruction(0xBD, "RES 7,L", .ResetBit(._7, .Register(.L)))),
//        0xBE: .Instruction(Instruction(0xBE, "RES 7,(HL)", .ResetBit(._7, .RegisterIndirect(.HL)))),
//        0xBF: .Instruction(Instruction(0xBF, "RES 7,A", .ResetBit(._7, .Register(.A)))),
//
    // - MARK: 0xCBC0
//        0xC0: .Instruction(Instruction(0xC0, "SET 0,B", .SetBit(._0, .Register(.B)))),
//        0xC1: .Instruction(Instruction(0xC1, "SET 0,C", .SetBit(._0, .Register(.C)))),
//        0xC2: .Instruction(Instruction(0xC2, "SET 0,D", .SetBit(._0, .Register(.D)))),
//        0xC3: .Instruction(Instruction(0xC3, "SET 0,E", .SetBit(._0, .Register(.E)))),
//        0xC4: .Instruction(Instruction(0xC4, "SET 0,H", .SetBit(._0, .Register(.H)))),
//        0xC5: .Instruction(Instruction(0xC5, "SET 0,L", .SetBit(._0, .Register(.L)))),
//        0xC6: .Instruction(Instruction(0xC6, "SET 0,(HL)", .SetBit(._0, .RegisterIndirect(.HL)))),
//        0xC7: .Instruction(Instruction(0xC7, "SET 0,A", .SetBit(._0, .Register(.A)))),
//        0xC8: .Instruction(Instruction(0xC8, "SET 1,B", .SetBit(._1, .Register(.B)))),
//        0xC9: .Instruction(Instruction(0xC9, "SET 1,C", .SetBit(._1, .Register(.C)))),
//        0xCA: .Instruction(Instruction(0xCA, "SET 1,D", .SetBit(._1, .Register(.D)))),
//        0xCB: .Instruction(Instruction(0xCB, "SET 1,E", .SetBit(._1, .Register(.E)))),
//        0xCC: .Instruction(Instruction(0xCC, "SET 1,H", .SetBit(._1, .Register(.H)))),
//        0xCD: .Instruction(Instruction(0xCD, "SET 1,L", .SetBit(._1, .Register(.L)))),
//        0xCE: .Instruction(Instruction(0xCE, "SET 1,(HL)", .SetBit(._1, .RegisterIndirect(.HL)))),
//        0xCF: .Instruction(Instruction(0xCF, "SET 1,A", .SetBit(._1, .Register(.A)))),
//
    // - MARK: 0xCBD0
//        0xD0: .Instruction(Instruction(0xD0, "SET 2,B", .SetBit(._2, .Register(.B)))),
//        0xD1: .Instruction(Instruction(0xD1, "SET 2,C", .SetBit(._2, .Register(.C)))),
//        0xD2: .Instruction(Instruction(0xD2, "SET 2,D", .SetBit(._2, .Register(.D)))),
//        0xD3: .Instruction(Instruction(0xD3, "SET 2,E", .SetBit(._2, .Register(.E)))),
//        0xD4: .Instruction(Instruction(0xD4, "SET 2,H", .SetBit(._2, .Register(.H)))),
//        0xD5: .Instruction(Instruction(0xD5, "SET 2,L", .SetBit(._2, .Register(.L)))),
//        0xD6: .Instruction(Instruction(0xD6, "SET 2,(HL)", .SetBit(._2, .RegisterIndirect(.HL)))),
//        0xD7: .Instruction(Instruction(0xD7, "SET 2,A", .SetBit(._2, .Register(.A)))),
//        0xD8: .Instruction(Instruction(0xD8, "SET 3,B", .SetBit(._3, .Register(.B)))),
//        0xD9: .Instruction(Instruction(0xD9, "SET 3,C", .SetBit(._3, .Register(.C)))),
//        0xDA: .Instruction(Instruction(0xDA, "SET 3,D", .SetBit(._3, .Register(.D)))),
//        0xDB: .Instruction(Instruction(0xDB, "SET 3,E", .SetBit(._3, .Register(.E)))),
//        0xDC: .Instruction(Instruction(0xDC, "SET 3,H", .SetBit(._3, .Register(.H)))),
//        0xDD: .Instruction(Instruction(0xDD, "SET 3,L", .SetBit(._3, .Register(.L)))),
//        0xDE: .Instruction(Instruction(0xDE, "SET 3,(HL)", .SetBit(._3, .RegisterIndirect(.HL)))),
//        0xDF: .Instruction(Instruction(0xDF, "SET 3,A", .SetBit(._3, .Register(.A)))),
//
    // - MARK: 0xCBE0
//        0xE0: .Instruction(Instruction(0xE0, "SET 4,B", .SetBit(._4, .Register(.B)))),
//        0xE1: .Instruction(Instruction(0xE1, "SET 4,C", .SetBit(._4, .Register(.C)))),
//        0xE2: .Instruction(Instruction(0xE2, "SET 4,D", .SetBit(._4, .Register(.D)))),
//        0xE3: .Instruction(Instruction(0xE3, "SET 4,E", .SetBit(._4, .Register(.E)))),
//        0xE4: .Instruction(Instruction(0xE4, "SET 4,H", .SetBit(._4, .Register(.H)))),
//        0xE5: .Instruction(Instruction(0xE5, "SET 4,L", .SetBit(._4, .Register(.L)))),
//        0xE6: .Instruction(Instruction(0xE6, "SET 4,(HL)", .SetBit(._4, .RegisterIndirect(.HL)))),
//        0xE7: .Instruction(Instruction(0xE7, "SET 4,A", .SetBit(._4, .Register(.A)))),
//        0xE8: .Instruction(Instruction(0xE8, "SET 5,B", .SetBit(._5, .Register(.B)))),
//        0xE9: .Instruction(Instruction(0xE9, "SET 5,C", .SetBit(._5, .Register(.C)))),
//        0xEA: .Instruction(Instruction(0xEA, "SET 5,D", .SetBit(._5, .Register(.D)))),
//        0xEB: .Instruction(Instruction(0xEB, "SET 5,E", .SetBit(._5, .Register(.E)))),
//        0xEC: .Instruction(Instruction(0xEC, "SET 5,H", .SetBit(._5, .Register(.H)))),
//        0xED: .Instruction(Instruction(0xED, "SET 5,L", .SetBit(._5, .Register(.L)))),
//        0xEE: .Instruction(Instruction(0xEE, "SET 5,(HL)", .SetBit(._5, .RegisterIndirect(.HL)))),
//        0xEF: .Instruction(Instruction(0xEF, "SET 5,A", .SetBit(._5, .Register(.A)))),
//
    // - MARK: 0xCBF0
//        0xF0: .Instruction(Instruction(0xF0, "SET 6,B", .SetBit(._6, .Register(.B)))),
//        0xF1: .Instruction(Instruction(0xF1, "SET 6,C", .SetBit(._6, .Register(.C)))),
//        0xF2: .Instruction(Instruction(0xF2, "SET 6,D", .SetBit(._6, .Register(.D)))),
//        0xF3: .Instruction(Instruction(0xF3, "SET 6,E", .SetBit(._6, .Register(.E)))),
//        0xF4: .Instruction(Instruction(0xF4, "SET 6,H", .SetBit(._6, .Register(.H)))),
//        0xF5: .Instruction(Instruction(0xF5, "SET 6,L", .SetBit(._6, .Register(.L)))),
//        0xF6: .Instruction(Instruction(0xF6, "SET 6,(HL)", .SetBit(._6, .RegisterIndirect(.HL)))),
//        0xF7: .Instruction(Instruction(0xF7, "SET 6,A", .SetBit(._6, .Register(.A)))),
//        0xF8: .Instruction(Instruction(0xF8, "SET 7,B", .SetBit(._7, .Register(.B)))),
//        0xF9: .Instruction(Instruction(0xF9, "SET 7,C", .SetBit(._7, .Register(.C)))),
//        0xFA: .Instruction(Instruction(0xFA, "SET 7,D", .SetBit(._7, .Register(.D)))),
//        0xFB: .Instruction(Instruction(0xFB, "SET 7,E", .SetBit(._7, .Register(.E)))),
//        0xFC: .Instruction(Instruction(0xFC, "SET 7,H", .SetBit(._7, .Register(.H)))),
//        0xFD: .Instruction(Instruction(0xFD, "SET 7,L", .SetBit(._7, .Register(.L)))),
//        0xFE: .Instruction(Instruction(0xFE, "SET 7,(HL)", .SetBit(._7, .RegisterIndirect(.HL)))),
//        0xFF: .Instruction(Instruction(0xFF, "SET 7,A", .SetBit(._7, .Register(.A)))),
//    ])),
//    0xCC: .Instruction(Instruction(0xCC, "CALL Z,%04X", .Call(.IfZero))),
//    0xCD: .Instruction(Instruction(0xCD, "CALL %04X", .Call())),
//    0xCE: .Instruction(Instruction(0xCE, "ADC A,%02X", .Add(.Byte(.Register(.A)), .Byte(.Immediate), .WithCarry))),
//    0xCF: .Instruction(Instruction(0xCF, "RST 8", .Restart(._08))),
//
    // - MARK: 0xD0
//    0xD0: .Instruction(Instruction(0xD0, "RET NC", .Return(.IfNotCarry))),
//    0xD1: .Instruction(Instruction(0xD1, "POP DE", .Pop(.DE))),
//    0xD2: .Instruction(Instruction(0xD2, "JP NC,%04X", .Jump(.Word(.ExtendedImmediate), .IfNotCarry))),
//    0xD3: .Instruction(Instruction(0xD3, "XX", .Invalid)),
//    0xD4: .Instruction(Instruction(0xD4, "CALL NC,%04X", .Call(.IfNotCarry))),
//    0xD5: .Instruction(Instruction(0xD5, "PUSH DE", .Push(.DE))),
//    0xD6: .Instruction(Instruction(0xD6, "SUB A,%02X", .Subtract(.Immediate))),
//    0xD7: .Instruction(Instruction(0xD7, "RST 10", .Restart(._10))),
//    0xD8: .Instruction(Instruction(0xD8, "RET C", .Return(.IfCarry))),
//    0xD9: .Instruction(Instruction(0xD9, "RETI", .ReturnFromInterrupt)),
//    0xDA: .Instruction(Instruction(0xDA, "JP C,%04X", .Jump(.Word(.ExtendedImmediate), .IfCarry))),
//    0xDB: .Instruction(Instruction(0xDB, "XX", .Invalid)),
//    0xDC: .Instruction(Instruction(0xDC, "CALL C,%04X", .Call(.IfCarry))),
//    0xDD: .Instruction(Instruction(0xDD, "XX", .Invalid)),
//    0xDE: .Instruction(Instruction(0xDE, "SBC A,%02X", .Subtract(.Immediate, .WithCarry))),
//    0xDF: .Instruction(Instruction(0xDF, "RST 18", .Restart(._18))),
//
    // - MARK: 0xE0
//    0xE0: .Instruction(Instruction(0xE0, "LDH (%02X),A", .LoadByte(into: .HighAddress, from: .Register(.A)))),
//    0xE1: .Instruction(Instruction(0xE1, "POP HL", .Pop(.HL))),
//    0xE2: .Instruction(Instruction(0xE2, "LDH (C),A", .LoadByte(into: .RegisterIndirectHigh(.C), from: .Register(.A)))),
//    0xE3: .Instruction(Instruction(0xE3, "XX", .Invalid)),
//    0xE4: .Instruction(Instruction(0xE4, "XX", .Invalid)),
//    0xE5: .Instruction(Instruction(0xE5, "PUSH HL", .Push(.HL))),
//    0xE6: .Instruction(Instruction(0xE6, "AND %02X", .And(.Immediate))),
//    0xE7: .Instruction(Instruction(0xE7, "RST 20", .Restart(._20))),
//    0xE8: .Instruction(Instruction(0xE8, "ADD SP,% +03X", .Add(.Word(.RegisterExtended(.SP)), .Relative))),
//    0xE9: .Instruction(Instruction(0xE9, "JP (HL)", .Jump(.Byte(.RegisterIndirect(.HL))))),
//    0xEA: .Instruction(Instruction(0xEA, "LD (%04X),A", .LoadByte(into: .Address, from: .Register(.A)))),
//    0xEB: .Instruction(Instruction(0xEB, "XX", .Invalid)),
//    0xEC: .Instruction(Instruction(0xEC, "XX", .Invalid)),
//    0xED: .Instruction(Instruction(0xED, "XX", .Invalid)),
//    0xEE: .Instruction(Instruction(0xEE, "XOR %02X", .ExclusiveOr(.Immediate))),
//    0xEF: .Instruction(Instruction(0xEF, "RST 28", .Restart(._28))),
//
    // - MARK: 0xF0
//    0xF0: .Instruction(Instruction(0xF0, "LDH A,(%02X)", .LoadByte(into: .Register(.A), from: .HighAddress))),
//    0xF1: .Instruction(Instruction(0xF1, "POP AF", .Pop(.AF))),
//    0xF2: .Instruction(Instruction(0xF2, "XX", .Invalid)),
//    0xF3: .Instruction(Instruction(0xF3, "DI", .Interrupts(false))),
//    0xF4: .Instruction(Instruction(0xF4, "XX", .Invalid)),
//    0xF5: .Instruction(Instruction(0xF5, "PUSH AF", .Push(.AF))),
//    0xF6: .Instruction(Instruction(0xF6, "OR %02X", .Or(.Immediate))),
//    0xF7: .Instruction(Instruction(0xF7, "RST 30", .Restart(._30))),
//    0xF8: .Instruction(Instruction(0xF8, "LD HL,SP,% +03X", .LoadWord(into: .RegisterExtended(.HL), from: .RegisterIndexed(.SP)))),
//    0xF9: .Instruction(Instruction(0xF9, "LD SP,HL", .LoadWord(into: .RegisterExtended(.SP), from: .RegisterExtended(.HL)))),
//    0xFA: .Instruction(Instruction(0xFA, "LD A,(%04X)", .LoadByte(into: .Register(.A), from: .Address))),
//    0xFB: .Instruction(Instruction(0xFB, "EI", .Interrupts(true))),
//    0xFC: .Instruction(Instruction(0xFC, "XX", .Invalid)),
//    0xFD: .Instruction(Instruction(0xFD, "XX", .Invalid)),
//    0xFE: .Instruction(Instruction(0xFE, "CP %02X", .Compare(.Immediate))),
//    0xFF: .Instruction(Instruction(0xFF, "RST 38", .Restart(._38))),



    // ####################################################################################################################################
    // ##  GENERIC INSTRUCTION HELPERS  ###################################################################################################
    // ####################################################################################################################################

    // - MARK: Generic instruction helpers

    private func testLoadRegisterPairFromImmediate(_ registerPairName: Register.Pair.Name) {
        expectedRegisters[registerPairName] = 0xa5a5
        gameboy.cpu.execute(.LoadWord(into: .RegisterExtended(name: registerPairName, value: 0x0000), from: .ExtendedImmediate(0xa5a5)))
        assertRegistersMatch()
    }

    private func testLoadRegisterFromImmediate(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0xa5
        gameboy.cpu.execute(.LoadByte(into: .Register(name: registerName, value: 0x0000), from: .Immediate(0xa5)))
        assertRegistersMatch()
    }

    func testLoadRegisterIndirectFromA(_ registerPairName: Register.Pair.Name, type: Instruction.Definition.LoadType = .Normal) {
        switch type {
        case let .AndIncrement(incrementedRegisterPairName):
            gameboy.cpu.registers[incrementedRegisterPairName] = 0x8765
            expectedRegisters[incrementedRegisterPairName] = 0x8766
        case let .AndDecrement(decrementedRegisterPairName):
            gameboy.cpu.registers[decrementedRegisterPairName] = 0x8765
            expectedRegisters[decrementedRegisterPairName] = 0x8764
        case .Normal:
            break
        }

        gameboy.cpu.execute(
            .LoadByte(
                type,
                into: .RegisterIndirect(name: registerPairName, address: 0x8765, value: 0x00),
                from: .Register(name: .A, value: 0xa5)
            )
        )
        assertRegistersMatch()
        assertMatch(gameboy[0x8765], 0xa5, 0x8765)
    }

    private func testInc(_ registerPairName: Register.Pair.Name) {
        gameboy.cpu.registers[registerPairName] = 0xa5a5
        expectedRegisters[registerPairName] = 0xa5a6
        gameboy.cpu.execute(.IncrementWord(registerPairName))
        assertRegistersMatch()
    }

    private func testIncWithoutFlags(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0xa6
        gameboy.cpu.execute(.IncrementByte(.Register(name: registerName, value: 0xa5)))
        assertRegistersMatch()
    }

    private func testIncWithHalfCarry(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x40
        expectedRegisters.set(flag: .H, value: true)
        gameboy.cpu.execute(.IncrementByte(.Register(name: registerName, value: 0x3f)))
        assertRegistersMatch()
    }

    private func testIncWithHalfCarryAndZero(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x00
        expectedRegisters.set(flag: .Z, value: true)
        expectedRegisters.set(flag: .H, value: true)
        gameboy.cpu.execute(.IncrementByte(.Register(name: registerName, value: 0xff)))
        assertRegistersMatch()
    }

    private func testDec(_ registerPairName: Register.Pair.Name) {
        gameboy.cpu.registers[registerPairName] = 0xa5a5
        expectedRegisters[registerPairName] = 0xa5a4
        gameboy.cpu.execute(.DecrementWord(registerPairName))
        assertRegistersMatch()
    }

    private func testDecWithoutFlags(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0xa4
        expectedRegisters.set(flag: .N, value: true)
        gameboy.cpu.execute(.DecrementByte(.Register(name: registerName, value: 0xa5)))
        assertRegistersMatch()
    }

    private func testDecWithHalfCarry(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x3f
        expectedRegisters.set(flag: .N, value: true)
        expectedRegisters.set(flag: .H, value: true)
        gameboy.cpu.execute(.DecrementByte(.Register(name: registerName, value: 0x40)))
        assertRegistersMatch()
    }

    private func testDecWithZero(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x00
        expectedRegisters.set(flag: .Z, value: true)
        expectedRegisters.set(flag: .N, value: true)
        gameboy.cpu.execute(.DecrementByte(.Register(name: registerName, value: 0x01)))
        assertRegistersMatch()
    }

    private func testRotateLeftWithCarryRegister(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x44
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x22), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftWithCarryRegisterWithCarry(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x54
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0xaa), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftWithCarryRegisterWithCarrySetWithCarry(_ registerName: Register.Name) {
        gameboy.cpu.registers.set(flag: .C, value: true)
        expectedRegisters[registerName] = 0x55
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0xaa), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftWithCarryRegisterWithCarrySet(_ registerName: Register.Name) {
        gameboy.cpu.registers.set(flag: .C, value: true)
        expectedRegisters[registerName] = 0x01
        expectedRegisters.set(flag: .C, value: false)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x00), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftWithCarryRegisterWithZero(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x00
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x00), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftWithCarryRegisterWithZeroWithCarry(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x00
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x80), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateRightWithCarryRegister(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x55
        gameboy.cpu.execute(.Rotate(.Right, .Register(name: registerName, value: 0xaa), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateRightWithCarryRegisterWithCarrySet(_ registerName: Register.Name) {
        gameboy.cpu.registers.set(flag: .C, value: true)
        expectedRegisters[registerName] = 0xd5
        expectedRegisters.set(flag: .C, value: false)
        gameboy.cpu.execute(.Rotate(.Right, .Register(name: registerName, value: 0xaa), .WithCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftRegister(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x44
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x22), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftRegisterWithCarry(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x55
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0xaa), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftRegisterWithCarrySetWithCarry(_ registerName: Register.Name) {
        gameboy.cpu.registers.set(flag: .C, value: true)
        expectedRegisters[registerName] = 0x55
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0xaa), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftRegisterWithCarrySet(_ registerName: Register.Name) {
        gameboy.cpu.registers.set(flag: .C, value: true)
        expectedRegisters[registerName] = 0x00
        expectedRegisters.set(flag: .C, value: false)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x00), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftRegisterWithZero(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x00
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x00), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateLeftRegisterWithZeroWithCarry(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x01
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(.Rotate(.Left, .Register(name: registerName, value: 0x80), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateRightRegister(_ registerName: Register.Name) {
        expectedRegisters[registerName] = 0x55
        gameboy.cpu.execute(.Rotate(.Right, .Register(name: registerName, value: 0xaa), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testRotateRightRegisterWithCarrySet(_ registerName: Register.Name) {
        gameboy.cpu.registers.set(flag: .C, value: true)
        expectedRegisters[registerName] = 0x55
        expectedRegisters.set(flag: .C, value: false)
        gameboy.cpu.execute(.Rotate(.Right, .Register(name: registerName, value: 0xaa), .WithoutCarry, .Clear))
        assertRegistersMatch()
    }

    private func testAddHL(_ registerPairName: Register.Pair.Name) {
        expectedRegisters.HL = 0x6600
        gameboy.cpu.execute(
            .Add(.Word(.RegisterExtended(name: .HL, value: 0x3300)), .Word(.RegisterExtended(name: registerPairName, value: 0x3300)))
        )
        assertRegistersMatch()
    }

    private func testAddHLWithHalfCarry(_ registerPairName: Register.Pair.Name) {
        expectedRegisters.HL = 0x7200
        expectedRegisters.set(flag: .H, value: true)
        gameboy.cpu.execute(
            .Add(.Word(.RegisterExtended(name: .HL, value: 0x3900)), .Word(.RegisterExtended(name: registerPairName, value: 0x3900)))
        )
        assertRegistersMatch()
    }

    private func testAddHLWithCarry(_ registerPairName: Register.Pair.Name) {
        expectedRegisters.HL = 0x2600
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(
            .Add(.Word(.RegisterExtended(name: .HL, value: 0x9300)), .Word(.RegisterExtended(name: registerPairName, value: 0x9300)))
        )
        assertRegistersMatch()
    }

    private func testAddHLWithCarryAndHalfCarry(_ registerPairName: Register.Pair.Name) {
        expectedRegisters.HL = 0x3200
        expectedRegisters.set(flag: .H, value: true)
        expectedRegisters.set(flag: .C, value: true)
        gameboy.cpu.execute(
            .Add(.Word(.RegisterExtended(name: .HL, value: 0x9900)), .Word(.RegisterExtended(name: registerPairName, value: 0x9900)))
        )
        assertRegistersMatch()
    }

    private func testLoadAFromRegisterIndirect(_ registerPairName: Register.Pair.Name, type: Instruction.Definition.LoadType = .Normal) {
        switch type {
        case let .AndIncrement(incrementedRegisterPairName):
            gameboy.cpu.registers[incrementedRegisterPairName] = 0x1234
            expectedRegisters[incrementedRegisterPairName] = 0x1235
        case let .AndDecrement(decrementedRegisterPairName):
            gameboy.cpu.registers[decrementedRegisterPairName] = 0x1234
            expectedRegisters[decrementedRegisterPairName] = 0x1233
        case .Normal:
            break
        }

        expectedRegisters.A = 0xa5
        gameboy.cpu.execute(
            .LoadByte(
                type,
                into: .Register(name: .A, value: 0x00),
                from: .RegisterIndirect(name: registerPairName, address: 0x1234, value: 0xa5)
            )
        )
        assertRegistersMatch()
    }

    private func testDecimalAdjustAccumulatorAdd(_ carrying: Instruction.Definition.Carrying, carrySet: Bool = false) {
        let maybeCarry: Int, mnemonic: String

        switch (carrying, carrySet) {
        case (.WithoutCarry, _):
            maybeCarry = 0
            mnemonic = "ADD"
        case (.WithCarry, false):
            maybeCarry = 0
            mnemonic = "C=0 - ADC"
        case (.WithCarry, true):
            maybeCarry = 1
            mnemonic = "C=1 - ADC"
        }

        (0...99).forEach { a in
            (0...99).forEach { b in
                let sum = a + b + maybeCarry

                let bcdA = ((a / 10) << 4) | (a % 10)
                let bcdB = ((b / 10) << 4) | (b % 10)
                let bcdSum = ((((sum % 100) / 10) << 4) | (sum % 10)) & 0xff
                gameboy.cpu.registers.A = Byte(bcdA)
                gameboy.cpu.registers.B = Byte(bcdB)
                gameboy.cpu.registers.set(flag: .C, value: carrySet)

                expectedRegisters.A = Byte(bcdSum)
                expectedRegisters.B = Byte(bcdB)

                expectedRegisters.set(flag: .Z, value: bcdSum == 0)
                expectedRegisters.set(flag: .C, value: sum > 99)

                gameboy.cpu.execute(
                    .Add(
                        .Byte(.Register(name: .A, value: Byte(bcdA))),
                        .Byte(.Register(name: .B, value: Byte(bcdB))),
                        carrying
                    )
                )

                gameboy.cpu.execute(.DecimalAdjustAccumulator)

                assertRegistersMatch(description: "\(mnemonic)(\(a), \(b), .WithoutCarry)")
            }
        }
    }

    // ####################################################################################################################################
    // ##  ASSERTION HELPERS  #############################################################################################################
    // ####################################################################################################################################

    // - MARK: Assertion Helpers

    private func assertRegistersMatch(description: String? = nil) {
        self.assertMatch(self.gameboy.cpu.registers, self.expectedRegisters, description)
    }

    private func assertMatch(_ actual: Register.Set, _ expected: Register.Set, _ description: String? = nil) {
        guard actual != expected else { return }

        let registers: [Register.Name] = [.A, .B, .C, .D, .E, .H, .L]
        registers.forEach { name in
            let actualString = String(format: "0x%02X", actual[name])
            let expectedString = String(format: "0x%02X", expected[name])
            let errorMessage: String
            if let actualDescription = description {
                errorMessage = "\(actualDescription): Register \(name) mismatch (got \(actualString), expected: \(expectedString)"
            } else {
                errorMessage = "Register \(name) mismatch (got \(actualString), expected: \(expectedString)"
            }
            XCTAssert(actual[name] == expected[name], errorMessage)
        }

        let registerPairs: [Register.Pair.Name] = [.SP, .PC]
        registerPairs.forEach { name in
            let actualString = String(format: "0x%04X", actual[name])
            let expectedString = String(format: "0x%04X", expected[name])
            let errorMessage: String
            if let actualDescription = description {
                errorMessage = "\(actualDescription): Register \(name) mismatch (got \(actualString), expected: \(expectedString)"
            } else {
                errorMessage = "Register \(name) mismatch (got \(actualString), expected: \(expectedString)"
            }
            XCTAssert(actual[name] == expected[name], errorMessage)
        }

        let flags: [Register.Set.Flag] = [.Z, .N, .H, .C]
        flags.forEach { name in
            let actualValue = actual.get(flag: name)
            let expectedValue = expected.get(flag: name)
            let errorMessage: String
            if let actualDescription = description {
                errorMessage = "\(actualDescription): Flag \(name) mismatch (got \(actualValue), expected \(expectedValue))"
            } else {
                errorMessage = "Flag \(name) mismatch (got \(actualValue), expected \(expectedValue))"
            }
            XCTAssert(actualValue == expectedValue, errorMessage)
        }
    }

    private func assertMatch(_ actualByte: Byte, _ expectedByte: Byte, _ address: Address) {
        let addressString = String(format: "0x%04X", address)
        let actualString = String(format: "0x%02X", actualByte)
        let expectedString = String(format: "0x%02X", expectedByte)
        XCTAssert(actualByte == expectedByte, "Memory \(addressString) mismatch (got \(actualString), expected \(expectedString)))")
    }

    private func assertMatch(_ actualWord: Word, _ expectedWord: Word, _ address: Address) {
        let addressString = String(format: "0x%04X", address)
        let actualString = String(format: "0x%04X", actualWord)
        let expectedString = String(format: "0x%04X", expectedWord)
        XCTAssert(actualWord == expectedWord, "Memory \(addressString) mismatch (got \(actualString), expected \(expectedString)))")
    }
}
