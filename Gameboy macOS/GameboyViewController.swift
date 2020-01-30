//
//  GameboyViewController.swift
//  Gameboy macOS
//
//  Created by Brad Feehan on 11/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//



import Cocoa
import SpriteKit
import GameplayKit

class GameboyViewController: NSViewController {
    private weak var sidebarViewController: SidebarViewController?
    private weak var screenViewController: ScreenViewController?

    private var gameboy = Gameboy()

    @IBAction func openDocument(_ sender: Any) {
        if let sidebarViewController = self.sidebarViewController {
            guard !sidebarViewController.running else { return }
            guard !sidebarViewController.ticking else { return }
        }

        guard let window = self.view.window else {
            fatalError("Couldn't find window")
        }

        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["gb"]
        panel.beginSheetModal(for: window) { (modalResponse) in
            guard modalResponse == .OK else { return }
            guard let url = panel.url else { return }

            do {
                try self.gameboy.load(rom: url)
            } catch {
                // do nothing
            }
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let sidebarViewController = segue.destinationController as? SidebarViewController {
            self.sidebarViewController = sidebarViewController
            sidebarViewController.gameboy = self.gameboy
        }

        if let screenViewController = segue.destinationController as? ScreenViewController {
            self.screenViewController = screenViewController
            screenViewController.gameboy = self.gameboy
        }
    }
}

