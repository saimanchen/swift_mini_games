import UIKit

class MemoryViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPlayer1ScoreName: UILabel!
    @IBOutlet weak var lblPlayer2ScoreName: UILabel!
    @IBOutlet weak var lblPlayer1Pairs: UILabel!
    @IBOutlet weak var lblPlayer2Pairs: UILabel!
    @IBOutlet weak var lblPlayer1Score: UILabel!
    @IBOutlet weak var lblPlayer2Score: UILabel!
    @IBOutlet weak var btnResetPlayAgain: UIButton!
    @IBOutlet var UIButtons: [UIButton]!
    
    // values received from MemoryFormViewController
    var receivingName1: String?
    var receivingName2: String?
    var isComputerGame: Bool = false
    
    var game: MemoryGame = MemoryGame(player1: Player(name: "Player 1", isTurn: true, score: 0, isComputer: false), player2: Player(name: "Player 2", isTurn: false, score: 0, isComputer: false))
    
    var shuffledCellArray: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets all labels with player names
        if let receivingName1 = receivingName1,
           let receivingName2 = receivingName2 {
            game.player1.name = receivingName1
            game.player2.name = receivingName2
            lblName.text = game.player1.name
            lblPlayer1ScoreName.text = game.player1.name
            lblPlayer2ScoreName.text = game.player2.name

            shuffledCellArray = game.shuffleCells()
        }
    }
    
    @IBAction func onPress(_ sender: UIButton) {
        let tag = sender.tag
        
        cellOnPress(tag: tag)
    }
    
    @IBAction func btnResetPlayAgain(_ sender: Any) {
        resetAllButtons()
        shuffledCellArray = game.shuffleCells()
        game.isGameStarted = false
        game.matchingPairs = 0
        game.player1MatchingPairs = 0
        game.player2MatchingPairs = 0
        game.chosenCells = []
        game.firstTag = nil
        lblTitle.text = "Turn to play:"
        lblName.text = getPlayerName(isPlayerTurn: game.isPlayerTurn, name1: game.player1.name, name2: game.player2.name)
        lblPlayer1Pairs.text = String(game.player1MatchingPairs)
        lblPlayer2Pairs.text = String(game.player2MatchingPairs)
    }
    
    func cellOnPress(tag: Int) {
        if game.chosenCells.count == 0 {
            game.firstTag = tag
        }
        
        // opens the cell and gets the image
        UIButtons[tag].setImage(getImage(tag: tag), for: .normal)
        
        if game.chosenCells.count < 2 {
            game.chosenCells.append(shuffledCellArray[tag])
        }
        
        if game.chosenCells.count == 2 {
            game.isAMatch = game.isAMatch(array: game.chosenCells)
        }
        
        if game.isAMatch && game.chosenCells.count == 2 {
            UIButtons[tag].isUserInteractionEnabled = false
            UIButtons[game.firstTag ?? -1].isUserInteractionEnabled = false
            game.chosenCells = []
            game.updatePlayerPairs(isPlayerTurn: game.isPlayerTurn)
            lblPlayer1Pairs.text = String(game.player1MatchingPairs)
            lblPlayer2Pairs.text = String(game.player2MatchingPairs)
            game.updateMatchingPairs()
            game.isAMatch = false
        } else if !game.isAMatch && game.chosenCells.count == 2 {
            delayTimerToggleBack(firstTag: game.firstTag ?? -1, tag: tag)
            game.chosenCells = []
            game.isPlayerTurn = game.switchTurn(isPlayerTurn: game.isPlayerTurn)
            delayTimerChangeName()
        }
        
        if game.matchingPairs == 10 {
            endGame()
        }
    }
    
    func getImage(tag: Int) -> UIImage {
        let image = self.shuffledCellArray[tag]
        return UIImage(named: image) ?? UIImage(named: "memory_blank")!
    }
    
    func delayTimerToggleBack(firstTag: Int, tag: Int) {
        _ = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false
        ) { timer in
            self.toggleBackToBlank(firstTag: firstTag, tag: tag)
        }
    }
    
    func delayTimerChangeName() {
        _ = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false
        ) { timer in
            self.lblName.text = self.getPlayerName(isPlayerTurn: self.game.isPlayerTurn, name1: self.game.player1.name, name2: self.game.player2.name)        }
    }
    
    func toggleBackToBlank(firstTag: Int, tag: Int) {
        UIButtons[firstTag].setImage(UIImage(named: "memory_blank"), for: .normal)
        UIButtons[tag].setImage(UIImage(named: "memory_blank"), for: .normal)
    }
    
    func getPlayerName(isPlayerTurn: Array<Bool>, name1: String, name2: String) -> String {
        if game.isPlayerTurn[0] {
            return name1
        } else if game.isPlayerTurn[1] {
            return name2
        }
        return "Error"
    }
    
    func endGame() {
        let result = game.checkWinnerDraw()
        
        switch result {
        case 1:
            lblTitle.text = "Winner:"
            lblName.text = game.player1.name
            break
        case 2:
            lblTitle.text = "Winner:"
            lblName.text = game.player2.name
            break
        case 3:
            lblTitle.text = ""
            lblName.text = "Draw"
            break
        default: break
        }
        
        game.updatePlayerScore(result: result)
        lblPlayer1Score.text = String(game.player1.score)
        lblPlayer2Score.text = String(game.player2.score)
        btnResetPlayAgain.setImage(UIImage(named: "play_again"), for: .normal)
    }
    
    func resetAllButtons() {
        for button in UIButtons {
            button.isUserInteractionEnabled = true
            button.setImage(UIImage(named: "memory_blank"), for: .normal)
        }
    }
}
