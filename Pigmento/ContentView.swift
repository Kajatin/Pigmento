//
//  ContentView.swift
//  Pigmento
//
//  Created by Roland Kajatin on 31/03/2024.
//

import SwiftUI

struct ContentView: View {
    @SceneStorage("gameMode") var gameMode: GameMode = .guess
    
    var body: some View {
        switch gameMode {
        case .guess:
            GuessTheColor(gameMode: $gameMode)
        case .battle:
            Battle(gameMode: $gameMode)
        }
    }
}

#Preview {
    let hapticsManager = HapticsManager.shared
    return ContentView()
        .environmentObject(hapticsManager)
}
