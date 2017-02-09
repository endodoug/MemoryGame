//
//  GameScene.swift
//  MemoryGame
//
//  Created by doug harper on 3/18/15.
//  Copyright (c) 2015 Doug Harper. All rights reserved.
//

import SpriteKit
import GameKit
import AVFoundation

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class Level5: SKScene, GKGameCenterControllerDelegate {
  
  var buttonPlay : SKSpriteNode!
  var buttonLeaderboard : SKSpriteNode!
  var buttonRate : SKSpriteNode!
  var title : SKSpriteNode!
  var buttonTwitter : SKSpriteNode!
  var buttonEmail : SKSpriteNode!
  var background: SKSpriteNode!
  
  let cardsPerRow : Int = 4
  let cardsPerColumn : Int = 4
  let cardSizeX : CGFloat = 50
  let cardSizeY : CGFloat = 50
  
  let scorePanelAndAdvertisingHeight : CGFloat = 100
  
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
  private var tryCountBest : Int!
  
  var tryCountCurrentLabel : SKLabelNode!
  var tryCountBestLabel : SKLabelNode!
  
  var DEBUG_MODE_ON : Bool = false
  var DelayPriorToHidingCards : TimeInterval =  1.5
  
  var finishedFlag : SKSpriteNode!
  
  var buttonReset : SKSpriteNode!
  
  var soundActionButton : SKAction!
  var soundActionMatch : SKAction!
  var soundActionNoMatch : SKAction!
  var soundActionWin : SKAction!
  
  var gcEnabled = Bool()
  var gcDefaultLeaderboard = String()
  var LeaderboardID = "com.endodoug.MagicalLeaderboard"
  
  var gameCenterAchievements = [String: GKAchievement]()
  
  override func didMove(to view: SKView) {
    
    playBackgroundMusic(filename: "MysticalForest.mp3")
    
    setupScenery()
    
    createScoreboard()
    HideScoreboard()
    
    //    CreateFinishedFlag()
    //    HideFinishedFlag()
    
    //    createMenu()
    //    hideMenu()
    createCardsSequence()
    ResetCardStatus()
    createCardBoard()
    gameIsPlaying = true
    PlaceScoreboardAboveCards()
    ShowScoreboard()
    //    HideFinishedFlag()
    
    setUpAudio()
    AuthenticateLocalPlayer()
    
    if(DEBUG_MODE_ON == false) {
      DelayPriorToHidingCards = 0.75
    }
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: UITouch! = touches.first
    let positionInScene: CGPoint = touch.location(in: self.scene!)
    let touchedNode: SKNode = self.scene!.atPoint(positionInScene)
    
    self.processItemTouch(touchedNode)
  }
  
  override func update(_ currentTime: TimeInterval) {
    /* Called before each frame is rendered */
  }
  
  func setupScenery() {
    
    let background = SKSpriteNode(imageNamed: BackgroundImage)
    background.anchorPoint = CGPoint(x: 0, y: 1)
    background.position = CGPoint(x: 0, y: size.height)
    background.zPosition = 0
    background.size = CGSize(width: self.view!.bounds.size.width, height: self.view!.bounds.size.height)
    addChild(background)
    
    let fireflies = SKEmitterNode (fileNamed: "Fireflies.sks")
    fireflies!.position = CGPoint (x: 0, y: size.height)
    fireflies!.zPosition = 1
    self.addChild(fireflies!)
    
  }
  
  func createMenu() {
    
    let offsetY : CGFloat = 5.0
    let offsetX : CGFloat = 5.0
    
    buttonRate = SKSpriteNode(imageNamed: buttonRateImage)
    buttonRate.position = CGPoint(x: size.width / 2, y: size.height / 2 + buttonRate.size.height + offsetY)
    buttonRate.zPosition = 10
    buttonRate.name = "rate"
    addChild(buttonRate)
    let enlarge = SKAction.scale(to: 1.25, duration: 2.5)
    let shrinky = SKAction.scale(to: 1.0, duration: 2.5)
    let wait: SKAction = SKAction.wait(forDuration: 2)
    let sequence: SKAction = SKAction.sequence([wait,enlarge,shrinky])
    let repeatThreeTimes: SKAction = SKAction.repeat(sequence, count: 3)
    buttonRate.run(repeatThreeTimes)
    
    buttonPlay = SKSpriteNode(imageNamed: buttonPlayImage)
    buttonPlay.position = CGPoint(x: size.width / 2  - (buttonPlay.size.width / 2), y: size.height / 2 - offsetY)
    buttonPlay.zPosition = 10
    buttonPlay.name = "play"
    addChild(buttonPlay)
    
    buttonLeaderboard = SKSpriteNode(imageNamed: buttonLeaderBoardImage)
    buttonLeaderboard.position = CGPoint(x: size.width / 2 + offsetX + buttonLeaderboard.size.width / 2, y: size.height / 2 - offsetY)
    buttonLeaderboard.zPosition = 10
    buttonLeaderboard.name = "leaderboard"
    addChild(buttonLeaderboard)
    
    title = SKSpriteNode(imageNamed: titleImage)
    title.position = CGPoint(x: size.width / 2, y: buttonRate.position.y + buttonRate.size.height / 2 + title.size.height / 2 + offsetY)
    title.zPosition = 10
    title.name = "title"
    title.setScale(1.0)
    addChild(title)
  }
  
  func showMenu() {
    let duration : TimeInterval = 0.5
    buttonPlay.run(SKAction.fadeAlpha(to: 1, duration: duration))
    buttonLeaderboard.run(SKAction.fadeAlpha(to: 1, duration: duration))
    buttonRate.run(SKAction.fadeAlpha(to: 1, duration: duration))
    title.run(SKAction.fadeAlpha(to: 1, duration: duration))
    
  }
  
  func hideMenu() {
    let duration : TimeInterval = 0.3
    buttonPlay.run(SKAction.fadeAlpha(to: 0, duration: duration))
    buttonLeaderboard.run(SKAction.fadeAlpha(to: 0, duration: duration))
    buttonRate.run(SKAction.fadeAlpha(to: 0, duration: duration))
    title.run(SKAction.fadeAlpha(to: 0, duration: duration))
    
  }
  
  func processItemTouch(_ nod : SKNode) {
    
    if(gameIsPlaying == false) {
      if (nod.name == "play") {
        print("play button")
        //        hideMenu()
        //        createCardsSequence()
        //        ResetCardStatus()
        //        createCardBoard()
        //        gameIsPlaying = true
        //        PlaceScoreboardAboveCards()
        //        ShowScoreboard()
        //        HideFinishedFlag()
        run(soundActionButton)
      } else if (nod.name == "leaderboard") {
        print("leaderboard button")
        run(soundActionButton)
        showLeaderboard()
      } else if (nod.name == "rate") {
        print("rate button")
        run(soundActionButton)
      }
    } else {
      // game is playing
      if( nod.name == "reset" )
      {
        ResetGame()
        run(soundActionButton)
      }
      
      if nod.name != nil {
        print(nod.name!)
        
        let num = Int(nod.name!)
        if(num != nil) // it is a number
        {
          if (num > 0) {
            if(lockedInteraction == true) {
              return
            } else {
              print("card with number \(num) was touched.")
              for i in 0..<cardsBacks.count {
                
                let cardBack : SKSpriteNode = cardsBacks[i] as SKSpriteNode
                if(cardBack === nod) {
                  run(soundActionButton)
                  // the nod is identical to the cardBack at index i
                  let cardNode : SKSpriteNode = cards[i] as SKSpriteNode
                  if (selectedCardIndex1 == -1) {
                    selectedCardIndex1 = i
                    selectedCardValue1 = cardNode.name!
                    cardBack.run(SKAction.hide())
                    
                    // enlarge card!
                    
                    let enlarge = SKAction.scale(to: 4.0, duration: 0.3)
                    let shrinky = SKAction.scale(to: 1.0, duration: 0.0)
                    
                    let savedAnchorPoint = cardNode.anchorPoint
                    let newAnchorPoint = CGPoint(x: 0.5, y: 0.5)
                    
                    let savedPosition = cardNode.position
                    let newPosition = CGPoint(x: frame.midX, y: frame.midY)
                    
                    let slide = SKAction.group([SKAction.run({cardNode.anchorPoint = newAnchorPoint}), SKAction.run({cardNode.position = newPosition})])
                    
                    let returnSlide = SKAction.group([SKAction.run({cardNode.anchorPoint = savedAnchorPoint}), SKAction.run({cardNode.position = savedPosition}), shrinky])
                    
                    let enlargeShrinky = SKAction.sequence([slide, enlarge, SKAction.wait(forDuration: 2), returnSlide , SKAction.run({cardNode.zPosition = 9})])
                    
                    cardNode.zPosition = 20
                    cardNode.run(enlargeShrinky)
                    
                  } else if (selectedCardIndex2 == -1) {
                    if(i != selectedCardIndex1) {
                      lockedInteraction = true
                      selectedCardIndex2 = i
                      selectedCardValue2 = cardNode.name!
                      cardBack.run(SKAction.hide())
                      
                      //  compare the 2 cards for a match.
                      if(selectedCardValue1 == selectedCardValue2 || DEBUG_MODE_ON == true) {
                        print("we have a match")
                        Timer.scheduledTimer(timeInterval: DelayPriorToHidingCards, target: self, selector: .hideSelectedCards, userInfo: nil, repeats: false)
                        
                        setStatusCardFound(selectedCardIndex1)
                        setStatusCardFound(selectedCardIndex2)
                        run(soundActionMatch)
                        incrementCurrentPercentOfAchievement("FirstMatch", amount: 100)
                        if(CheckIfGameOver() == true) {
                          gameIsPlaying = false
                          //                          showMenu()
                          run(soundActionWin)
                          PlaceScoreboardInCenter()
                          SaveBestTryCount()
                          //                          ShowFinishedFlag()
                          buttonReset.isHidden = true
                          
                          delayWithSeconds(5) {
                            self.showGameOverScene()
                          }
                          
                        }
                        
                      } else {
                        print("no match")
                        Timer.scheduledTimer(timeInterval: DelayPriorToHidingCards, target: self, selector: .resetSelectedCards, userInfo: nil, repeats: false)
                        
                        run(soundActionNoMatch)
                        
                        IncreaseTryCount()
                      }
                    }
                  }
                }
              }
            }
          }
        }
        
      } else {
        print("nil")
      }
      // here
    }
  }
  
  func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      completion()
    }
  }
  
  func createCardBoard() {
    
    let totalEmptySpaceX : CGFloat = self.size.width - ( CGFloat(cardsPerRow + 1) ) * cardSizeX
    let offsetX : CGFloat = totalEmptySpaceX / ( CGFloat(cardsPerRow) + 2 )
    
    let totalEmptySpaceY : CGFloat = self.size.height - scorePanelAndAdvertisingHeight - ( CGFloat(cardsPerColumn + 1) ) * cardSizeY
    let offsetY : CGFloat = totalEmptySpaceY / ( CGFloat(cardsPerColumn) + 2 )
    
    var idx : Int = 0
    for i in 0...cardsPerRow {
      
      for j in 0...cardsPerColumn {
        
        let cardIndex : Int = cardsSequence[idx]
        idx += 1
        
        let cardName : String = String(format: "card-%i", cardIndex)
        let card : SKSpriteNode = SKSpriteNode(imageNamed: cardName)
        card.size = CGSize(width: cardSizeX, height: cardSizeY)
        card.anchorPoint = CGPoint(x: 0, y: 0)
        
        let posX : CGFloat = offsetX + CGFloat(i) * card.size.width + offsetX * CGFloat(i)
        let posY : CGFloat = offsetY + CGFloat(j) * card.size.height  + offsetY * CGFloat(j)
        
        card.position = CGPoint(x: posX, y: posY)
        card.zPosition = 9
        card.name = String(format: "%i", cardIndex)
        addChild(card)
        cards.append(card)
        
        let cardBack : SKSpriteNode = SKSpriteNode(imageNamed: "card-back")
        cardBack.size = CGSize(width: cardSizeX, height: cardSizeY)
        cardBack.anchorPoint = CGPoint(x: 0, y: 0)
        cardBack.zPosition = 10
        cardBack.position = CGPoint(x: posX, y: posY)
        cardBack.name = String(format: "%i", cardIndex)
        addChild(cardBack)
        cardsBacks.append(cardBack)
        
      }
      
    }
  }
  
  // Replaced with MutableCollection extension at bottom
  //  func shuffle<C: MutableCollection>(_ list: C) -> C where C.Index == Int {
  //
  //    var theList = list
  //
  //    let shufflecount = theList.count
  //
  //    for i in 0..<(shufflecount - 1) {
  //      let j = Int(arc4random_uniform(UInt32(shufflecount - i))) + i
  //      if i != j {
  //        swap(&theList[i], &theList[j])
  //      }
  //    }
  //    return theList
  //
  //  }
  
  func createCardsSequence() {
    
    // Added to clear cardSequence when starting a new game after completing original
    removeALLCards()
    
    let totalCards : Int = (cardsPerRow + 1) * (cardsPerColumn + 1) / 2
    for i in 1...(totalCards) {
      cardsSequence.append(i)
      cardsSequence.append(i)
    }
    
    let newSequence = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: cardsSequence)
    print("1st: \(newSequence.description)")
    // use extension  let newSequence = cardsSequence.shuffle()
    // original   let newSequence = shuffle(cardsSequence)
    cardsSequence.removeAll(keepingCapacity: false)
    cardsSequence += newSequence as! [Int]
    print("2nd: \(newSequence.description)")
  }
  
  func HideSelectedCards() {
    let card1 : SKSpriteNode = cards[selectedCardIndex1] as SKSpriteNode
    let card2 : SKSpriteNode = cards[selectedCardIndex2] as SKSpriteNode
    
    card1.run(SKAction.hide())
    card2.run(SKAction.hide())
    
    selectedCardIndex1 = -1
    selectedCardIndex2 = -1
    lockedInteraction = false
    
  }
  
  func setStatusCardFound(_ cardIndex : Int) {
    cardStatus[cardIndex] = true
  }
  
  func ResetCardStatus() {
    for _ in 0...(cardsSequence.count - 1) {
      cardStatus.append(false)
    }
  }
  
  func resetSelectedCards () {
    let card1 : SKSpriteNode = cardsBacks[selectedCardIndex1] as SKSpriteNode
    let card2 : SKSpriteNode = cardsBacks[selectedCardIndex2] as SKSpriteNode
    
    card1.run(SKAction.unhide())
    card2.run(SKAction.unhide())
    selectedCardIndex1 = -1
    selectedCardIndex2 = -1
    lockedInteraction = false
  }
  
  func createScoreboard() {
    scoreboard = SKSpriteNode(imageNamed: "scoreboard")
    scoreboard.position = CGPoint(x: size.width / 2, y: size.height - 50 - scoreboard.size.height / 2)
    scoreboard.zPosition = 1
    scoreboard.name = "scoreboard"
    addChild(scoreboard)
    
    tryCountCurrentLabel = SKLabelNode(fontNamed: fontName)
    tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
    tryCountCurrentLabel?.fontSize = 30
    tryCountCurrentLabel?.fontColor = SKColor.white
    tryCountCurrentLabel?.zPosition = 11
    tryCountCurrentLabel?.position = CGPoint(x: scoreboard.position.x, y: scoreboard.position.y + 10)
    addChild(tryCountCurrentLabel)
    print("tryCount: \(tryCountCurrent)")
    
    // todo: get the best score from storage (NSUserDefault) 
    // Added the if let to unwrap optional showing on scoreboard
    tryCountBest = UserDefaults.standard.integer(forKey: "level4_besttrycount") as Int
    if let tryCountBest = tryCountBest {
    tryCountBestLabel = SKLabelNode(fontNamed: fontName)
    tryCountBestLabel?.text = "Best: \(tryCountBest)"
    tryCountBestLabel?.fontSize = 30
    tryCountBestLabel?.fontColor = SKColor.white
    tryCountBestLabel?.zPosition = 11
    tryCountBestLabel?.position = CGPoint(x: tryCountCurrentLabel.position.x, y: tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
    addChild(tryCountBestLabel)
    print("tryCountBest: \(tryCountBest)")
    }
    
    buttonReset = SKSpriteNode(imageNamed: buttonRestartImage)
    buttonReset.position = CGPoint(x: scoreboard.position.x + scoreboard.size.width / 2 - buttonReset.size.width / 1.6, y: scoreboard.position.y - buttonReset.size.height / 4 + 50)
    buttonReset.name = "reset"
    buttonReset.zPosition = 11
    buttonReset.setScale(0.5)
    addChild(buttonReset)
    buttonReset.isHidden = true
    
  }
  
  func HideScoreboard() {
    scoreboard.isHidden = true
    tryCountBestLabel.isHidden = true
    tryCountCurrentLabel.isHidden = true
    buttonReset.isHidden = true
  }
  
  func ShowScoreboard() {
    scoreboard.isHidden = false
    tryCountBestLabel.isHidden = false
    tryCountCurrentLabel.isHidden = false
    buttonReset.isHidden = false
    
    if(tryCountBest == nil  || tryCountBest == 0) {
      tryCountBestLabel.isHidden = true
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
  
  func PlaceScoreboardInCenter() {
    scoreboard.position = CGPoint(x: size.width / 2, y: size.height/2)
//    scoreboard.zPosition = 11
    tryCountCurrentLabel?.position = CGPoint(x: scoreboard.position.x, y: scoreboard.position.y + 10)
    tryCountBestLabel?.position = CGPoint(x: tryCountCurrentLabel.position.x, y: tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
    tryCountBestLabel.isHidden = false
  }
  
  func PlaceScoreboardAboveCards() {
    scoreboard.position = CGPoint(x: size.width / 2, y: size.height - 0 - scoreboard.size.height / 2) // original size.height - 50 - scoreboard.size.height / 2
    tryCountCurrentLabel?.position = CGPoint(x: scoreboard.position.x, y: scoreboard.position.y + 10)
    tryCountBestLabel?.position = CGPoint(x: tryCountCurrentLabel.position.x, y: tryCountCurrentLabel.position.y - 10 - tryCountCurrentLabel.fontSize)
    
    // move reset button up with scoreboard
    
    
    //        buttonReset = SKSpriteNode(imageNamed: buttonRestartImage)
    //        buttonReset.position = CGPointMake(scoreboard.position.x + scoreboard.size.width / 2 - buttonReset.size.width / 1.6, scoreboard.position.y - buttonReset.size.height / 4)
    //        buttonReset.name = "reset"
    //        buttonReset.zPosition = 11
    //        buttonReset.setScale(0.5)
    //        addChild(buttonReset)
    //        buttonReset.hidden = true
  }
  
  func SaveBestTryCount() {
    if(tryCountBest == nil || tryCountBest == 0 || tryCountCurrent < tryCountBest) {
      if tryCountBest != nil {
        tryCountBest = tryCountCurrent
        UserDefaults.standard.set(tryCountBest, forKey: "level4_besttrycount")
        UserDefaults.standard.synchronize()
        tryCountBestLabel?.text = "Best: \(tryCountBest!)"
        submitScore()
      }
    }
  }
  
  func CreateFinishedFlag() {
    finishedFlag = SKSpriteNode(imageNamed: finishedFlagImage)
    finishedFlag.size = CGSize(width: cardSizeX, height: cardSizeY)
    finishedFlag.anchorPoint = CGPoint(x: 0, y: 0)
    finishedFlag.position = CGPoint(x: size.width / 2, y: scoreboard.position.y - scoreboard.size.height / 2 - finishedFlag.size.height / 2)
    finishedFlag.zPosition = 11
    finishedFlag.name = "finishedFlag"
    addChild(finishedFlag)
    finishedFlag.isHidden = true
  }
  
  func ShowFinishedFlag() {
    finishedFlag.position = CGPoint(x: size.width / 2, y: scoreboard.position.y - scoreboard.size.height / 2 - finishedFlag.size.height / 2)
    finishedFlag.isHidden = false
  }
  
  func HideFinishedFlag() {
    finishedFlag.isHidden = true
  }
  
  func IncreaseTryCount() {
    tryCountCurrent = tryCountCurrent + 1
    tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
  }
  
  func ResetGame() {
    run(soundActionButton)
    removeALLCards()
    PlaceScoreboardAboveCards()
    ShowScoreboard()
    createCardsSequence()
    createCardBoard()
    ResetCardStatus()
    tryCountCurrent = 0
    tryCountCurrentLabel?.text = "Attempts: \(tryCountCurrent)"
//    finishedFlag.isHidden = true
  }
  
  func removeALLCards() {
    for card in cards {
      card.removeFromParent()
    }
    for card in cardsBacks {
      card.removeFromParent()
    }
    cards.removeAll(keepingCapacity: false)
    cardsBacks.removeAll(keepingCapacity: false)
    cardStatus.removeAll(keepingCapacity: false)
    cardsSequence.removeAll(keepingCapacity: false)
    
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
  
  func AuthenticateLocalPlayer()
  {
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
    
    localPlayer.authenticateHandler = {(ViewController, error) -> Void in
      if((ViewController) != nil)
      {
        let vc = self.view?.window?.rootViewController
        vc?.present(ViewController!, animated: true, completion: nil)
      } else if (localPlayer.isAuthenticated) {
        print("player is already authenticated")
        self.gcEnabled = true
        
        // Get the default leaderboard ID
        localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer: String?, error: Error?) -> Void in
          if error != nil {
            print(error)
          } else {
            self.gcDefaultLeaderboard = leaderboardIdentifer!
          }
        })
       
      } else {
        self.gcEnabled = false
        print("Local player could not be authenticated, disabling game center")
        print(error)
      }
      
    }
    
  }
  
  func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    
    gameCenterViewController.dismiss(animated: true, completion: nil)
    
    gameCenterAchievements.removeAll()
    loadAchievementPercentages()
    
  }
  
  func showLeaderboard() {
    let gcVC : GKGameCenterViewController = GKGameCenterViewController()
    gcVC.gameCenterDelegate = self
    gcVC.viewState = GKGameCenterViewControllerState.leaderboards
    gcVC.leaderboardIdentifier = LeaderboardID
    
    let vc = self.view?.window?.rootViewController
    vc?.present(gcVC, animated: true, completion: nil)
  }
  
  func submitScore() {
    let sScore = GKScore(leaderboardIdentifier: LeaderboardID)
    sScore.value = Int64(tryCountBest)
    
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
    
    GKScore.report([sScore], withCompletionHandler: { (error: Error?) -> Void in
      if error != nil {
        print(error!.localizedDescription)
      }
      else
      {
        print("score submitted successfully")
      }
    })
    
  }
  
  // MARK: Show GameOverScene
  
  func showGameOverScene() {
    
    let gameOverScene = MainMenu(size: size)
    gameOverScene.scaleMode = scaleMode
    let reveal = SKTransition.crossFade(withDuration: 3.0)
    view?.presentScene(gameOverScene, transition: reveal)
  }
  
  // MARK: Game Center Achievement Functions
  
  func loadAchievementPercentages() {
    
    print("getting percentage of past achievements")
    
    GKAchievement.loadAchievements(  completionHandler: {  (allAchievements, error) -> Void in
      
      if error != nil {
        
        print ("Game center could not load achievements, the error is \(error)")
      } else {
        
        // this could be nil if there was no progress on any achievements thus far
        if (allAchievements != nil) {
          
          for theAchievement in allAchievements! {
            
            if let singleAchievement:GKAchievement = theAchievement {
              
              self.gameCenterAchievements[singleAchievement.identifier!] = singleAchievement
              
            }
            
          }
          
          for (id, achievement) in self.gameCenterAchievements{
            
            print (" \(id)  -  \(achievement.percentComplete)")
            
          }
          
        }
      }
      
    })
    
  }
  
  func incrementCurrentPercentOfAchievement(_ identifier:String, amount:Double) {
    
    if GKLocalPlayer.localPlayer().isAuthenticated {
      
      var currentPercentFound:Bool = false
      
      if (gameCenterAchievements.count != 0) {
        
        for (id, achievement) in gameCenterAchievements {
          
          if (id == identifier) {
            
            currentPercentFound = true
            
            var currentPercent:Double = achievement.percentComplete
            
            currentPercent = currentPercent + amount
            
            reportAchievement(identifier, percentComplete:currentPercent)
            
            break
          }
          
        }
        
      }
      
      if (currentPercentFound == false) {
        
        reportAchievement(identifier, percentComplete:amount)
        
      }
      
    }
    
  }
  
  func reportAchievement(_ identifier:String, percentComplete:Double) {
    
    let achievement = GKAchievement(identifier: identifier)
    
    achievement.percentComplete = percentComplete
    
    let achievementArray:[GKAchievement] = [achievement]
    
    GKAchievement.report(achievementArray, withCompletionHandler: {
      
      error -> Void in
      
      if ( error != nil) {
        
        print(error)
      } else {
        
        print("reported achievement with percent complete of \(percentComplete)")
        
        self.gameCenterAchievements.removeAll()
        self.loadAchievementPercentages()
      }
    })
  }
}

private extension Selector {
  
  static let hideSelectedCards = #selector(GameScene.HideSelectedCards)
  static let resetSelectedCards = (#selector(GameScene.resetSelectedCards))
 
}

private extension MutableCollection where Index == Int {
  mutating func shuffle() {
    if count < 2 {return}
    
    for i in startIndex ..< endIndex - 1 {
      let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
      if i != j {
        swap(&self[i], &self[j])
      }
    }
  }
}























