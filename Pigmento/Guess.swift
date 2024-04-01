//
//  Guess.swift
//  Pigmento
//
//  Created by Roland Kajatin on 01/04/2024.
//

import Foundation

struct Guess: Identifiable {
    let id = UUID()
    let color: HexColor
    let distance: Double
    
    init(color: HexColor, target: HexColor) {
        self.color = color
        self.distance = color.similarity(to: target)
    }
}
