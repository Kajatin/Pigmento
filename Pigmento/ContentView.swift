//
//  ContentView.swift
//  Pigmento
//
//  Created by Roland Kajatin on 31/03/2024.
//

import SwiftUI
import ConfettiSwiftUI

struct ContentView: View {
    @State private var color = HexColor()

    @State private var red: Double = 7
    @State private var green: Double = 7
    @State private var blue: Double = 7

    @State private var guesses: [Guess] = []
    @State private var guessed = false

    // Triggers the confetti animation every time this value changes.
    @State private var counter: Int = 0
    
    @State private var showInfo = false
    @State private var solutionBlurRadius: Double = 8.0

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
                        showInfo.toggle()
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
                            .frame(minWidth: 300)
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
                    .frame(maxWidth: 500)

                    Button {
                        if guessed {
                            reset()
                        } else {
                            let newGuess = Guess(color: HexColor(red: red, green: green, blue: blue), target: color)
                            guesses.append(newGuess)
                            guessed = newGuess.distance == 1.0
                            if guessed {
                                counter += 1
                            }
                        }
                    } label: {
                        let hex = HexColor(red: red, green: green, blue: blue)
                        Text(guessed ? "New Game" : "Guess #\(hex.hex)")
                            .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                            .getContrastText(backgroundColor: color.color)
                    }
                    .tint(color.color)
                    .buttonStyle(.borderedProminent)
                    .confettiCannon(counter: $counter, num: 30, rainHeight: 300, openingAngle: Angle(degrees: 35), closingAngle: Angle(degrees: 145), radius: 200)
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
                .background(.regularMaterial)
            }
            .sheet(isPresented: $showInfo) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading) {
                            HStack(spacing: 12) {
                                if let image = UIImage(named: "AppIcon") {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Text("Pigmento")
                                    .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                                Spacer()
                            }
                            
                            Text("An open-source fun puzzle game for people who love colors.")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                                .opacity(0.8)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Stuck?")
                                .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                                .opacity(0.6)
                            Text("Having trouble figuring the solution out?")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                            
                            HStack {
                                Spacer()
                                VStack(alignment: .center, spacing: 12) {
                                    Text("#\(color.hex)")
                                        .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                                        .blur(radius: solutionBlurRadius)
                                    
                                    Button {
                                        withAnimation {
                                            solutionBlurRadius = 0.0
                                        }
                                    } label: {
                                        Text("Reveal Solution")
                                            .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                                            .getContrastText(backgroundColor: color.color)
                                    }
                                    .tint(color.color)
                                    .buttonStyle(.borderedProminent)
                                }
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Source Code")
                                .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                                .opacity(0.6)
                            HStack {
                                Image("Github")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .scaledToFit()
                                Text("https://github.com/Kajatin/Pigmento")
                                    .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Support")
                                .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                                .opacity(0.6)
                            Text("If you want to support me, just leave a ⭐️ on the GitHub repo.")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                        }
                        
                        Spacer()
                    }
                }
                .scenePadding()
                .presentationBackground(.thinMaterial)
                .presentationDetents([.medium])
                .scrollIndicators(.hidden)
            }
        }
    }

    func reset() {
        color = HexColor()
        guesses = []
        guessed = false
        solutionBlurRadius = 8.0
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
