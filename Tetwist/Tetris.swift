 protocol TetrisDelegate {
    
    func gameDidEnd(Tetris: Tetris)
    
    func gameDidBegin(Tetris: Tetris)
    
    func gameShapeDidLand(Tetris: Tetris)
    
    func gameShapeDidMove(Tetris: Tetris)
    
    func gameShapeDidDrop(Tetris: Tetris)
    
    func gameDidLevelUp(Tetris: Tetris)
 }
 
 
 class Tetris {
    
    static let NumColumns = 10
    static let NumRows = 20
    static let StartingColumn = 4
    static let StartingRow = 0
    static let PreviewColumn = 12
    static let PreviewRow = 1
    
    static let PointsPerLine = 10
    static let LevelThreshold = 500
    
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:TetrisDelegate?
    
    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: Tetris.NumColumns, rows: Tetris.NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(startingColumn: Tetris.PreviewColumn, startingRow: Tetris.PreviewRow)
        }
        delegate?.gameDidBegin(Tetris: self)
    }
    
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: Tetris.PreviewColumn, startingRow: Tetris.PreviewRow)
        fallingShape?.moveTo(column: Tetris.StartingColumn, row: Tetris.StartingRow)
        
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(column: Tetris.PreviewColumn, row: Tetris.PreviewRow)
            endGame()
            return (nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= Tetris.NumColumns
                || block.row < 0 || block.row >= Tetris.NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(Tetris: self)
    }
    
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(Tetris: self)
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(Tetris: self)
    }
    
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(Tetris: self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(Tetris: self)
    }
    
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(Tetris: self)
    }
    
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == Tetris.NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(Tetris: self)
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<Tetris.NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<Tetris.NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for row in (1..<Tetris.NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            // #11
            for column in 0..<Tetris.NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            if rowOfBlocks.count == Tetris.NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // #12
        if removedLines.count == 0 {
            return ([], [])
        }
        // #13
        let pointsEarned = removedLines.count * Tetris.PointsPerLine * level
        score += pointsEarned
        if score >= level * Tetris.LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(Tetris: self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<Tetris.NumColumns {
            var fallenBlocksArray = Array<Block>()
            // #14
            for row in (1..<removedLines[0][0].row).reversed() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                while (newRow < Tetris.NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
 }
