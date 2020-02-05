//
//  SidebarView.swift
//  Gameboy macOS
//
//  Created by Brad Feehan on 29/1/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import AppKit

class SidebarView: NSView {
    @IBOutlet weak var pcLabel: NSTextField!
    @IBOutlet weak var spLabel: NSTextField!
    @IBOutlet weak var aLabel: NSTextField!
    @IBOutlet weak var fLabel: NSTextField!
    @IBOutlet weak var bLabel: NSTextField!
    @IBOutlet weak var cLabel: NSTextField!
    @IBOutlet weak var dLabel: NSTextField!
    @IBOutlet weak var eLabel: NSTextField!
    @IBOutlet weak var hLabel: NSTextField!
    @IBOutlet weak var lLabel: NSTextField!
    @IBOutlet weak var cpuTicksLabel: NSTextField!

    @IBOutlet weak var flagZLabel: NSTextField!
    @IBOutlet weak var flagNLabel: NSTextField!
    @IBOutlet weak var flagHLabel: NSTextField!
    @IBOutlet weak var flagCLabel: NSTextField!

    @IBOutlet weak var instructionLabel: NSTextField!

    @IBOutlet weak var gpuModeLabel: NSTextField!
    @IBOutlet weak var gpuScanLineLabel: NSTextField!
    @IBOutlet weak var gpuScrollXLabel: NSTextField!
    @IBOutlet weak var gpuScrollYLabel: NSTextField!
    @IBOutlet weak var gpuControlLabel: NSTextField!

    @IBOutlet weak var flagIMELabel: NSTextField!
    @IBOutlet weak var flagIEJoypadLabel: NSTextField!
    @IBOutlet weak var flagIESerialLabel: NSTextField!
    @IBOutlet weak var flagIETimerLabel: NSTextField!
    @IBOutlet weak var flagIELCDSTATLabel: NSTextField!
    @IBOutlet weak var flagIEVBlankLabel: NSTextField!
    @IBOutlet weak var flagIFJoypadLabel: NSTextField!
    @IBOutlet weak var flagIFSerialLabel: NSTextField!
    @IBOutlet weak var flagIFTimerLabel: NSTextField!
    @IBOutlet weak var flagIFLCDSTATLabel: NSTextField!
    @IBOutlet weak var flagIFVBlankLabel: NSTextField!

    @IBOutlet weak var timerEnabledLabel: NSTextField!
    @IBOutlet weak var timerFrequencyLabel: NSTextField!
    @IBOutlet weak var timerDIVLabel: NSTextField!
    @IBOutlet weak var timerTIMALabel: NSTextField!

    private let disassembler = Disassembler()

    weak var gameboy: Gameboy? {
        didSet { self.triggerUpdate() }
    }

    private var needsUpdate = false

