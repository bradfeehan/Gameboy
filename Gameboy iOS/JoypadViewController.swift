//
//  JoypadViewController.swift
//  Gameboy iOS
//
//  Created by Brad Feehan on 6/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import UIKit

class JoypadViewController: UIViewController {
    weak var gameboy: Gameboy?

    @IBAction func buttonTouchDown(_ sender: UIButton) {
        self.buttonState(true, sender)
    }

    @IBAction func buttonTouchUp(_ sender: UIButton) {
        self.buttonState(false, sender)
    }

    private func buttonState(_ state: Bool, _ sender: UIButton) {
        guard let gameboy = self.gameboy else { return }

        switch sender.tag {
        case 123: gameboy.joypad.left = state
        case 124: gameboy.joypad.right = state
        case 125: gameboy.joypad.down = state
        case 126: gameboy.joypad.up = state
        case 0:   gameboy.joypad.a = state
        case 45:  gameboy.joypad.b = state
        case 36:  gameboy.joypad.start = state
        case 49:  gameboy.joypad.select = state
        default: break
        }
    }
}
