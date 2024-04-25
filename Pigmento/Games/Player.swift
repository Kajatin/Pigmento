//
//  Player.swift
//  Pigmento
//
//  Created by Roland Kajatin on 10/04/2024.
//

import Foundation

enum PlayerNumber {
    case one
    case two
}

struct Player: Identifiable, Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    var playerNumber: PlayerNumber
    var score = 0
    var red: Double = 7
    var green: Double = 7
    var blue: Double = 7
    var guesses: [Guess] = []
    
    init(playerNumber: PlayerNumber) {
        self.playerNumber = playerNumber
    }
    
    mutating func reset(hard: Bool = false) {
        red = 7
        green = 7
        blue = 7
        guesses = []
        
        if hard {
            score = 0
        }
    }
    
    mutating func guess(target: HexColor) -> Guess {
        let guess = Guess(color: HexColor(red: red, green: green, blue: blue), target: target)
        guesses.append(guess)
        return guess
    }
    
    mutating func scored() {
        score += 1
    }
}
