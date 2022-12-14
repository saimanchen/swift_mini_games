import Foundation

struct Player {
    var name: String
    var isTurn: Bool
    var score: Int
    var isComputer: Bool
    
    init(name: String, isTurn: Bool, score: Int, isComputer: Bool) {
        self.name = name
        self.isTurn = isTurn
        self.score = score
        self.isComputer = isComputer
    }
}
