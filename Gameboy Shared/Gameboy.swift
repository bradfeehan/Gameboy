//
//  Gameboy.swift
//  Gameboy
//
//  Created by Brad Feehan on 9/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

import Foundation

class Gameboy {
    static let BOOT_ROM_CAPACITY: Address = 0x100
    static let BOOT_ROM_OFFSET: Address = 0
    static let BOOT_ROM_RANGE = BOOT_ROM_OFFSET..<(BOOT_ROM_OFFSET + BOOT_ROM_CAPACITY)

    static let CARTRIDGE_ROM_CAPACITY: Address = 0x8000
    static let CARTRIDGE_ROM_OFFSET: Address = 0
    static let CARTRIDGE_ROM_RANGE = CARTRIDGE_ROM_OFFSET..<(CARTRIDGE_ROM_OFFSET + CARTRIDGE_ROM_CAPACITY)

    static let CARTRIDGE_RAM_CAPACITY: Address = 0x2000
    static let CARTRIDGE_RAM_OFFSET: Address = 0xa000
    static let CARTRIDGE_RAM_RANGE = CARTRIDGE_RAM_OFFSET..<(CARTRIDGE_RAM_OFFSET + CARTRIDGE_RAM_CAPACITY)

    static let WORKING_RAM_CAPACITY: Address = 0x2000
    static let WORKING_RAM_OFFSET: Address = 0xc000
    static let WORKING_RAM_RANGE = WORKING_RAM_OFFSET..<(WORKING_RAM_OFFSET + WORKING_RAM_CAPACITY)

    static let WORKING_RAM_SHADOW_CAPACITY: Address = 0x1e00
    static let WORKING_RAM_SHADOW_OFFSET: Address = 0xe000
    static let WORKING_RAM_SHADOW_RANGE = WORKING_RAM_SHADOW_OFFSET..<(WORKING_RAM_SHADOW_OFFSET + WORKING_RAM_SHADOW_CAPACITY)

    static let OBJECT_ATTRIBUTE_RAM_CAPACITY: Address = 0x0100
    static let OBJECT_ATTRIBUTE_RAM_OFFSET: Address = 0xfe00
    static let OBJECT_ATTRIBUTE_RAM_RANGE = OBJECT_ATTRIBUTE_RAM_OFFSET..<(OBJECT_ATTRIBUTE_RAM_OFFSET + OBJECT_ATTRIBUTE_RAM_CAPACITY)

    static let HIGH_RAM_CAPACITY: Address = 0x7f
    static let HIGH_RAM_OFFSET: Address = 0xff80
    static let HIGH_RAM_RANGE = HIGH_RAM_OFFSET..<(HIGH_RAM_OFFSET + HIGH_RAM_CAPACITY)

    static let IO_CAPACITY: Address = 0x100
    static let IO_OFFSET: Address = 0xff00
    static let IO_RANGE = IO_OFFSET...(IO_OFFSET - 1 + IO_CAPACITY)

    static let IO_RESET: Array<Byte> = [
        0x0F, 0x00, 0x7C, 0xFF, 0x00, 0x00, 0x00, 0xF8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01, // 0x0f
        0x80, 0xBF, 0xF3, 0xFF, 0xBF, 0xFF, 0x3F, 0x00, 0xFF, 0xBF, 0x7F, 0xFF, 0x9F, 0xFF, 0xBF, 0xFF, // 0x1f
        0xFF, 0x00, 0x00, 0xBF, 0x77, 0xF3, 0xF1, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // 0x2f
        0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, // 0x3f
        0x91, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFC, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x7E, 0xFF, 0xFE, // 0x4f
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3E, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // 0x5f
        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xC0, 0xFF, 0xC1, 0x00, 0xFE, 0xFF, 0xFF, 0xFF, // 0x6f
        0xF8, 0xFF, 0x00, 0x00, 0x00, 0x8F, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // 0x7f
        0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D, // 0x8f
        0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E, 0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99, // 0x9f
        0xBB, 0xBB, 0x67, 0x63, 0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E, // 0xaf
        0x45, 0xEC, 0x52, 0xFA, 0x08, 0xB7, 0x07, 0x5D, 0x01, 0xFD, 0xC0, 0xFF, 0x08, 0xFC, 0x00, 0xE5, // 0xbf
        0x0B, 0xF8, 0xC2, 0xCE, 0xF4, 0xF9, 0x0F, 0x7F, 0x45, 0x6D, 0x3D, 0xFE, 0x46, 0x97, 0x33, 0x5E, // 0xcf
        0x08, 0xEF, 0xF1, 0xFF, 0x86, 0x83, 0x24, 0x74, 0x12, 0xFC, 0x00, 0x9F, 0xB4, 0xB7, 0x06, 0xD5, // 0xdf
        0xD0, 0x7A, 0x00, 0x9E, 0x04, 0x5F, 0x41, 0x2F, 0x1D, 0x77, 0x36, 0x75, 0x81, 0xAA, 0x70, 0x3A, // 0xef
        0x98, 0xD1, 0x71, 0x02, 0x4D, 0x01, 0xC1, 0xFF, 0x0D, 0x00, 0xD3, 0x05, 0xF9, 0x00, 0x0B, 0x00, // 0xff
    ]

