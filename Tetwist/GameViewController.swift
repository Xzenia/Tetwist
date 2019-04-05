import UIKit
import SpriteKit

class GameViewController: UIViewController, TetrisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var tetris:Tetris!
    
    var panPointReference:CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        scene.tick = didTick
        
        tetris = Tetris()
        tetris.delegate = self
        tetris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.view.addGestureRecognizer(tapGesture)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        self.view.addGestureRecognizer(longTapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.view.addGestureRecognizer(panGesture)
        
    }
    
    func didTick() {
        tetris.letShapeFall()
    }

    
    func didTap(gesture: UITapGestureRecognizer) -> Void {
        tetris.rotateShape()
    }
    

    func didPan(gesture: UIPanGestureRecognizer) -> Void {
        let currentPoint = gesture.translation(in: self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                if gesture.velocity(in: self.view).x > CGFloat(0) {
                    tetris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    tetris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if gesture.state == .began {
            panPointReference = currentPoint
        }
    }
    
    func didLongPress(gesture: UILongPressGestureRecognizer) -> Void {
        tetris.dropShape()
    }
    

    func nextShape() {
        let newShapes = tetris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(Tetris tetris: Tetris) {
        
        scene.tickLengthMillis = TickLengthLevelOne
        if tetris.nextShape != nil && tetris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: tetris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(Tetris tetris: Tetris) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
        
        scene.animateCollapsingLines(linesToRemove: tetris.removeAllBlocks(), fallenBlocks: tetris.removeAllBlocks()) {
            tetris.beginGame()
        }
    }
    
    func gameDidLevelUp(Tetris tetris: Tetris) {
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
    }
    
    func gameShapeDidDrop(Tetris tetris: Tetris) {
        scene.stopTicking()
        scene.redrawShape(shape: tetris.fallingShape!) {
            tetris.letShapeFall()
        }
    }
    
    func gameShapeDidLand(Tetris tetris: Tetris) {
        scene.stopTicking()
        self.view.isUserInteractionEnabled = false

        let removedLines = tetris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                self.gameShapeDidLand(Tetris: tetris)
            }
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(Tetris tetris: Tetris) {
        scene.redrawShape(shape: tetris.fallingShape!) {}
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
