//
//  OperationDecoder.swift
//  Gameboy
//
//  Created by Brad Feehan on 15/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

extension Operation {
    class Decoder {
        private weak var cpu: CPU!
        private var offset: Address = 0

        init(cpu: CPU) {
            self.cpu = cpu
        }

        func decode(_ instructionOrSet: Instruction.InstructionOrSet) -> (Operation, CPU.CycleCount) {
            self.offset = 1
            switch instructionOrSet {
            case let .Instruction(instruction):
                return decode(instruction)
            case let .Set(subInstructions):
                return decode(subInstructions[self.nextImmediate()])
            }
        }

        private func decode(_ instruction: Instruction) -> (Operation, CPU.CycleCount) {
            let operation = self.operation(instruction)
            let cycleCount = self.cycleCount(operation, instruction.timing)

            return (operation, cycleCount)
        }

        private func operation(_ instruction: Instruction) -> Operation {
            switch instruction.definition {
            case let .Add(operand1, operand2, carrying):
                return .Add(self.fetch(operand1), self.fetch(operand2), carrying)
            case let .And(operand):
                return .And(self.fetch(operand))
            case let .Call(condition):
                return .Call(self.nextImmediateWord(), condition)
            case let .CarryFlag(operation):
                return .CarryFlag(operation)
            case let .Compare(operand):
                return .Compare(self.fetch(operand))
            case let .CompareBit(bit, operand):
                return .CompareBit(bit, self.fetch(operand))
            case .Complement:
                return .Complement
            case .DecimalAdjustAccumulator:
                return .DecimalAdjustAccumulator
            case let .DecrementByte(operand):
                return .DecrementByte(self.fetch(operand))
            case let .DecrementWord(registerPairName):
                return .DecrementWord(registerPairName)
            case let .ExclusiveOr(operand):
                return .ExclusiveOr(self.fetch(operand))
            case .Halt:
                return .Halt
            case let .IncrementByte(operand):
                return .IncrementByte(self.fetch(operand))
            case let .IncrementWord(registerPairName):
                return .IncrementWord(registerPairName)
            case let .Interrupts(value):
                return .Interrupts(value)
            case .Invalid:
                return .Invalid(address: self.cpu.registers.PC, opCode: instruction.opCode)
            case let .Jump(operand, condition):
                return .Jump(self.fetch(operand), condition)
            case let .LoadByte(type, into: destination, from: source):
                return .LoadByte(type, into: self.fetch(destination), from: self.fetch(source))
            case let .LoadWord(type, into: destination, from: source):
                return .LoadWord(type, into: self.fetch(destination), from: self.fetch(source))
            case .NoOp:
                return .NoOp
            case let .Or(operand):
                return .Or(self.fetch(operand))
            case let .Pop(registerPairName):
                return .Pop(registerPairName)
            case let .Push(registerPairName):
                return .Push(registerPairName)
            case let .Restart(vector):
                return .Restart(vector)
            case let .ResetBit(bit, operand):
                return .ResetBit(bit, self.fetch(operand))
            case let .Return(condition):
                return .Return(condition)
            case .ReturnFromInterrupt:
                return .ReturnFromInterrupt
            case let .Rotate(direction, operand, carrying, zeroFlagBehaviour):
                return .Rotate(direction, self.fetch(operand), carrying, zeroFlagBehaviour)
            case let .SetBit(bit, operand):
                return .SetBit(bit, self.fetch(operand))
            case let .Shift(direction, operand):
                return .Shift(direction, self.fetch(operand))
            case .Stop:
                return .Stop
            case let .Subtract(operand, carrying):
                return .Subtract(self.fetch(operand), carrying)
            case let .Swap(operand):
                return .Swap(self.fetch(operand))
            }
        }

        private func cycleCount(_ operation: Operation, _ timing: Instruction.Timing) -> CPU.CycleCount {
            switch timing {
            case let .Constant(cycleCount):
                return cycleCount
            case let .Variable(cycleCountIfTaken, cycleCountIfNotTaken):
                let taken: Bool

                switch operation {
                case let .Call(_, condition), let .Jump(_, condition), let .Return(condition):
                    switch condition {
                    case .IfCarry: taken = cpu.registers.get(flag: .C)
                    case .IfZero: taken = cpu.registers.get(flag: .Z)
                    case .IfNonZero: taken = !cpu.registers.get(flag: .Z)
                    case .IfNotCarry: taken = !cpu.registers.get(flag: .C)
                    case .Unconditional: taken = true
                    }
                default: taken = false
                }

                return taken ? cycleCountIfTaken : cycleCountIfNotTaken
            }
        }

        private func fetch(_ operand: Operand.Definition) -> Operand {
            switch operand {
            case .Relative:
                return .Relative(Int8(bitPattern: self.nextImmediate()))
            case let .Byte(definition):
                return .Byte(self.fetch(definition))
            case let .Word(definition):
                return .Word(self.fetch(definition))
            }
        }

        private func fetch(_ operand: Operand.Definition.OneByte) -> Operand.OneByte {
            switch operand {
            case .Address:
                let address = self.nextImmediateWord()
                return .Address(address: address, value: self.cpu[address])
            case .HighAddress:
                let address = Address(0xff, self.nextImmediate())
                return .HighAddress(address: address, value: self.cpu[address])
            case .Immediate:
                return .Immediate(self.nextImmediate())
            case let .Register(name):
                return .Register(name: name, value: self.cpu.registers[name])
            case let .RegisterIndirect(name):
                let address = self.cpu.registers[name]
                return .RegisterIndirect(name: name, address: address, value: self.cpu[address])
            case let .RegisterIndirectHigh(name):
                let address = Address(0xff, self.cpu.registers[name])
                return .RegisterIndirectHigh(name: name, address: address, value: self.cpu[address])
            }
        }

        private func fetch(_ operand: Operand.Definition.TwoByte) -> Operand.TwoByte {
            switch operand {
            case .Address:
                let address = self.nextImmediateWord()
                return .Address(address: address, value: Word(self.cpu[address + 1], self.cpu[address]))
            case .ExtendedImmediate:
                return .ExtendedImmediate(self.nextImmediateWord())
            case let .RegisterExtended(name):
                return .RegisterExtended(name: name, value: self.cpu.registers[name])
            case let .RegisterIndexed(name):
                let baseAddress = self.cpu.registers[name]
                let index = Int8(bitPattern: self.nextImmediate())
                return .RegisterIndexed(name: name, address: baseAddress, index: index, value: baseAddress.withOffset(by: index))
            }
        }

        private func nextImmediate() -> Byte {
            self.offset += 1
            return self.cpu[self.cpu.registers.PC + self.offset - 1]
        }

        private func nextImmediateWord() -> Word {
            self.offset += 2
            return Word(
                self.cpu[self.cpu.registers.PC + self.offset - 1],
                self.cpu[self.cpu.registers.PC + self.offset - 2]
            )
        }
    }
}
