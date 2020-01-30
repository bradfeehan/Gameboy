//
//  Memory.swift
//  Gameboy
//
//  Created by Brad Feehan on 9/11/19.
//  Copyright © 2019 Brad Feehan. All rights reserved.
//

struct Memory {
    private var data: [Byte]
    private let capacity: Address
    private let offset: Address

    init(capacity: Address, offset: Address = 0x0000, initialValue: Optional<[Byte]> = nil) {
        self.capacity = capacity
        self.offset = offset

        if let data = initialValue {
            self.data = data
        } else {
            self.data = Array<Byte>(repeating: 0x00, count: Int(self.capacity))
        }
    }

    mutating func reset() {
        self.data = Array<Byte>(repeating: 0x00, count: Int(self.capacity))
    }

    mutating func reset(to data: [Byte]) {
        self.data = data
    }

    subscript(address: Address) -> Byte? {
        get {
            return self.data[index(for: address)]
        }
        set(newValue) {
            if let unwrappedValue = newValue {
                self.data[self.index(for: address)] = unwrappedValue
            }
        }
    }

    func getSlice(index: Int, length: Int) -> Slice<[Byte]> {
        return self.data[index..<(index + length)]
    }

    private func index(for address: Address) -> Int {
        Int(address - self.offset)
    }
}