    var cpu = CPU()
    var gpu = GPU()
    weak var screen: GameboyScreen?

    let bootROMImage = #fileLiteral(resourceName: "BootROM.bin")
    let bootROM: Data
    var bootROMEnabled = BOOT_ROM_ENABLED
    static let BOOT_ROM_ENABLED = false
    var cartridgeROM = Data(repeating: 0, count: Int(Gameboy.CARTRIDGE_ROM_CAPACITY))
    var cartridgeRAM = Memory(capacity: Gameboy.CARTRIDGE_RAM_OFFSET, offset: Gameboy.CARTRIDGE_RAM_OFFSET)
    var workingRAM = Memory(capacity: Gameboy.WORKING_RAM_CAPACITY, offset: Gameboy.WORKING_RAM_OFFSET)
    var objectAttributeRAM = Memory(capacity: Gameboy.OBJECT_ATTRIBUTE_RAM_CAPACITY, offset: Gameboy.OBJECT_ATTRIBUTE_RAM_OFFSET)
    var highRAM = Memory(capacity: Gameboy.HIGH_RAM_CAPACITY, offset: Gameboy.HIGH_RAM_OFFSET)
    var io = Memory(capacity: Gameboy.IO_CAPACITY, offset: Gameboy.IO_OFFSET, initialValue: Gameboy.IO_RESET)

    init() {
        let fileHandle: FileHandle

        do {
            fileHandle = try FileHandle(forReadingFrom: self.bootROMImage.absoluteURL)
        } catch {
            fatalError("Couldn't load Boot ROM")
        }

        self.bootROM = fileHandle.readDataToEndOfFile()
        self.cpu.connect(to: self)
        self.gpu.connect(to: self)
    }

    func load(rom: URL) throws {
        self.cartridgeROM = try FileHandle(forReadingFrom: rom).readDataToEndOfFile()
        self.reset()
    }

    func connect(to screen: GameboyScreen) {
        self.screen = screen
    }

    func reset() {
        self.bootROMEnabled = Self.BOOT_ROM_ENABLED
        self.cpu.reset()
        self.gpu.reset()
        self.screen?.reset()
        self.cartridgeRAM.reset()
        self.workingRAM.reset()
        self.objectAttributeRAM.reset()
        self.highRAM.reset()
        self.io.reset(to: Self.IO_RESET)

        self[0xFF04] = 0
        self[0xFF05] = 0
        self[0xFF06] = 0
        self[0xFF07] = 0
        self[0xFF10] = 0x80
        self[0xFF11] = 0xBF
        self[0xFF12] = 0xF3
        self[0xFF14] = 0xBF
        self[0xFF16] = 0x3F
        self[0xFF17] = 0x00
        self[0xFF19] = 0xBF
        self[0xFF1A] = 0x7A
        self[0xFF1B] = 0xFF
        self[0xFF1C] = 0x9F
        self[0xFF1E] = 0xBF
        self[0xFF20] = 0xFF
        self[0xFF21] = 0x00
        self[0xFF22] = 0x00
        self[0xFF23] = 0xBF
        self[0xFF24] = 0x77
        self[0xFF25] = 0xF3
        self[0xFF26] = 0xF1
        self[0xFF40] = 0x91
        self[0xFF42] = 0x00
        self[0xFF43] = 0x00
        self[0xFF45] = 0x00
        self[0xFF47] = 0xFC
        self[0xFF48] = 0xFF
        self[0xFF49] = 0xFF
        self[0xFF4A] = 0x00
        self[0xFF4B] = 0x00
        self[0xFFFF] = 0x00
    }

    func tick() {
        self.cpu.tick()
        self.gpu.update(cycleCount: self.cpu.cycleCount)
        self.cpu.handleInterrupts()
    }

