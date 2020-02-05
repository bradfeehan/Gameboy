//
//  GPU.swift
//  Gameboy
//
//  Created by Brad Feehan on 15/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

class GPU {
    static let HORIZONTAL_BLANK_CYCLES: CPU.CycleCount = 204
    static let VERTICAL_BLANK_CYCLES: CPU.CycleCount = 456
    static let OBJECT_ATTRIBUTE_MEMORY_CYCLES: CPU.CycleCount = 80
    static let VIDEO_RAM_CYCLES: CPU.CycleCount = 172

    static let VERTICAL_BLANK_SCANLINE = 143
    static let MAX_SCANLINE = 153

    static let VIDEO_RAM_CAPACITY: Address = 0x2000
    static let VIDEO_RAM_OFFSET: Address = 0x8000
    static let VIDEO_RAM_RANGE = VIDEO_RAM_OFFSET..<(VIDEO_RAM_OFFSET + VIDEO_RAM_CAPACITY)

    static let VIDEO_RAM_TILE_CAPACITY: Address = 0x1800
    static let VIDEO_RAM_TILE_RANGE = VIDEO_RAM_OFFSET..<(VIDEO_RAM_OFFSET + VIDEO_RAM_TILE_CAPACITY)

    var videoRAM = Memory(capacity: GPU.VIDEO_RAM_CAPACITY, offset: GPU.VIDEO_RAM_OFFSET)

    typealias Pixel = UInt32
    typealias Palette = [Pixel]
    static let PALETTE: Palette = [0xffdddddd, 0xffaaaaaa, 0xff555555, 0xff000000]
//    static let PALETTE: Palette = [0xff0000dd, 0xff00aa00, 0xff550000, 0xff000000]

    var backgroundPalette = Palette(repeating: GPU.PALETTE[0], count: 4)
    var spritePalette = [Palette](repeating: Palette(repeating: GPU.PALETTE[0], count: 4), count: 2)

    enum PaletteSelection {
        case Background, Sprite(index: Int)

        func update(gpu: GPU, index: Int, value: Pixel) {
            switch self {
            case .Background:
                gpu.backgroundPalette[index] = value
            case .Sprite(let palette) where palette < gpu.spritePalette.count:
                gpu.spritePalette[palette][index] = value
            case .Sprite(let palette):
                fatalError("No such sprite palette \(palette)")
            }
        }
    }

    var lcdControl = LCDControl()          // 0xFF40 LCDC
    var mode = Mode.HorizontalBlank        // 0xFF41 STAT (bits 1-0)
    var scrollY: Byte = 0                  // 0xFF42 SCY   jsGB: yscrl
    var scrollX: Byte = 0                  // 0xFF43 SCX   jsGB: xscrl
    var scanLine: Byte = 0                 // 0xFF44 LY    jsGB: curline
    var cpuCycleCount: CPU.CycleCount = 0
    private var lastCpuCycleCount: CPU.CycleCount = 0

    static let TILE_COUNT = 384

    typealias PaletteIndex = UInt8
    typealias TileRow = [PaletteIndex]
    typealias Tile = [TileRow]
    static let TILE_WIDTH = 8
    static let TILE_HEIGHT = 8

    private var tiles: [Tile] = [Tile](
        repeating: Tile(repeating: TileRow(repeating: 0, count: GPU.TILE_WIDTH), count: GPU.TILE_HEIGHT),
        count: GPU.TILE_COUNT
    )

    private var frameBuffer = [Pixel](repeating: PALETTE[0], count: 160 * 144)

    enum Mode {
        case HorizontalBlank, VerticalBlank, ObjectAttributeMemory, VideoRam
    }

    weak var gameboy: Gameboy!

    func connect(to gameboy: Gameboy) {
        self.gameboy = gameboy
    }

    func reset() {
        self.videoRAM.reset()
        self.lcdControl = LCDControl()
        self.mode = Mode.HorizontalBlank
        self.scanLine = 0
        self.scrollX = 0
        self.scrollY = 0
        self.cpuCycleCount = 0
        self.lastCpuCycleCount = 0
        self.frameBuffer = [Pixel](repeating: GPU.PALETTE[0], count: 160 * 144)
        self.backgroundPalette = Palette(repeating: GPU.PALETTE[0], count: 4)
        self.spritePalette = [Palette](repeating: Palette(repeating: GPU.PALETTE[0], count: 4), count: 2)
        self.tiles = [Tile](
            repeating: Tile(repeating: TileRow(repeating: 0, count: GPU.TILE_WIDTH), count: GPU.TILE_HEIGHT),
            count: GPU.TILE_COUNT
        )
    }

