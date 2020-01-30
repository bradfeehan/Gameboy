//
//  CPU.swift
//  Gameboy
//
//  Created by Brad Feehan on 8/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

class CPU {
    weak var gameboy: Gameboy!
    var decoder: Operation.Decoder!
    var registers = Register.Set()

    typealias CycleCount = UInt64
    var cycleCount: CycleCount = 0

    var timerDivider: Byte = 0          // DIV  0xFF04
    var timerCounter: Byte = 0          // TIMA 0xFF05
    var timerModulo: Byte = 0           // TMA  0xFF06
    var timerControl: TimerControl = 0  // TAC  0xFF07

    typealias TimerControl = Byte

    var interruptsEnabled: Register.Interrupt = 0    // 0xFFFF IE
    var interruptsFlags: Register.Interrupt = 0      // 0xFF0F IF
    var interruptsMaster: Bool = true                //        IME?
    var interruptsScheduled: Bool = true

    var lastOperation: Operation?

    var stopped = false

    func connect(to gameboy: Gameboy) {
        self.gameboy = gameboy
        self.decoder = Operation.Decoder(cpu: self)
        self.checkBootROM()
    }

    func checkBootROM() {
        if !gameboy.bootROMEnabled {
            self.registers.SP = 0xFFFE
            self.registers.PC = 0x0100
        }
    }

    subscript(address: Address) -> Byte {
        get {
            if address == 0xff0f { return self.interruptsFlags }
            if address == 0xffff { return self.interruptsEnabled }

            return self.gameboy[address]
        }
        set {
            switch address {
            case 0xff0f: self.interruptsFlags = newValue
            case 0xffff: self.interruptsEnabled = newValue
            default: self.gameboy[address] = newValue
            }
        }
    }

    func reset() {
        // TODO: more resetting
        self.cycleCount = 0
        self.registers.reset()
        self.checkBootROM()

        self.interruptsEnabled = 0
        self.interruptsFlags = 0
        self.interruptsMaster = true
        self.interruptsScheduled = false

        self.stopped = false
    }

    // - MARK: Fetch, Decode, Execute cycle

    func tick() {
        guard !stopped else { return }

        let (operation, cycleCount) = fetch()

        self.registers.PC &+= (1 &+ UInt16(operation.operandLength))

        execute(operation)
        updateTiming(cycleCount)
    }

    private func updateTiming(_ cycleCount: CPU.CycleCount) {
        let beforePeriods = self.cycleCount
        self.cycleCount += cycleCount
        let afterPeriods = self.cycleCount

        if self.timerControl.timerStart {
            let dividerDifference = afterPeriods / 256 - beforePeriods / 256
            if dividerDifference > 0 {
                self.timerDivider &+= UInt8(dividerDifference)
            }

            let divisor = UInt64(self.timerControl.frequency.divisor)
            let counterDifference = afterPeriods / divisor - beforePeriods / divisor
            if counterDifference > 0 {
                let newValue = UInt64(self.timerCounter) + counterDifference
                if newValue <= 0xff {
                    self.timerCounter = UInt8(newValue)
                } else {
                    self.timerCounter = self.timerModulo + UInt8(newValue & 0xff)
                    self.interruptsFlags.timer = true
                }
            }
        }
    }

    // - MARK: Interrupts

    func handleInterrupts() {
        if interruptsMaster && interruptsEnabled > 0 && interruptsFlags > 0 {
            let interruptsToFire = interruptsEnabled & interruptsFlags

            if interruptsToFire.vblank {
                interruptsFlags.vblank = false
                gameboy.gpu.vblank()
                fireInterrupt(vector: ._40)
            }

            if interruptsToFire.lcdstat {
                interruptsFlags.lcdstat = false
                fireInterrupt(vector: ._48)
            }

            if interruptsToFire.timer {
                interruptsFlags.timer = false
                fireInterrupt(vector: ._50)
            }

            if interruptsToFire.serial {
                interruptsFlags.serial = false
                fireInterrupt(vector: ._58)
            }

            if interruptsToFire.joypad {
                interruptsFlags.joypad = false
                fireInterrupt(vector: ._60)
            }
        }

        if interruptsScheduled {
            interruptsScheduled = false
            interruptsMaster = true
        }
    }

    private func fireInterrupt(vector: Instruction.Definition.ResetVector) {
        interruptsScheduled = false
        interruptsMaster = false
        execute(.Restart(vector))
        updateTiming(20)
    }