    subscript(address: Address) -> Byte {
        get {
            if self.bootROMEnabled && Self.BOOT_ROM_RANGE.contains(address) {
                return self.bootROM[Int(address)]
            }

            if Self.CARTRIDGE_ROM_RANGE.contains(address) {
                return self.cartridgeROM[Int(address)]
            }

            if GPU.VIDEO_RAM_RANGE.contains(address) {
                return self.gpu[address]!
            }

            if Self.CARTRIDGE_RAM_RANGE.contains(address) {
                return self.cartridgeRAM[address]!
            }

            if Self.WORKING_RAM_RANGE.contains(address) {
                return self.workingRAM[address]!
            }

            if Self.WORKING_RAM_SHADOW_RANGE.contains(address) {
                let realAddress = address - Self.WORKING_RAM_SHADOW_OFFSET + Self.WORKING_RAM_OFFSET
                return self.workingRAM[realAddress]!
            }

            if Self.OBJECT_ATTRIBUTE_RAM_RANGE.contains(address) {
                return self.objectAttributeRAM[address]!
            }

            if address == 0xff00 {
                var byte: Byte = 0xc0

                if !Byte.Bit._5.read(from: io[0xff00]!) {
                    Byte.Bit._4.write(true, to: &byte)
                    // TODO: add button keys in
                    return byte
                }
                if !Byte.Bit._4.read(from: io[0xff00]!) {
                    Byte.Bit._5.write(true, to: &byte)
                    // TODO: add direction keys in
                    return byte
                }

                return 0
            }

            if address == 0xff04 { return cpu.timerDivider }
            if address == 0xff05 { return cpu.timerCounter }
            if address == 0xff06 { return cpu.timerModulo }
            if address == 0xff07 { return cpu.timerControl }

            if address == 0xff40 { return gpu.lcdControl.value }
            if address == 0xff42 { return gpu.scrollY }
            if address == 0xff43 { return gpu.scrollX }
            if address == 0xff44 { return gpu.scanLine }

            if address == 0xff0f { return cpu.interruptsFlags }
            if address == 0xffff { return cpu.interruptsEnabled }

            if Self.HIGH_RAM_RANGE.contains(address) {
                return self.highRAM[address]!
            }

            if Self.IO_RANGE.contains(address) {
                return self.io[address]!
            }

            fatalError("Unknown address: \(String(format: "%04X", address))")
        }
        set(newValue) {
            if address == 0xff02 && (newValue & 0x80 > 0) {
                print(Character(UnicodeScalar(self[0xff01])), terminator: "")
            }

            if GPU.VIDEO_RAM_RANGE.contains(address) {
                self.gpu[address] = newValue
            }

            if Self.CARTRIDGE_RAM_RANGE.contains(address) {
                self.cartridgeRAM[address] = newValue
            }

            if Self.WORKING_RAM_RANGE.contains(address) {
                self.workingRAM[address] = newValue
            }

            if Self.WORKING_RAM_SHADOW_RANGE.contains(address) {
                let realAddress = address - Self.WORKING_RAM_SHADOW_OFFSET + Self.WORKING_RAM_OFFSET
                self.workingRAM[realAddress] = newValue
            }

            if Self.OBJECT_ATTRIBUTE_RAM_RANGE.contains(address) {
                self.objectAttributeRAM[address] = newValue
            }

            if address == 0xff04 { cpu.timerDivider = 0 }
            if address == 0xff05 { cpu.timerCounter = newValue }
            if address == 0xff06 { cpu.timerModulo = newValue }
            if address == 0xff07 { cpu.timerControl = newValue }

            if address == 0xff40 { gpu.lcdControl.value = newValue }
            if address == 0xff42 { gpu.scrollY = newValue }
            if address == 0xff43 { gpu.scrollX = newValue }
            if address == 0xff46 { copy(from: Self.OBJECT_ATTRIBUTE_RAM_OFFSET, to: Address(newValue) << 8, bytes: 160) }
            if address == 0xff47 { gpu.updatePalette(GPU.PaletteSelection.Background, newValue) }
            if address == 0xff48 { gpu.updatePalette(GPU.PaletteSelection.Sprite(index: 0), newValue) }
            if address == 0xff49 { gpu.updatePalette(GPU.PaletteSelection.Sprite(index: 1), newValue) }
            if address == 0xff50 && newValue == 0x01 { self.bootROMEnabled = false }

            if address == 0xff0f { cpu.interruptsFlags = newValue }
            if address == 0xffff { cpu.interruptsEnabled = newValue }

            if Self.HIGH_RAM_RANGE.contains(address) {
                self.highRAM[address] = newValue
            }

            if Self.IO_RANGE.contains(address) {
                self.io[address] = newValue
            }
        }
    }

    private func copy(from source: Address, to destination: Address, bytes length: Address) {
        for index in 0..<length {
            self[destination + index] = self[source + index]
        }
    }
}
