//
//  Guess.swift
//  Pigmento
//
//  Created by Roland Kajatin on 01/04/2024.
//

import Foundation
import CoreTransferable

struct Guess: Identifiable, Codable {
    var id = UUID()
    let color: HexColor
    let distance: Double
    
    init(color: HexColor, target: HexColor) {
        self.color = color
        self.distance = color.similarity(to: target)
    }
}

extension Guess: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
