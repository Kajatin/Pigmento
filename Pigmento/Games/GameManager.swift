//
//  GameManager.swift
//  Pigmento
//
//  Created by Roland Kajatin on 10/04/2024.
//

import Foundation

class GameManager: ObservableObject {
    @Published var color = HexColor()
    @Published var player1 = Player(playerNumber: .one)
    @Published var player2 = Player(playerNumber: .two)
    @Published var guessed: PlayerNumber?
    
    func guesses(playerNumber: PlayerNumber) -> [Guess] {
        switch playerNumber {
        case .one:
            return player1.guesses
        case .two:
            return player2.guesses
        }
    }
    
    func reset(hard: Bool = false) {
        color = HexColor()
        guessed = nil
        player1.reset(hard: hard)
        player2.reset(hard: hard)
    }
}
