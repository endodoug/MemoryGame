//
//  GameScene.swift
//  MemoryGame
//
//  Created by doug harper on 3/18/15.
//  Copyright (c) 2015 Doug Harper. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene, GKGameCenterControllerDelegate {
    
    var buttonPlay : SKSpriteNode!
    var buttonLeaderboard : SKSpriteNode!
    var buttonRate : SKSpriteNode!
    var title : SKSpriteNode!
    
    let cardsPerRow : Int = 4
    let cardsPerColumn : Int = 5
    let cardSizeX : CGFloat = 50
    let cardSizeY : CGFloat = 50
    
    let scorePanelAndAdvertisingHeight : CGFloat = 150
    
    var cards : [SKSpriteNode] = []
    var cardsBacks : [SKSpriteNode] = []
    var cardStatus : [Bool] = []
    
    let numberOfTypesOfCards : Int = 26
    
    var cardsSequence : [Int] = []
    
    var selectedCardIndex1 : Int = -1
    var selectedCardValue1 : String = ""
    
    var selectedCardIndex2 : Int = -1
    var selectedCardValue2 : String = ""
    
    var gameIsPlaying : Bool = false
    var lockedInteraction : Bool = false
    
    var scoreboard : SKSpriteNode!
    
    var tryCountCurrent : Int = 0
    var tryCountBest : Int!
    
    var tryCountCurrentLabel : SKLabelNode!
    var tryCountBestLabel : SKLabelNode!
    
    var DEBUG_MODE_ON : Bool = true
    var DelayPriorToHidingCards : NSTimeInterval =  1.5
    
    var finishedFlag : SKSpriteNode!
    
    var buttonReset : SKSpriteNode!
    
    var soundActionButton : SKAction!
    var soundActionMatch : SKAction!
    var soundActionNoMatch : SKAction!
    var soundActionWin : SKAction!
    
    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String()
    var LeaderboardID = ""
    
    override func didMoveToView(view: SKView) {
        
        setupScenery()
        
        createMenu()
        
        createScoreboard()
        HideScoreboard()
        
        CreateFinishedFlag()
        HideFinishedFlag()
        
        setUpAudio()
        
        if(DEBUG_MODE_ON == true) {
            DelayPriorToHidingCards = 0.15
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
       
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        // let touchLocation = touch.locationInNode(self)
        
        var positionInScene : CGPoint = touch.locationInNode(self)
        var touchedNode : SKSpriteNode = self.nodeAtPoint(positionInScene) as SKSpriteNode
        
        self.processItemTouch(touchedNode)
        
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func setupScenery() {
        
        let background = SKSpriteNode(imageNamed: BackgroundImage)
        background.anchorPoint = CGPointMake(0, 1)
        background.position = CGPointMake(0, size.height)
        background.zPosition = 0
        background.size = CGSize(width: self.view!.bounds.size.width, height: self.view!.bounds.size.height)
        addChild(background)
    }
    
    func createMenu() {
        
        var offsetY : CGFloat = 3.0
        var offsetX : CGFloat = 5.0
        
        buttonRate = SKSpriteNode(imageNamed: buttonRateImage)
        buttonRate.position = CGPointMake(size.width / 2, size.height / 2 + buttonRate.size.height + offsetY)
        buttonRate.zPosition = 10
        buttonRate.name = "rate"
        addChild(buttonRate)
        
        buttonPlay = SKSpriteNode(imageNamed: buttonPlayImage)
        buttonPlay.position = CGPointMake(size.width / 2 - offsetX - buttonPlay.size.width / 2, size.height / 2 )
        buttonPlay.zPosition = 10
        buttonPlay.name = "play"
        addChild(buttonPlay)
        
        buttonLeaderboard = SKSpriteNode(imageNamed: buttonLeaderBoardImage)
        buttonLeaderboard.position = CGPointMake(size.width / 2 + offsetX + buttonLeaderboard.size.width / 2, size.height / 2 )
        buttonLeaderboard.zPosition = 10
        buttonLeaderboard.name = "leaderboard"
        addChild(buttonLeaderboard)
        
        title = SKSpriteNode(imageNamed: titleImage)
        title.position = CGPointMake(size.width / 2, buttonRate.position.y + buttonRate.size.height / 2 + title.size.height / 2 + offsetY)
        title.zPosition = 10
        title.name = "title"
        title.setScale(0.6)
        addChild(title)
    }
    
    func showMenu() {
        var duration : NSTimeInterval = 0.5
        buttonPlay.runAction(SKAction.fadeAlphaTo(1, duration: duration))
        buttonLeaderboard.runAction(SKAction.fadeAlphaTo(1, duration: duration))
        buttonRate.runAction(SKAction.fadeAlphaTo(1, duration: duration))
        title.runAction(SKAction.fadeAlphaTo(1, duration: duration))
    }
    
    func hideMenu() {
        var duration : NSTimeInterval = 0.5
        buttonPlay.runAction(SKAction.fadeAlphaTo(0, duration: duration))
        buttonLeaderboard.runAction(SKAction.fadeAlphaTo(0, duration: duration))
        buttonRate.runAction(SKAction.fadeAlphaTo(0, duration: duration))
        title.runAction(SKAction.fadeAlphaTo(0, duration: duration))
    }
    
    func processItemTouch(nod : SKSpriteNode) {
        
        if(gameIsPlaying == false) {
            if (nod.name == "play") {
                println("play button")
                hideMenu()
                createCardsSequence()
                ResetCardStatus()
                createCardBoard()
                gameIsPlaying = true
                PlaceScoreboardAboveCards()
                ShowScoreboard()
                HideFinishedFlag()
                runAction(soundActionButton)
            } else if (nod.name == "leaderboard") {
            println("leaderboard button")
                runAction(soundActionButton)
            } else if (nod.name == "rate") {
                println("rate button")
                runAction(soundActionButton)
            }
        } else {
            // game is playing
            
            if(nod.name == "reset"){
                ResetGame()
                runAction(soundActionButton)
            }
            var num = nod.name?.toInt()
            if (num != nil) // it is a number 
            {
                if (num > 0) {
                    if(lockedInteraction == true) {
                        return
                    } else {
                        println("card with number \(num) was touched.")
                        for (var i : Int = 0; i < cardsBacks.count; i++) {
                            var cardBack : SKSpriteNode = cardsBacks[i] as SKSpriteNode
                            if(cardBack === nod) {
                                runAction(soundActionButton)
                                // the nod is identical to the cardBack at index i
                                var cardNode : SKSpriteNode = cards[i] as SKSpriteNode
                                if (selectedCardIndex1 == -1) {
                                    selectedCardIndex1 = i
                                    selectedCardValue1 = cardNode.name!
                                    cardBack.runAction(SKAction.hide())
                                    
                                } else if (selectedCardIndex2 == -1) {
                                    if(i != selectedCardIndex1) {
                                        lockedInteraction = true
                                        selectedCardIndex2 = i
                                        selectedCardValue2 = cardNode.name!
                                        cardBack.runAction(SKAction.hide())
                                        
                                        // at this point we compare the 2 cards for a match.
                                        if(selectedCardValue1 == selectedCardValue2 || DEBUG_MODE_ON == true) {
                                            println("we have a match")
                                            NSTimer.scheduledTimerWithTimeInterval(DelayPriorToHidingCards, target: self, selector: Selector("HideSelectedCards"), userInfo: nil, repeats: false)
                                            
                                            setStatusCardFound(selectedCardIndex1)
                                            setStatusCardFound(selectedCardIndex2)
                                            runAction(soundActionMatch)
                                            if(CheckIfGameOver() == true) {
                                                gameIsPlaying = false
                                                showMenu()
                                                runAction(soundActionWin)
                                                PlaceScoreboardBelowPlayButton()
                                                SaveBestTryCount()
                                                ShowFinishedFlag()
                                                buttonReset.hidden = true
                                            }
                                            
                                        } else {
                                            println("no match")
                                            NSTimer.scheduledTimerWithTimeInterval(DelayPriorToHidingCards, target: self, selector: ("resetSelectedCards"), userInfo: nil, repeats: false)
                                            
                                            runAction(soundActionNoMatch)
                                            
                                            IncreaseTryCount()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func createCardBoard() {
        
        var totalEmptySpaceX : CGFloat = self.size.width - ( CGFloat(cardsPerRow + 1) ) * cardSizeX
        var offsetX : CGFloat = totalEmptySpaceX / ( CGFloat(cardsPerRow) + 2 )
        
        var totalEmptySpaceY : CGFloat = self.size.height - scorePanelAndAdvertisingHeight - ( CGFloat(cardsPerColumn + 1) ) * cardSizeY
        var offsetY : CGFloat = totalEmptySpaceY / ( CGFloat(cardsPerColumn) + 2 )
        
        var idx : Int = 0
        for i in 0...cardsPerRow {
            
            for j in 0...cardsPerColumn {
            
                var cardIndex : Int = cardsSequence[idx++] // todo- fill the cardSequence array!
                var cardName : String = String(format: "card-%i", cardIndex)
                var card : SKSpriteNode = SKSpriteNode(imageNamed: cardName)
                card.size = CGSizeMake(cardSizeX, cardSizeY)
                card.anchorPoint = CGPointMake(0, 0)
                
                var posX : CGFloat = offsetX + CGFloat(i) * card.size.width + offsetX * CGFloat(i)
                var posY : CGFloat = offsetY + CGFloat(j) * card.size.height  + offsetY * CGFloat(j)
                
                card.position = CGPointMake(posX, posY)
                card.zPosition = 9
                card.name = String(format: "%i", cardIndex)
                addChild(card)
                cards.append(card)
                
                var cardBack : SKSpriteNode = SKSpriteNode(imageNamed: "card-back")
                cardBack.size = CGSizeMake(cardSizeX, cardSizeY)
                cardBack.anchorPoint = CGPointMake(0, 0)
                cardBack.zPosition = 10
                cardBack.position = CGPointMake(posX, posY)
                cardBack.name = String(format: "%i", cardIndex)
                addChild(cardBack)
                cardsBacks.append(cardBack)
        
            }
        
        }
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        
        let count = countElements(list)
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
        
    }
    
    func createCardsSequence() {
        
        var totalCards : Int = (cardsPerRow + 1) * (cardsPerColumn + 1) / 2
        for i in 1...(totalCards) {
            cardsSequence.append(i)
            cardsSequence.append(i)
        }
        
        let newSequence = shuffle(cardsSequence)
        cardsSequence.removeAll(keepCapacity: false)
        cardsSequence += newSequence
        
    }
    
    func HideSelectedCards() {
        var card1 : SKSpriteNode = cards[selectedCardIndex1] as SKSpriteNode
        var card2 : SKSpriteNode = cards[selectedCardIndex2] as SKSpriteNode
        
        card1.runAction(SKAction.hide())
        card2.runAction(SKAction.hide())
        
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
        lockedInteraction = false
        
    }
    
    func setStatusCardFound(cardIndex : Int) {
        cardStatus[cardIndex] = true
    }
    
    func ResetCardStatus() {
        for i in 0...(cardsSequence.count - 1) {
            cardStatus.append(false)
        }
    }
    
    func resetSelectedCards () {
        var card1 : SKSpriteNode = cardsBacks[selectedCardIndex1] as SKSpriteNode
        var card2 : SKSpriteNode = cardsBacks[selectedCardIndex2] as SKSpriteNode
        
        card1.runAction(SKAction.unhide())
        card2.runAction(SKAction.unhide())
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
        lockedInteraction = false
    }

    func createScoreboard() {
        scoreboard = SKSpriteNode(imageNamed: "scoreboard")
        scoreboard.position = CGPointMake(size.width / 2, size.height - 50 - scoreboard.size.height / 2)
        scoreboard.zPosition = 1
        scoreboard.name = "scoreboard"
        addChild(scoreboard)
        
        tryCountCurrentLabel = SKLabelNode(fontNamed: fontName)
        tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
        tryCountCurrentLabel?.fontSize = 30
        tryCountCurrentLabel?.fontColor = SKColor.whiteColor()
        tryCountCurrentLabel?.zPosition = 11
        tryCountCurrentLabel?.position = CGPointMake(scoreboard.position.x, scoreboard.position.y + 10)
        addChild(tryCountCurrentLabel)
        
        // todo: get the best score from storage (NSUserDefault)
        tryCountBest = NSUserDefaults.standardUserDefaults().integerForKey("besttrycount") as Int
        
        tryCountBestLabel = SKLabelNode(fontNamed: fontName)
        tryCountBestLabel?.text = "Best: \(tryCountBest)"
        tryCountBestLabel?.fontSize = 30
        tryCountBestLabel?.fontColor = SKColor.whiteColor()
        tryCountBestLabel?.zPosition = 11
        tryCountBestLabel?.position = CGPointMake(tryCountCurrentLabel.position.x, tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
        addChild(tryCountBestLabel)
        
        buttonReset = SKSpriteNode(imageNamed: buttonRestartImage)
        buttonReset.position = CGPointMake(scoreboard.position.x + scoreboard.size.width / 2 - buttonReset.size.width / 2, scoreboard.position.y - buttonReset.size.height / 3)
        buttonReset.name = "reset"
        buttonReset.zPosition = 11
        buttonReset.setScale(0.5)
        addChild(buttonReset)
        buttonReset.hidden = true
        
    }

    func HideScoreboard() {
        scoreboard.hidden = true
        tryCountBestLabel.hidden = true
        tryCountCurrentLabel.hidden = true
        buttonReset.hidden = true
    }
    
    func ShowScoreboard() {
        scoreboard.hidden = false
        tryCountBestLabel.hidden = false
        tryCountCurrentLabel.hidden = false
        buttonReset.hidden = false
        
        if(tryCountBest == nil  || tryCountBest == 0) {
            tryCountBestLabel.hidden = true
        }
    }
    
    func CheckIfGameOver() -> Bool {
        var gameOver : Bool = true
        for i : Int in 0...(cardStatus.count - 1) {
            if (cardStatus[i] as Bool == false) {
                gameOver = false
                break
            }
        }
        return gameOver
    }
    
    func PlaceScoreboardBelowPlayButton() {
        scoreboard.position = CGPointMake(size.width / 2, buttonPlay.position.y - scoreboard.size.height)
        tryCountCurrentLabel?.position = CGPointMake(scoreboard.position.x, scoreboard.position.y + 10)
        tryCountBestLabel?.position = CGPointMake(tryCountCurrentLabel.position.x, tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
        tryCountBestLabel.hidden = false
    }
    
    func PlaceScoreboardAboveCards() {
        scoreboard.position = CGPointMake(size.width / 2, size.height - 50 - scoreboard.size.height / 2)
        tryCountCurrentLabel?.position = CGPointMake(scoreboard.position.x, scoreboard.position.y + 10)
        tryCountBestLabel?.position = CGPointMake(tryCountCurrentLabel.position.x, tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
    }
    
    func SaveBestTryCount() {
        if(tryCountBest == nil || tryCountBest == 0 || tryCountCurrent < tryCountBest) {
            tryCountBest = tryCountCurrent
            NSUserDefaults.standardUserDefaults().setInteger(tryCountBest, forKey: "besttrycount")
            NSUserDefaults.standardUserDefaults().synchronize()
            tryCountBestLabel?.text = "Best: \(tryCountBest)"
            // todo: submit score to Game Center
        }
    }
    
    func CreateFinishedFlag() {
        finishedFlag = SKSpriteNode(imageNamed: finishedFlagImage)
        finishedFlag.size = CGSizeMake(cardSizeX, cardSizeY)
        finishedFlag.anchorPoint = CGPointMake(0, 0)
        finishedFlag.position = CGPointMake(size.width / 2, scoreboard.position.y - scoreboard.size.height / 2 - finishedFlag.size.height / 2)
        finishedFlag.zPosition = 11
        finishedFlag.name = "finishedFlag"
        addChild(finishedFlag)
        finishedFlag.hidden = true
    }
    
    func ShowFinishedFlag() {
        finishedFlag.position = CGPointMake(size.width / 2, scoreboard.position.y - scoreboard.size.height / 2 - finishedFlag.size.height / 2)
        finishedFlag.hidden = false
    }
    
    func HideFinishedFlag() {
        finishedFlag.hidden = true
    }
    
    func IncreaseTryCount() {
        tryCountCurrent = tryCountCurrent + 1
        tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
    }
    
    func ResetGame() {
        runAction(soundActionButton)
        removeALLCards()
        PlaceScoreboardAboveCards()
        ShowScoreboard()
        createCardsSequence()
        createCardBoard()
        ResetCardStatus()
        tryCountCurrent = 0
        tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
        finishedFlag.hidden = true
    }
    
    func removeALLCards() {
        for card in cards {
            card.removeFromParent()
        }
        for card in cardsBacks {
            card.removeFromParent()
        }
        cards.removeAll(keepCapacity: false)
        cardsBacks.removeAll(keepCapacity: false)
        cardStatus.removeAll(keepCapacity: false)
        cardsSequence.removeAll(keepCapacity: false)
        
        selectedCardValue1 = ""
        selectedCardValue2 = ""
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
    }
    
    func setUpAudio() {
        soundActionButton = SKAction.playSoundFileNamed(soundButtonFile, waitForCompletion: false)
        soundActionMatch = SKAction.playSoundFileNamed(soundMatchFile, waitForCompletion: false)
        soundActionNoMatch = SKAction.playSoundFileNamed(soundNoMatchFile, waitForCompletion: false)
        soundActionWin = SKAction.playSoundFileNamed(soundWinFile, waitForCompletion: false)
    }
    
    //MARK: leaderboard
    
    func AuthenticateLocalPlayer() {
        // todo:
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showLeaderboard() {
        // todo
    }
    
    func submitScore() {
        // todo
    }
}