    func fetch() -> (Operation, CPU.CycleCount) {
        let opCode = self[registers.PC]

        return decoder.decode(InstructionSet[opCode])
    }

    func execute(_ operation: Operation) {
        switch operation {
        case let .Add(operand1, operand2, carrying):
            add(to: operand1, operand2, carrying)
            self.lastOperation = operation
        case let .And(operand):
            and(operand)
        case let .Call(address, condition):
            call(to: address, if: condition)
        case let .CarryFlag(operation):
            carryFlag(operation)
        case let .Compare(operand):
            compare(operand)
        case let .CompareBit(bit, operand):
            compareBit(bit, operand)
        case .Complement:
            complement()
        case .DecimalAdjustAccumulator:
            decimalAdjustAccumulator()
        case let .DecrementByte(operand):
            decrement(operand)
            self.lastOperation = operation
        case let .DecrementWord(operand):
            decrement(operand)
            self.lastOperation = operation
        case let .ExclusiveOr(operand):
            exclusiveOr(operand)
        case .Halt:
            halt()
        case let .IncrementByte(operand):
            increment(operand)
            self.lastOperation = operation
        case let .IncrementWord(operand):
            increment(operand)
            self.lastOperation = operation
        case let .Interrupts(value):
            interrupts(enabled: value)
        case let .Invalid(address, opCode):
            invalid(address, opCode)
        case let .Jump(operand, condition):
            jump(operand, condition)
        case let .LoadByte(type, into: operand1, from: operand2):
            load(type, into: operand1, from: operand2)
        case let .LoadWord(type, into: operand1, from: operand2):
            load(type, into: operand1, from: operand2)
        case .NoOp:
            noOp()
        case let .Or(operand):
            or(operand)
        case let .Pop(registerPair):
            pop(registerPair)
        case let .Push(registerPair):
            push(registerPair)
        case let .Restart(vector):
            restart(vector)
        case let .ResetBit(bit, operand):
            setBit(false, bit, operand)
        case let .Return(condition):
            return_(condition)
        case .ReturnFromInterrupt:
            returnFromInterrupt()
        case let .Rotate(direction, operand, carrying, zeroFlagBehaviour):
            rotate(direction, operand, carrying, zeroFlagBehaviour)
        case let .SetBit(bit, operand):
            setBit(true, bit, operand)
        case let .Shift(direction, operand):
            shift(direction, operand)
        case .Stop:
            stop()
        case let .Subtract(operand, carrying):
            subtract(operand, carrying)
            self.lastOperation = operation
        case let .Swap(operand):
            swap_(operand)
        }
    }

    // - MARK: Operation Helpers

    private func evaluate(_ jumpCondition: Instruction.Definition.JumpCondition) -> Bool {
        switch jumpCondition {
        case .IfCarry:       return self.registers.get(flag: .C)
        case .IfNotCarry:    return !self.registers.get(flag: .C)
        case .IfZero:        return self.registers.get(flag: .Z)
        case .IfNonZero:     return !self.registers.get(flag: .Z)
        case .Unconditional: return true
        }
    }

    private func processLoadType(_ type: Instruction.Definition.LoadType) {
        switch type {
        case .Normal:
            return
        case let .AndDecrement(name):
            self.registers[name] &-= 1
        case let .AndIncrement(name):
            self.registers[name] &+= 1
        }
    }

    private func write(_ value: Byte, to destination: Operand.OneByte) {
        switch destination {
        case let .Register(name: name, value: _):
            self.registers[name] = value
        case let .Address(address: address, value: _), let .HighAddress(address: address, value: _),
             let .RegisterIndirect(name: _, address: address, value: _), let .RegisterIndirectHigh(name: _, address: address, value: _):
            self[address] = value
        default:
            invalid("write(value: \(value), to: \(destination)")
        }
    }

    private func write(_ value: Word, to destination: Operand.TwoByte) {
        switch destination {
        case let .RegisterExtended(name: name, value: _):
            self.registers[name] = value
        case let .Address(address: address, value: _):
            self[address] = value.lowByte
            self[address + 1] = value.highByte
        default:
            invalid("write(value: \(value), to: \(destination)")
        }
    }

    // - MARK: Operations

