//
//  GameViewController.swift
//  Gameboy iOS
//
//  Created by Brad Feehan on 7/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameboyViewController: UIViewController {
    private var gameboy = Gameboy()
    private let tetrisROM = #fileLiteral(resourceName: "Tetris (World) (Rev A).gb")

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try gameboy.load(rom: tetrisROM)
        } catch {
            let alert = UIAlertController(title: "Error", message: "Couldn't load Tetris ROM", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let skView = segue.destination.view as? SKView {
            let scene = GameboyScreen.newScene()
            gameboy.connect(to: scene)

            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true

            DispatchQueue.global(qos: .userInitiated).async {
                while true { self.gameboy.tick() }
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
