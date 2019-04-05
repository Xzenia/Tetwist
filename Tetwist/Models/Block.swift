import SpriteKit

let NumberOfColors: UInt32 = 6

class Block: Hashable, CustomStringConvertible {
    
    let color: BlockColor
    
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    var spriteName: String {
        return color.spriteName
    }
    
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

func == (lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}

enum BlockColor: Int, CustomStringConvertible {
    
    case Blue = 0, Orange, Magenta, Scarlet, Aqua, Lime, Gray
    
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Magenta:
            return "magenta"
        case .Scarlet:
            return "scarlet"
        case .Aqua:
            return "aqua"
        case .Lime:
            return "lime"
        case .Gray:
            return "gray"
        }
    }
    
    var description: String {
        return self.spriteName
    }
    
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}