    private func add(to destinationWrapper: Operand, _ operandWrapper: Operand, _ carrying: Instruction.Definition.Carrying) {
        switch (destinationWrapper, operandWrapper, carrying) {
        case let (.Byte(destination), .Byte(operand), _):
            let left = destination.value
            let right = operand.value
            var maybeCarry: Byte = 0

            if case .WithCarry = carrying {
                maybeCarry = self.registers.get(flag: .C) ? 1 : 0
            }

            let sum = left &+ right &+ maybeCarry
            self.write(sum, to: destination)

            self.registers.set(flag: .Z, value: sum == 0)
            self.registers.set(flag: .H, value: (left & 0x0f) + (right & 0x0f) + maybeCarry > 0x0f)
            self.registers.set(flag: .C, value: Word(left) + Word(right) + Word(maybeCarry) > 0xff)

        case let (.Word(destination), .Word(operand), _):
            let left = destination.value
            let right = operand.value
            var maybeCarry: Word = 0

            if case .WithCarry = carrying {
                maybeCarry = self.registers.get(flag: .C) ? 1 : 0
            }

            let sum = left &+ right &+ maybeCarry
            self.write(sum, to: destination)

            self.registers.set(flag: .H, value: (left & 0x0fff) + (right & 0x0fff) + maybeCarry > 0x0fff)
            self.registers.set(flag: .C, value: UInt32(left) + UInt32(right) + UInt32(maybeCarry) > 0xffff)
        case let (.Word(.RegisterExtended(name: .SP, value: value)), .Relative(offset), .WithoutCarry):
            let result = Int32(value) + Int32(offset)

            let sum = value.withOffset(by: offset)
            self.registers.SP = sum

            self.registers.set(flag: .Z, value: false)
            self.registers.set(flag: .N, value: false)
            self.registers.set(flag: .H, value: (Int32(value) ^ Int32(offset) ^ result) & 0x10 > 0)
            self.registers.set(flag: .C, value: (Int32(value) ^ Int32(offset) ^ result) & 0x100 > 0)
        default:
            invalid("add(destination: \(destinationWrapper), operand: \(operandWrapper), carrying: \(carrying)")
        }

        self.registers.set(flag: .N, value: false)
    }

