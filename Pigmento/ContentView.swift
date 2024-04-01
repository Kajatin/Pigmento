//
//  ContentView.swift
//  Pigmento
//
//  Created by Roland Kajatin on 31/03/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var color = HexColor()

    @State private var red: Double = 7
    @State private var green: Double = 7
    @State private var blue: Double = 7

    @State private var guesses: [Guess] = []
    @State private var guessed = false

    var body: some View {
        ZStack {
            color.color
                .ignoresSafeArea(.all)

            VStack {
                HStack {
                    Button {
                        reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .bold()
                    }
                    .tint(.primary)
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))

                    Spacer()
                    
                    Text("Guess the Color")
                        .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                        .getContrastText(backgroundColor: color.color)
                    
                    Spacer()

                    Button {
                    } label: {
                        Image(systemName: "info")
                            .bold()
                    }
                    .tint(.primary)
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
                .scenePadding()

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(guesses, id: \.id) { guess in
                            HStack(alignment: .firstTextBaseline) {
                                Text("#\(guess.color.hex)")
                                    .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                                    .getContrastText(backgroundColor: guess.color.color)
                                Text("\(100 * guess.distance, specifier: "%.0f%% match")")
                                    .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                                    .getContrastText(backgroundColor: guess.color.color)
                                    .opacity(0.8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(guess.color.color)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .defaultScrollAnchor(.bottom)
                .scrollIndicators(.hidden)

                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        StepSlider(label: "red", color: color.color, value: $red)
                        StepSlider(label: "green", color: color.color, value: $green)
                        StepSlider(label: "blue", color: color.color, value: $blue)
                    }
                    
                    if guessed {
                        Button {
                            reset()
                        } label: {
                            let hex = HexColor(red: red, green: green, blue: blue)
                            Text("New Game")
                                .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                                .getContrastText(backgroundColor: color.color)
                        }
                        .tint(color.color)
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button {
                            let newGuess = Guess(color: HexColor(red: red, green: green, blue: blue), target: color)
                            guesses.append(newGuess)
                            guessed = newGuess.distance == 1.0
                        } label: {
                            let hex = HexColor(red: red, green: green, blue: blue)
                            Text("Guess #\(hex.hex)")
                                .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                                .getContrastText(backgroundColor: color.color)
                        }
                        .tint(color.color)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .scenePadding()
                .background(.regularMaterial)
            }
        }
    }
    
    func reset() {
        color = HexColor()
        guesses = []
        guessed = false
    }
}

extension Text {
    func getContrastText(backgroundColor: Color) -> some View {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        UIColor(backgroundColor).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  luminance < 0.6 ? self.foregroundColor(.white) : self.foregroundColor(.black)
    }
}

#Preview {
    ContentView()
}
