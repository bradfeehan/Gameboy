//
//  Joypad.swift
//  Gameboy
//
//  Created by Brad Feehan on 6/2/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

class Joypad {
    var up = false, down = false, left = false, right = false, a = false, b = false, select = false, start = false

    enum Selection {
        case Directions
        case Buttons
    }

    func write(selection: Selection, to byte: inout Byte) {
        switch selection {
        case .Buttons:
            Byte.Bit._0.write(!a, to: &byte)
            Byte.Bit._1.write(!b, to: &byte)
            Byte.Bit._2.write(!select, to: &byte)
            Byte.Bit._3.write(!start, to: &byte)
        case .Directions:
            Byte.Bit._0.write(!right, to: &byte)
            Byte.Bit._1.write(!left, to: &byte)
            Byte.Bit._2.write(!up, to: &byte)
            Byte.Bit._3.write(!down, to: &byte)
        }
    }
}
