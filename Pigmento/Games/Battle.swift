//
//  Battle.swift
//  Pigmento
//
//  Created by Roland Kajatin on 09/04/2024.
//

import SwiftUI
import ConfettiSwiftUI

struct Battle: View {
    @Binding var gameMode: GameMode
    @StateObject var gameManager = GameManager()
    @EnvironmentObject var hapticsManager: HapticsManager
    
    var body: some View {
        ZStack {
            gameManager.color.color
                .ignoresSafeArea(.all)
            
            VStack {
                BattleField(playerNumber: .one)
                    .rotationEffect(.degrees(180))
                Spacer(minLength: 0)
                Scores(gameMode: $gameMode)
                Spacer(minLength: 0)
                BattleField(playerNumber: .two)
            }
        }
        .statusBarHidden()
        .environmentObject(gameManager)
    }
}

struct BattleField: View {
    var playerNumber: PlayerNumber
    var flip = false
    
    @State private var counter = 0
    
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var hapticsManager: HapticsManager
    
    var body: some View {
        VStack(spacing: 20) {
            if let guess = gameManager.guesses(playerNumber: playerNumber).last {
                HStack(alignment: .firstTextBaseline) {
                    Text("#\(guess.color.hex)")
                        .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                        .foregroundStyle(guess.color.color.getContrastColor())
                    Text("\(100 * guess.distance, specifier: "%.0f%% match")")
                        .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                        .foregroundStyle(guess.color.color.getContrastColor())
                        .opacity(0.8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(minWidth: 300)
                .background(guess.color.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                HStack(alignment: .firstTextBaseline) {
                    Text("⠀")
                        .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                        .foregroundStyle(gameManager.color.color.getContrastColor())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(minWidth: 300)
                .background(gameManager.color.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 0) {
                    if playerNumber == .one {
                        StepSlider(label: "red", color: gameManager.color.color, withHaptics: false, value: $gameManager.player1.red)
                        StepSlider(label: "green", color: gameManager.color.color, withHaptics: false, value: $gameManager.player1.green)
                        StepSlider(label: "blue", color: gameManager.color.color, withHaptics: false, value: $gameManager.player1.blue)
                    } else {
                        StepSlider(label: "red", color: gameManager.color.color, withHaptics: false, value: $gameManager.player2.red)
                        StepSlider(label: "green", color: gameManager.color.color, withHaptics: false, value: $gameManager.player2.green)
                        StepSlider(label: "blue", color: gameManager.color.color, withHaptics: false, value: $gameManager.player2.blue)
                    }
                }
                .frame(maxWidth: 500)
                
                Button {
                    if gameManager.guessed != nil {
                        return
                    }
                    
                    if playerNumber == .one {
                        let guess = gameManager.player1.guess(target: gameManager.color)
                        if guess.distance == 1.0 {
                            counter += 1
                            gameManager.guessed = .one
                            gameManager.player1.scored()
                            hapticsManager.playHaptics()
                        } else {
                            hapticsManager.playHaptics(intensity: 0.4, sharpness: 0.8)
                        }
                    } else {
                        let guess = gameManager.player2.guess(target: gameManager.color)
                        if guess.distance == 1.0 {
                            counter += 1
                            gameManager.guessed = .two
                            gameManager.player2.scored()
                            hapticsManager.playHaptics()
                        } else {
                            hapticsManager.playHaptics(intensity: 0.4, sharpness: 0.8)
                        }
                    }
                } label: {
                    if playerNumber == .one {
                        Text(gameManager.guessed == nil ? "Guess" : gameManager.guessed == .one ? "Victory" : "Defeat")
                            .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                            .foregroundStyle(gameManager.color.color.getContrastColor())
                    } else {
                        Text(gameManager.guessed == nil ? "Guess" : gameManager.guessed == .two ? "Victory" : "Defeat")
                            .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                            .foregroundStyle(gameManager.color.color.getContrastColor())
                    }
                }
                .tint(gameManager.color.color)
                .buttonStyle(.borderedProminent)
                .confettiCannon(counter: $counter, num: 30, rainHeight: 300, openingAngle: Angle(degrees: 35), closingAngle: Angle(degrees: 145), radius: 200)
            }
            .frame(maxWidth: .infinity)
            .scenePadding()
            .background(.regularMaterial)
        }
    }
}

struct Scores: View {
    @Binding var gameMode: GameMode
    
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                Text("\(gameManager.player2.score)")
                Text("•")
                Text("\(gameManager.player1.score)")
            }
            .padding(.vertical, 4)
            .padding(.horizontal)
            .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            
            Spacer(minLength: 0)
            
            Button {
                gameMode = .guess
            } label: {
                Image(systemName: "xmark")
                    .bold()
                    .tint(.primary)
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            
            let guessed = gameManager.guessed != nil
            Button {
                gameManager.reset(hard: !guessed)
            } label: {
                Image(systemName: guessed ? "play" : "arrow.counterclockwise")
                    .bold()
                    .tint(.primary)
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
            
            Spacer(minLength: 0)
                
            HStack {
                Text("\(gameManager.player1.score)")
                Text("•")
                Text("\(gameManager.player2.score)")
            }
            .rotationEffect(.degrees(180))
            .padding(.vertical, 4)
            .padding(.horizontal)
            .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
        .frame(maxWidth: 500)
        .padding(.horizontal)
    }
}

#Preview {
    let hapticsManager = HapticsManager.shared
    
    return Battle(gameMode: .constant(.battle))
        .environmentObject(hapticsManager)
}