    func update(cycleCount cpuCycleCount: CPU.CycleCount) {
        self.cpuCycleCount += (cpuCycleCount - self.lastCpuCycleCount)
        self.lastCpuCycleCount = cpuCycleCount

        switch self.mode {
        case .HorizontalBlank:
            if self.cpuCycleCount >= Self.HORIZONTAL_BLANK_CYCLES {
                // End of HBlank
                self.scanLine += 1

                if self.scanLine == Self.VERTICAL_BLANK_SCANLINE {
                    // Start of VBlank
                    vblank()
                    gameboy.cpu.interruptsFlags.vblank = true
                    self.mode = .VerticalBlank
                } else {
                    self.mode = .ObjectAttributeMemory
                }

                self.cpuCycleCount -= Self.HORIZONTAL_BLANK_CYCLES
            }

        case .VerticalBlank:
            if self.cpuCycleCount >= Self.VERTICAL_BLANK_CYCLES {
                self.scanLine += 1

                if self.scanLine > Self.MAX_SCANLINE {
                    // End of VBlank
                    self.scanLine = 0
                    self.mode = .ObjectAttributeMemory
                }

                self.cpuCycleCount -= Self.VERTICAL_BLANK_CYCLES
            }

        case .ObjectAttributeMemory:
            if self.cpuCycleCount >= Self.OBJECT_ATTRIBUTE_MEMORY_CYCLES {
                self.mode = .VideoRam
                self.cpuCycleCount -= Self.OBJECT_ATTRIBUTE_MEMORY_CYCLES
            }

        case .VideoRam:
            if self.cpuCycleCount >= Self.VIDEO_RAM_CYCLES {
                // Start of HBlank
                self.mode = .HorizontalBlank
                self.renderScanline()
                self.cpuCycleCount -= Self.VIDEO_RAM_CYCLES
            }
        }
    }

    subscript(_ address: Address) -> Byte? {
        get {
            return Self.VIDEO_RAM_RANGE.contains(address) ? self.videoRAM[address]! : nil
        }
        set(maybeNewValue) {
            guard let newValue = maybeNewValue else { return }
            self.videoRAM[address] = newValue
            if Self.VIDEO_RAM_TILE_RANGE.contains(address) {
                self.updateTile(address, newValue)
            }
        }
    }

    func updateTile(_ address: Address, _ newValue: Byte) {
        let offset = address - Self.VIDEO_RAM_OFFSET
        let baseAddress = address & 0xFFFE // Clear last bit
        let tile = Int((offset >> 4) & 0x1FF)
        let y = Int((offset >> 1) & 0b111)

        let lowByte = self.videoRAM[baseAddress]!
        let highByte = self.videoRAM[baseAddress + 1]!

        for x in 0..<Self.TILE_WIDTH {
            let bit = Byte.Bit(rawValue: UInt8(7 - x))!
            let lowBit = bit.read(from: lowByte)
            let highBit = bit.read(from: highByte)
            self.tiles[tile][y][x] = (highBit ? 2 : 0) + (lowBit ? 1 : 0)
        }
    }

    func updatePalette(_ paletteSelection: PaletteSelection, _ value: Byte) {
        for index in 0..<4 {
            paletteSelection.update(gpu: self, index: index, value: GPU.PALETTE[Int(value >> (index * 2)) & 0b11])
        }
    }

