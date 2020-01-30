//
//  ScreenViewController.swift
//  Gameboy macOS
//
//  Created by Brad Feehan on 23/1/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ScreenViewController: NSViewController {
    weak var gameboy: Gameboy?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let gameboy = self.gameboy else {
            fatalError("No gameboy set on ScreenViewController")
        }

        let scene = GameboyScreen.newScene()
        gameboy.connect(to: scene)

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}