    private func and(_ operand: Operand.OneByte) {
        let newValue = self.registers.A & operand.value
        self.registers.A = newValue

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: true)
        self.registers.set(flag: .C, value: false)
    }

    private func call(to address: Address, if condition: Instruction.Definition.JumpCondition) {
        guard evaluate(condition) else { return }

        self.push(.PC)
        self.registers.PC = address
    }

    private func carryFlag(_ operation: Instruction.Definition.CarryFlagOperation) {
        let carryFlag: Bool

        switch operation {
        case .Set: carryFlag = true
        case .Complement: carryFlag = !self.registers.get(flag: .C)
        }

        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: false)
        self.registers.set(flag: .C, value: carryFlag)
    }

    private func compare(_ operand: Operand.OneByte) {
        let oldValue = self.registers.A
        let newValue = oldValue &- operand.value

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: true)
        self.registers.set(flag: .H, value: (operand.value & 0x0f) > (oldValue & 0x0f))
        self.registers.set(flag: .C, value: newValue > oldValue)
    }

    private func compareBit(_ bit: Byte.Bit, _ operand: Operand.OneByte) {
        let result = bit.read(from: operand.value)

        self.registers.set(flag: .Z, value: !result)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: true)
    }

    private func complement() {
        self.registers.A = ~self.registers.A

        self.registers.set(flag: .N, value: true)
        self.registers.set(flag: .H, value: true)
    }

    private func decimalAdjustAccumulator() {
        let oldValue = self.registers.A
        var correction: Byte = self.registers.get(flag: .C) ? 0x60 : 0x00

        if self.registers.get(flag: .H) {
            correction |= 0x06
        }

        if self.registers.get(flag: .N) {
            self.registers.A = oldValue &- correction
        } else {
            if oldValue & 0x0F > 0x09 {
                correction |= 0x06
            }

            if oldValue > 0x99 {
                correction |= 0x60
            }

            self.registers.A = oldValue &+ correction
        }

        self.registers.set(flag: .C, value: correction & 0x40 > 0)
        self.registers.set(flag: .Z, value: self.registers.A == 0)
        self.registers.set(flag: .H, value: false)

//        /////////////////////
//        // Old implementation
//        let oldValue = self.registers.A
//        let negative = self.registers.get(flag: .N)
//        let carry = self.registers.get(flag: .C)
//        let halfCarry = self.registers.get(flag: .H)
//
//        let operand: Byte
//        let newCarry: Bool
//
//        switch (negative, oldValue.highNibble, oldValue.lowNibble, carry, halfCarry) {
//        case (false, 0x00...0x09, 0x00...0x09, false, false):
//            operand = 0x00
//            newCarry = false
//        case (false, 0x00...0x08, 0x0a...0x0f, false, false):
//            operand = 0x06
//            newCarry = false
//        case (false, 0x00...0x09, 0x00...0x03, false, true):
//            operand = 0x06
//            newCarry = false
//        case (false, 0x0a...0x0f, 0x00...0x09, false, false):
//            operand = 0x60
//            newCarry = true
//        case (false, 0x09...0x0f, 0x0a...0x0f, false, false):
//            operand = 0x66
//            newCarry = true
//        case (false, 0x0a...0x0f, 0x00...0x03, false, true):
//            operand = 0x66
//            newCarry = true
//        case (false, 0x00...0x02, 0x00...0x09, true, false):
//            operand = 0x60
//            newCarry = true
//        case (false, 0x00...0x02, 0x0a...0x0f, true, false):
//            operand = 0x66
//            newCarry = true
//        case (false, 0x00...0x03, 0x00...0x03, true, true):
//            operand = 0x66
//            newCarry = true
//        case (true, 0x00...0x09, 0x00...0x09, false, false):
//            operand = 0x00
//            newCarry = false
//        case (true, 0x00...0x08, 0x06...0x0f, false, true):
//            operand = 0xfa
//            newCarry = false
//        case (true, 0x07...0x0f, 0x00...0x09, true, false):
//            operand = 0xa0
//            newCarry = true
//        case (true, 0x07...0x0f, 0x07...0x0f, true, true):
//            operand = 0x9a
//            newCarry = true
//        default:
//            operand = 0x00
//            newCarry = false
//        }
//
//        let newValue = oldValue &+ operand
//        self.registers.A = newValue
//
//        self.registers.set(flag: .Z, value: newValue == 0)
//        self.registers.set(flag: .H, value: false)
//        self.registers.set(flag: .C, value: newCarry)
    }

    private func decrement(_ operand: Operand.OneByte) {
        let newValue = operand.value &- 1
        self.write(newValue, to: operand)

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: true)
        self.registers.set(flag: .H, value: newValue & 0x0f == 0x0f)
    }

    private func decrement(_ registerName: Register.Pair.Name) {
        let newValue = self.registers[registerName] &- 1
        self.registers[registerName] = newValue
    }

    private func exclusiveOr(_ operand: Operand.OneByte) {
        let newValue = self.registers.A ^ operand.value
        self.registers.A = newValue

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: false)
        self.registers.set(flag: .C, value: false)
    }

    private func halt() {
        // TODO
    }

    private func increment(_ operand: Operand.OneByte) {
        let newValue = operand.value &+ 1
        self.write(newValue, to: operand)

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: newValue & 0x0f == 0x00)
    }

    private func increment(_ registerName: Register.Pair.Name) {
        let newValue = self.registers[registerName] &+ 1
        self.registers[registerName] = newValue
    }

    private func interrupts(enabled value: Bool) {
        self.interruptsScheduled = value

        if !value {
            self.interruptsMaster = false
        }
    }

    private func invalid(_ address: Address, _ opCode: Instruction.OpCode) {
        invalid("\(String(format: "0x%02X", opCode)) @ address \(String(format: "0x%04X", address))")
    }

    private func invalid(_ message: String) {
        assertionFailure("Executed unknown instruction -- \(message)")
    }

    private func jump(_ operand: Operand, _ condition: Instruction.Definition.JumpCondition) {
        guard evaluate(condition) else { return }

        switch operand {
        case let .Relative(offset):
            self.registers.PC.offset(by: offset)
        case let .Word(.ExtendedImmediate(address)), let .Word(.RegisterExtended(name: _, value: address)),
             let .Byte(.RegisterIndirect(name: _, address: address, value: _)):
            self.registers.PC = address
        default:
            invalid("jump(operand: \(operand), condition: \(condition))")
        }
    }

    private func load(_ type: Instruction.Definition.LoadType, into destination: Operand.OneByte, from source: Operand.OneByte) {
        self.write(source.value, to: destination)
        self.processLoadType(type)
    }

    private func load(_ type: Instruction.Definition.LoadType, into destination: Operand.TwoByte, from source: Operand.TwoByte) {
        self.write(source.value, to: destination)
        self.processLoadType(type)

        if case .RegisterExtended(name: .HL, value: _) = destination {
            if case let .RegisterIndexed(name: .SP, address: address, index: index, value: _) = source {
                let result = Int32(address) + Int32(index)

                self.registers.set(flag: .Z, value: false)
                self.registers.set(flag: .N, value: false)
                self.registers.set(flag: .H, value: (Int32(address) ^ Int32(index) ^ result) & 0x10 > 0)
                self.registers.set(flag: .C, value: (Int32(address) ^ Int32(index) ^ result) & 0x100 > 0)
            }
        }
    }

    private func noOp() {}

    private func or(_ operand: Operand.OneByte) {
        let newValue = self.registers.A | operand.value
        self.registers.A = newValue

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: false)
        self.registers.set(flag: .C, value: false)
    }

    private func pop(_ name: Register.Pair.Name) {
        let lowByte = self[self.registers.SP]
        self.registers.SP &+= 1
        let highByte = self[self.registers.SP]
        self.registers.SP &+= 1

        self.registers[name] = Word(highByte, lowByte)
    }

    var afDepth = 2
    private func push(_ name: Register.Pair.Name) {
        let value = self.registers[name]

        self.registers.SP &-= 1
        self[self.registers.SP] = value.highByte
        self.registers.SP &-= 1
        self[self.registers.SP] = value.lowByte
    }

    private func restart(_ vector: Instruction.Definition.ResetVector) {
        self.push(.PC)
        self.registers.PC = vector.rawValue
    }

    private func return_(_ condition: Instruction.Definition.JumpCondition) {
        guard evaluate(condition) else { return }

        self.pop(.PC)
    }

    private func returnFromInterrupt() {
        self.interruptsMaster = true
        self.pop(.PC)
    }

    // RLC: (Rotate Left with Carry)                                   RRC: (Rotate Right with Carry)
    //
    //       +----------------------------------+                      +----------------------------------+
    //       |                                  |                      |                                  |
    //       |                                  v                      v                                  |
    // CY <- 7 <- 6 <- 5 <- 4 <- 3 <- 2 <- 1 <- 0                      7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> 0 -> CY
    //       ^-- newCarryValue                  ^-- wrappedBit         ^-- wrappedBit                     ^-- newCarryValue
    //
    // RL: (Rotate Left)                                               RR: (Rotate Right)
    //
    //  +---------------------------------------+                      +---------------------------------------+
    //  |                                       |                      |                                       |
    //  |                                       v                      v                                       |
    // CY <- 7 <- 6 <- 5 <- 4 <- 3 <- 2 <- 1 <- 0                      7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> 0 -> CY
    //       ^-- newCarryValue                  ^-- wrappedBit         ^-- wrappedBit                     ^-- newCarryValue
    //
    // For rotating left: 7 is always newCarryValue, 0 is always wrappedBit
    // For rotating right: 7 is always wrappedBit, 0 is always newCarryValue
    //
    // For non-carry: wrappedBitValue is always from newCarryValue
    // For carry: wrappedBitValue is always from oldCarryValue
    private func rotate(_ direction: Instruction.Definition.RotateDirection,
                                 _ operand: Operand.OneByte,
                                 _ carrying: Instruction.Definition.Carrying,
                                 _ zeroFlagBehaviour: Instruction.Definition.ZeroFlagBehaviour) {
        let newCarryValue: Byte.Bit.Value
        var newValue: Byte
        let wrappedBit: Byte.Bit
        switch direction {
        case .Left:
            newCarryValue = Byte.Bit._7.read(from: operand.value)
            newValue = operand.value << 1
            wrappedBit = Byte.Bit._0
        case .Right:
            newCarryValue = Byte.Bit._0.read(from: operand.value)
            newValue = operand.value >> 1
            wrappedBit = Byte.Bit._7
        }

        let wrappedBitNewValue: Byte.Bit.Value
        switch carrying {
        case .WithCarry: wrappedBitNewValue = newCarryValue
        case .WithoutCarry: wrappedBitNewValue = self.registers.get(flag: .C)
        }

        wrappedBit.write(wrappedBitNewValue, to: &newValue)
        self.write(newValue, to: operand)

        let zeroFlagValue: Bool
        switch zeroFlagBehaviour {
        case .Clear: zeroFlagValue = false
        case .SetIfZero: zeroFlagValue = (newValue == 0)
        }

        self.registers.set(flag: .Z, value: zeroFlagValue)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: false)
        self.registers.set(flag: .C, value: newCarryValue)
    }

    private func setBit(_ value: Byte.Bit.Value, _ bit: Byte.Bit, _ operand: Operand.OneByte) {
        let newValue = bit.set(value, on: operand.value)

        self.write(newValue, to: operand)
    }

    // SLA:
    //
    //  CY <- 7 <- 6 <- 5 <- 4 <- 3 <- 2 <- 1 <- 0 <- "0"
    //        ^-- newCarryValue                  ^-- wrappedBit
    // SRA:
    //
    //     +--+
    //     |  |
    //     |  v
    //     +- 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> 0 -> CY
    //        ^-- wrappedBit                     ^-- newCarryValue
    // SRL:
    //
    // "0" -> 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> 0 -> CY
    //        ^-- wrappedBit                     ^-- newCarryValue
    private func shift(_ direction: Instruction.Definition.ShiftDirection, _ operand: Operand.OneByte) {
        let newCarryValue: Byte.Bit.Value
        var newValue: Byte
        let wrappedBit: Byte.Bit
        let wrappedBitNewValue: Byte.Bit.Value

        switch direction {
        case .LeftArithmetic:
            newCarryValue = Byte.Bit._7.read(from: operand.value)
            newValue = operand.value << 1
            wrappedBit = Byte.Bit._0
            wrappedBitNewValue = false
        case .RightArithmetic:
            newCarryValue = Byte.Bit._0.read(from: operand.value)
            newValue = operand.value >> 1
            wrappedBit = Byte.Bit._7
            wrappedBitNewValue = wrappedBit.read(from: operand.value)
        case .RightLogical:
            newCarryValue = Byte.Bit._0.read(from: operand.value)
            newValue = operand.value >> 1
            wrappedBit = Byte.Bit._7
            wrappedBitNewValue = false
        }

        wrappedBit.write(wrappedBitNewValue, to: &newValue)
        self.write(newValue, to: operand)

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: false)
        self.registers.set(flag: .C, value: newCarryValue)
    }

    private func stop() {
        self.stopped = true

//        var key1 = self[0xff4d]
//        let prepareSpeedSwitch = Byte.Bit._0.read(from: key1)
//        let currentSpeed = Byte.Bit._7.read(from: key1)
//        if prepareSpeedSwitch {
//            Byte.Bit._0.write(false, to: &key1)
//            Byte.Bit._7.write(!currentSpeed, to: &key1)
//            self[0xff4d] = key1
//        }
    }

    private func subtract(_ operand: Operand.OneByte, _ carrying: Instruction.Definition.Carrying) {
        let oldValue = self.registers.A
        var maybeCarry: Byte = 0
        var newValue = oldValue &- operand.value

        if case .WithCarry = carrying {
            if self.registers.get(flag: .C) {
                maybeCarry = 1
            }
        }

        newValue &-= maybeCarry
        self.registers.A = newValue

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: true)
        self.registers.set(flag: .H, value: (operand.value & 0x0f) + maybeCarry > (oldValue & 0x0f))
        self.registers.set(flag: .C, value: UInt16(operand.value) + UInt16(maybeCarry) > oldValue)
    }

    private func swap_(_ operand: Operand.OneByte) {
        let newValue = operand.value.swapped

        self.write(newValue, to: operand)

        self.registers.set(flag: .Z, value: newValue == 0)
        self.registers.set(flag: .N, value: false)
        self.registers.set(flag: .H, value: false)
        self.registers.set(flag: .C, value: false)
    }
}

extension CPU.TimerControl {
    enum Frequency: UInt8 {
        case _4096Hz   = 0b00
        case _262144Hz = 0b01
        case _65536Hz  = 0b10
        case _16384Hz  = 0b11

        var divisor: UInt {
            switch self {
            case ._4096Hz: return 1_024
            case ._262144Hz: return 16
            case ._65536Hz: return 64
            case ._16384Hz: return 256
            }
        }
    }

    var timerStart: Bool {
        return Byte.Bit._2.read(from: self)
    }

    var frequency: Frequency {
        let highBit = Byte.Bit._1.read(from: self)
        let lowBit = Byte.Bit._0.read(from: self)

        switch (highBit, lowBit) {
        case (false, false): return ._4096Hz
        case (false, true): return ._262144Hz
        case (true, false): return ._65536Hz
        case (true, true): return ._16384Hz
        }
    }
}