    private func renderScanline() {
        guard lcdControl.lcdDisplayEnable else { return }

        var scanLineRow = [Byte](repeating: 0, count: 160)

        //155674
        if lcdControl.bgDisplayEnable {
            let pixelOffset = Int(scanLine) * 160
            let mapOffset = lcdControl.tileMapBaseAddress + Address((((UInt16(scanLine) + UInt16(scrollY)) & 0xff) >> 3) << 5)

            let y = (Int(scanLine) + Int(scrollY)) & 0b111
            var x = Int(scrollX) & 0b111
            var lineOffset = Address(scrollX >> 3)
            var tileId = Int(videoRAM[mapOffset + lineOffset]!)

            if lcdControl.tileDataSelect == .High && tileId < 128 {
                tileId += 256
            }

            for i in 0..<160 {
                let paletteIndex = tiles[tileId][y][x]
                frameBuffer[pixelOffset + i] = backgroundPalette[Int(paletteIndex)]
                scanLineRow[i] = paletteIndex
                x += 1
                if x == 8 {
                    x = 0
                    lineOffset = (lineOffset + 1) & 0b1_1111
                    tileId = Int(videoRAM[mapOffset + lineOffset]!)
                    if lcdControl.tileDataSelect == .High && tileId < 128 {
                        tileId += 256
                    }
                }
            }
        }

        if lcdControl.spriteDisplayEnable {
            var count = 0
            for index in 0..<40 {
                let sprite = self.sprite(index)
                if sprite.y <= scanLine && (sprite.y + 8) > scanLine {
                    let pixelOffset = Int(scanLine) * 160 + Int(sprite.x)
                    let palette = spritePalette[sprite.palette ? 1 : 0]

                    let tileRow: Int
                    if sprite.verticalFlip {
                        tileRow = 7 - (Int(scanLine) - sprite.y)
                    } else {
                        tileRow = Int(scanLine) - sprite.y
                    }

                    for x in 0..<8 {
                        let xx = Int(sprite.x) + x
                        if xx >= 0 && xx < 160 && (!sprite.priority || scanLineRow[xx] == 0) {
                            let paletteIndex: PaletteIndex
                            if sprite.horizontalFlip {
                                paletteIndex = tiles[Int(sprite.tile)][tileRow][7 - x]
                            } else {
                                paletteIndex = tiles[Int(sprite.tile)][tileRow][x]
                            }

                            if paletteIndex > 0 {
                                frameBuffer[pixelOffset + x] = palette[Int(paletteIndex)]
                            }
                        }
                    }

                    count += 1
                    if count > 10 { break }
                }
            }
        }
    }

    func vblank() {
        gameboy.screen?.renderFrame(frameBuffer)
    }

    private func sprite(_ index: Int) -> Sprite {
        guard index < 40 else { fatalError("Invalid sprite index \(index)") }

        return Sprite(fromSlice: gameboy.objectAttributeRAM.getSlice(index: index << 2, length: 4))
    }

    struct Sprite {
        let x, y: Int
        let tile: Byte
        private let options: Byte

        init(fromSlice slice: Slice<[Byte]>) {
            guard slice.count == 4 else {
                fatalError("Invalid size slice for sprite \(slice.count)")
            }

            self.x = Int(slice[slice.startIndex]) - 8
            self.y = Int(slice[slice.startIndex + 1]) - 16
            self.tile = slice[slice.startIndex + 2]
            self.options = slice[slice.startIndex + 3]
        }

        var priority: Bool {
            return Byte.Bit._7.read(from: options)
        }

        var verticalFlip: Bool {
            return Byte.Bit._6.read(from: options)
        }

        var horizontalFlip: Bool {
            return Byte.Bit._5.read(from: options)
        }

        var palette: Bool {
            return Byte.Bit._4.read(from: options)
        }
    }

    // 0xFF40: LCDC
    struct LCDControl {
        var value: Byte = 0

        enum SpriteSize {
            case _8x8, _8x16
        }

        enum TileDataSelection {
            case High, Low
        }

        // Cinoop: BGENABLE
        // jsGB: bgon
        var bgDisplayEnable: Bool {
            return Byte.Bit._0.read(from: self.value)
        }

        // Cinoop: SPRITEENABLE
        // jsGB: objon
        var spriteDisplayEnable: Bool {
            return Byte.Bit._1.read(from: self.value)
        }

        // Cinoop: SPRITEVDOUBLE
        // jsGB: objsize
        var spriteSize: SpriteSize {
            return Byte.Bit._2.read(from: self.value) ? ._8x16 : ._8x8
        }

        // Cinoop: TILEMAP / mapOffset -- val ? 0x1c00 : 0x1800
        // jsGB: bgmapbase             -- (val & 0x08) ? 0x1C00 : 0x1800;
        var tileMap: Bool {
            return Byte.Bit._3.read(from: self.value)
        }

        var tileMapBaseAddress: Address {
            return tileMap ? 0x9c00 : 0x9800
        }

        // Cinoop: TILESET
        // jsGB: bgtilebase -- (val&0x10) ? 0x0000 : 0x0800
        var tileDataSelect: TileDataSelection {
            return Byte.Bit._4.read(from: self.value) ? .Low : .High
        }

        // Cinoop: WINDOWENABLE
        // jsGB:
        var windowEnable: Bool {
            return Byte.Bit._5.read(from: self.value)
        }

        // Cinoop: WINDOWTILEMAP
        // jsGB:
        var windowTileMap: Bool {
            return Byte.Bit._6.read(from: self.value)
        }

        // Cinoop: DISPLAYENABLE
        // jsGB: lcdon
        var lcdDisplayEnable: Bool {
            return Byte.Bit._7.read(from: self.value)
        }
    }
}
