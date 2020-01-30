//
//  GameboyScreen.swift
//  Gameboy
//
//  Created by Brad Feehan on 23/1/20.
//  Copyright © 2020 Brad Feehan. All rights reserved.
//

import SpriteKit

class GameboyScreen: SKScene, SKSceneDelegate {
    var frameBuffer: [UInt32] = [UInt32](repeating: GPU.PALETTE[0], count: 160 * 144)
    var frameBufferDirty = true
    weak var screenNode: SKSpriteNode?
    private let texture: SKMutableTexture = GameboyScreen.createTexture()

    private class func createTexture() -> SKMutableTexture {
        let texture = SKMutableTexture(size: CGSize(width: 160, height: 144))
        texture.filteringMode = .nearest
        return texture
    }

    class func newScene() -> GameboyScreen {
        // Load 'GameboyScreen.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameboyScreen") as? GameboyScreen else {
            fatalError("Failed to load GameboyScreen.sks")
        }

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.delegate = scene

        return scene
    }

    func reset() {
        self.frameBuffer = [UInt32](repeating: GPU.PALETTE[0], count: 160 * 144)
        self.frameBufferDirty = true
    }

    func setUpScene() {
        guard let node = self.childNode(withName: "//Screen") else {
            fatalError("Failed to get screenNode from scene")
        }

        guard let screenNode = node as? SKSpriteNode else {
            fatalError("Failed to set texture on screenNode")
        }

        screenNode.texture = self.texture

        self.screenNode = screenNode
    }

    func renderFrame(_ frameBuffer: [UInt32]) {
        self.frameBuffer = frameBuffer
        self.frameBufferDirty = true
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        guard self.frameBufferDirty else { return }

        self.texture.modifyPixelData { (pointer: UnsafeMutableRawPointer?, lengthInBytes: Int) in
            let textureCount = lengthInBytes / MemoryLayout<UInt32>.stride

            guard textureCount == self.frameBuffer.count else {
                fatalError("Framebuffer length mismatch with texture buffer size -- texture = \(textureCount), frameBuffer: \(self.frameBuffer.count)")
            }

            guard let pixels = pointer?.bindMemory(to: UInt32.self, capacity: textureCount) else { return }

            for textureIndex in 0..<textureCount {
                let row = textureIndex / 160
                let column = textureIndex % 160

                let bufferIndex = textureCount - (row + 1) * 160 + column
                pixels[textureIndex] = self.frameBuffer[bufferIndex]
            }
        }

        self.frameBufferDirty = false
    }

    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif
}