    func triggerUpdate() {
        if !needsUpdate {
            DispatchQueue.main.async {
                self.needsUpdate = true
                self.needsDisplay = true
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        self.updateLabels()
        super.draw(dirtyRect)
        self.needsUpdate = false
    }

    private func updateLabels() {
        let cpu = gameboy?.cpu
        let registers = cpu?.registers

        self.pcLabel.stringValue = format(value: registers?.PC)
        self.spLabel.stringValue = format(value: registers?.SP)
        self.aLabel.stringValue = format(value: registers?.A)
        self.fLabel.stringValue = format(value: registers?.F)
        self.bLabel.stringValue = format(value: registers?.B)
        self.cLabel.stringValue = format(value: registers?.C)
        self.dLabel.stringValue = format(value: registers?.D)
        self.eLabel.stringValue = format(value: registers?.E)
        self.hLabel.stringValue = format(value: registers?.H)
        self.lLabel.stringValue = format(value: registers?.L)

        self.flagZLabel.textColor = color(for: registers?.get(flag: .Z))
        self.flagNLabel.textColor = color(for: registers?.get(flag: .N))
        self.flagHLabel.textColor = color(for: registers?.get(flag: .H))
        self.flagCLabel.textColor = color(for: registers?.get(flag: .C))

        self.flagIMELabel.textColor = color(for: cpu?.interruptsMaster)

        let interruptsEnabled = cpu?.interruptsEnabled
        self.flagIEJoypadLabel.textColor = color(for: interruptsEnabled?.joypad)
        self.flagIESerialLabel.textColor = color(for: interruptsEnabled?.serial)
        self.flagIETimerLabel.textColor = color(for: interruptsEnabled?.timer)
        self.flagIELCDSTATLabel.textColor = color(for: interruptsEnabled?.lcdstat)
        self.flagIEVBlankLabel.textColor = color(for: interruptsEnabled?.vblank)

        let interruptsFlags = cpu?.interruptsFlags
        self.flagIFJoypadLabel.textColor = color(for: interruptsFlags?.joypad)
        self.flagIFSerialLabel.textColor = color(for: interruptsFlags?.serial)
        self.flagIFTimerLabel.textColor = color(for: interruptsFlags?.timer)
        self.flagIFLCDSTATLabel.textColor = color(for: interruptsFlags?.lcdstat)
        self.flagIFVBlankLabel.textColor = color(for: interruptsFlags?.vblank)

        let timerControl = cpu?.timerControl
        self.timerEnabledLabel.textColor = color(for: timerControl?.timerStart)
        self.timerFrequencyLabel.stringValue = format(timerFrequency: timerControl?.frequency)
        self.timerDIVLabel.stringValue = format(value: cpu?.timerDivider)
        self.timerTIMALabel.stringValue = format(value: cpu?.timerCounter)

        let cycleCount = cpu?.cycleCount ?? 0
        self.cpuTicksLabel.stringValue = "\(cycleCount) / \(String(format: "0x%X", cycleCount))"
        self.instructionLabel.stringValue = format(operation: cpu?.fetch().0)

        let gpu = gameboy?.gpu
        self.gpuModeLabel.stringValue = format(gpuMode: gpu?.lcdStat.mode)

        let gpuScanlineHex = format(value: gpu?.scanLine, format: .Hexadecimal)
        let gpuScanlineDec = format(value: gpu?.scanLine, format: .Decimal)
        self.gpuScanLineLabel.stringValue = "\(gpuScanlineHex) / \(gpuScanlineDec)"

        self.gpuScrollXLabel.stringValue = format(value: gpu?.scrollX)
        self.gpuScrollYLabel.stringValue = format(value: gpu?.scrollY)
        self.gpuControlLabel.stringValue = format(value: gpu?.lcdControl.value)
    }

    private func color(for maybeFlag: Register.Set.Flag.Value?) -> NSColor {
        guard let flag = maybeFlag else { return NSColor.tertiaryLabelColor }

        return flag ? NSColor.labelColor : NSColor.tertiaryLabelColor
    }

    private func format(value maybeRegister: Register.Pair?, format: NumberFormat = .Hexadecimal) -> String {
        guard let register = maybeRegister else {
            return ""
        }

        switch format {
        case .Hexadecimal:
            return String(format: "0x%04X", register)
        case .Decimal:
            return String(format: "%d", register)
        }
    }

    private func format(value maybeRegister: Register?, format: NumberFormat = .Hexadecimal) -> String {
        guard let register = maybeRegister else {
            return ""
        }

        switch format {
        case .Hexadecimal:
            return String(format: "0x%02X", register)
        case .Decimal:
            return String(format: "%d", register)
        }
    }

    private func format(operation maybeOperation: Operation?) -> String {
        guard let operation = maybeOperation else {
            return ""
        }

        guard let disassembly = disassembler.disassemble(operation) else {
            return ""
        }

        return disassembly
    }

    private func format(timerFrequency maybeFrequency: CPU.TimerControl.Frequency?) -> String {
        guard let frequency = maybeFrequency else {
            return "--"
        }

        switch frequency {
        case ._4096Hz: return "4 KiHz"
        case ._16384Hz: return "16 KiHz"
        case ._65536Hz: return "64 KiHz"
        case ._262144Hz: return "256 KiHz"
        }
    }

    private func format(gpuMode maybeMode: GPU.LCDStat.Mode?) -> String {
        guard let mode = maybeMode else {
            return "--"
        }

        switch mode {
        case .HorizontalBlank: return "HBlank"
        case .VerticalBlank: return "VBlank"
        case .ObjectAttributeMemory: return "OAM"
        case .VideoRam: return "VRAM"
        }
    }

    private enum NumberFormat {
        case Hexadecimal, Decimal
    }
}
