//
//  Game.swift
//  SushiGo
//
//  Created by David Zilli on 1/31/16.
//  Copyright © 2016 Bravebeard. All rights reserved.
//

import Foundation

typealias Hand = Array<CardType>

enum CardType : Int {
    case SimpleValueOne     // Nigiri 1
    case SimpleValueTwo     // Nigiri 2
    case SimpleValueThree   // Nigiri 3
    case Double             // Tempura
    case Triple             // Sashimi
    case CollectionOne      // Maki 1
    case CollectionTwo      // Maki 2
    case CollectionThree    // Maki 3
    case CollectionSet      // Dumpling
    case CollectionEndGame  // Pudding
    case Multiplier         // Wasabi
    case Trade              // Chopsticks
    
    func description() -> String {
        switch (self)
        {
        case SimpleValueOne:
            return "Salmon Nigiri 1"
        case SimpleValueTwo:
            return "Tuna Nigiri 2"
        case SimpleValueThree:
            return "Shrimp Nigiri 3"
        case Double:
            return "Tempura"
        case Triple:
            return "Sashimi"
        case CollectionOne:
            return "Maki 1"
        case CollectionTwo:
            return "Maki 2"
        case CollectionThree:
            return "Maki 3"
        case CollectionSet:
            return "Dumping 1 3 5 7"
        case CollectionEndGame:
            return "Pudding"
        case Multiplier:
            return "Wasabi"
        case Trade:
            return "Chopsticks"
        }
    }
}

class Player {
    var id          : Int
    var displayName : String
    var roundScore  : Int = 0
    var totalScore  : Int = 0
    var hand        : Hand
    var playedHand  : Hand
    
    init(name : String, id : Int)
    {
        displayName = name
        self.id = id
        hand = Hand()
        playedHand = Hand()
    }
    
    func playCardAtIndex(index : Int)
    {
        if index < hand.count {
            let card = hand.removeAtIndex(index)
            playedHand.append(card)
        }
    }
    
    func getPlayedHandScore() -> Int {
        
        // Perhaps return a view model containing information about the hand score
        // Some is straight forward like points awarded for cards that don't involve
        // other players. But we'd have to put forth the count of collection cards to
        // compare to other players, and then award points to the top two players, for example
        
        // OR
        
        // The game can iterate over each card type, filter each players hand for that type and award points
        
        let typeDict = playedHand.reduce(Dictionary<CardType, Int>()) { (var typeDict, card : CardType) -> Dictionary<CardType, Int> in
            if let typeCount = typeDict[card] {
                typeDict[card] = typeCount + 1
            } else {
                typeDict[card] = 1
            }
            return typeDict
        }
        
        print("HAND DICTIONARY:")
        print(typeDict)
        
        var tempScore = 0
        
        for (card, count) in typeDict {
            switch card {
            case .SimpleValueOne:
                tempScore += 1 * count
            case .SimpleValueTwo:
                tempScore += 2 * count
            case .SimpleValueThree:
                tempScore += 3 * count
            case .Double:
                let numberOfPairs = Int(count / 2)
                tempScore += numberOfPairs * 5
            case .Triple:
                let numberOfTriplets = Int(count / 3)
                tempScore += numberOfTriplets * 10
            case .CollectionOne:
                fallthrough
            case .CollectionTwo:
                fallthrough
            case .CollectionThree:
                break
            case .CollectionSet:
                switch count {
                case 0:
                    tempScore += 0
                case 1:
                    tempScore += 1
                case 2:
                    tempScore += 3
                case 3:
                    tempScore += 6
                case 4:
                    tempScore += 10
                case 5:
                    fallthrough
                default:
                    tempScore += 15
                }
            case .CollectionEndGame:
                fallthrough
            case .Multiplier:
                fallthrough
            case .Trade:
                break
            }
        }
        
        return tempScore
    }
}

class Deck {
    
    var deck : Array<CardType>
    
    init()
    {
        deck = Array()
        for _ in 1...30 {
            let randomTypeRawValue = Int(arc4random_uniform(UInt32(11)))
            if let card = CardType(rawValue: randomTypeRawValue) {
                deck.append(card)
            }
        }
    }
    
    func dealCard() -> CardType?
    {
        guard deck.count > 0 else { return nil }
        let randomIndex = Int(arc4random_uniform(UInt32(deck.count)))
        let card = deck[randomIndex]
        deck.removeAtIndex(randomIndex)
        return card
    }
    
    func dealHand() -> Hand
    {
        var hand = Hand()
        for _ in 1...7 {
            if let card = dealCard() {
                hand.append(card)
            }
        }
        return hand
    }
}

class Game {
    
    var deck            : Deck?
    var players         : Array<Player>
    
    init(numberOfPlayers : Int)
    {
        // Create a deck
        deck = Deck()
        
        // Create players and hands
        
        players = Array()
        for index in 1...numberOfPlayers {
            let player = Player(name: "Player \(index)", id: index)
            player.hand = deck!.dealHand()
            players.append(player)
        }
        
        for player in players {
            print("\(player.displayName) \(player.hand)")
        }
        
        print("\(deck!.deck.count) cards remaining in deck.")
        
        // While cards in hand > 0
        while players[0].hand.count > 0 {
            //>>
            // Each player plays a card from their hand
            for player in players {
                player.playCardAtIndex(0)
            }
            
            // Swap hands
            var tempHand : Hand
            var player1 = players[0]
            var player2 = players[1]
            tempHand = player1.hand
            player1.hand = player2.hand
            player2.hand = tempHand
            
            for player in players {
                print("\(player.displayName) \(player.hand)")
            }
            //<<
        }
        
        // Count up scores
        for player in players {
//            print("\(player.displayName) played hand: \(player.playedHand)")
            print("\(player.displayName) score: \(player.getPlayedHandScore())")
        }
    }
}