//
//  SidebarViewController.swift
//  Gameboy macOS
//
//  Created by Brad Feehan on 11/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//


import Cocoa
import SpriteKit
import GameplayKit

class SidebarViewController: NSViewController {
    weak var gameboy: Gameboy?
    private weak var sidebarView: SidebarView!

    private var liveUpdate = true

    private var liveUpdateCheckBoxChecked: Bool {
        get { self.liveUpdateCheckBox.state == .on }
        set { self.liveUpdateCheckBox.state = newValue ? .on : .off }
    }

    @IBOutlet weak var tickStepTextBox: NSTextField!
    @IBOutlet weak var breakpointTextField: NSTextFieldCell!

    private func tick(_ gameboy: Gameboy) {
        gameboy.tick()
        if liveUpdate { sidebarView.triggerUpdate() }
    }

    @IBOutlet weak var liveUpdateCheckBox: NSButton!
    @IBAction func liveUpdateCheckBoxAction(_ sender: Any) {
        self.liveUpdate = self.liveUpdateCheckBoxChecked
    }

    // - MARK: Reset

    @IBOutlet weak var resetButton: NSButton!
    @IBAction func resetButtonAction(_ sender: NSButton) {
        guard !running && !ticking else { return }
        gameboy?.reset()
        self.sidebarView.triggerUpdate()
    }

    // - MARK: Run
    @IBOutlet weak var runButton: NSButtonCell!
    var running: Bool = false {
        willSet {
            runButton.state = newValue ? .on : .off
            tickButton.isEnabled = !newValue
            resetButton.isEnabled = !newValue
        }
    }

    @IBAction func runButtonAction(_ sender: NSButton) {
        guard let gameboy = self.gameboy else { return }
        guard !ticking else { return }

        if running {
            self.running = false
            return
        }

        self.running = true

        let maybeBreakpoint = self.breakpoint()
        let hasBreakpoint = maybeBreakpoint != nil

        DispatchQueue.global(qos: .userInitiated).async {
            while self.running {
                self.tick(gameboy)

                if hasBreakpoint {
                    if let breakpoint = maybeBreakpoint {
                        if breakpoint == gameboy.cpu.registers.PC { break }
                    }
                }
            }

            DispatchQueue.main.async { self.running = false }
            self.sidebarView.triggerUpdate()
        }
    }

    // - MARK: Tick
    @IBOutlet weak var tickButton: NSButton!
    var ticking: Bool = false {
        willSet {
            tickButton.state = newValue ? .on : .off
            runButton.isEnabled = !newValue
            resetButton.isEnabled = !newValue
        }
    }

    @IBAction func tickButtonAction(_ sender: NSButton) {
        guard let gameboy = self.gameboy else { return }
        guard !running else { return }

        if ticking {
            self.ticking = false
            return
        }

        self.ticking = true

        let ticks = self.tickStepTextBox.integerValue
        let maybeBreakpoint = self.breakpoint()

        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 0..<ticks {
                guard self.ticking else { break }

                self.tick(gameboy)

                if let breakpoint = maybeBreakpoint {
                    if breakpoint == gameboy.cpu.registers.PC { break }
                }
            }

            DispatchQueue.main.async { self.ticking = false }
            self.sidebarView.triggerUpdate()
        }
    }

    override func viewDidLoad() {
        self.sidebarView = self.view as? SidebarView

        guard self.sidebarView != nil else {
            fatalError("Requires SidebarView")
        }

        self.sidebarView?.gameboy = self.gameboy
    }

    private func breakpoint() -> Address? {
        let stringValue = self.breakpointTextField.stringValue.replacingOccurrences(of: "0x", with: "")

        guard let integerValue = Int(stringValue, radix: 16) else { return nil }
        guard integerValue >= 0 && integerValue <= 0xFFFF else { return nil }

        return Address(integerValue)
    }
}
