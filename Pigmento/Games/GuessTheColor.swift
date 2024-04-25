//
//  GuessTheColor.swift
//  Pigmento
//
//  Created by Roland Kajatin on 09/04/2024.
//

import SwiftUI
import StoreKit
import ConfettiSwiftUI

enum DropdownState {
    case open
    case closed
}

struct GuessTheColor: View {
    @State private var color = HexColor()
    
    @State private var red: Double = 7
    @State private var green: Double = 7
    @State private var blue: Double = 7
    
    @State private var guesses: [Guess] = []
    @State private var guessed = false
    
    // Triggers the confetti animation every time this value changes.
    @State private var counter: Int = 0
    @AppStorage("lastRequestedReview") var lastRequestedReview: Date?
    
    @State private var showInfo = false
    @State private var solutionBlurRadius: Double = 8.0
    
    @State private var incomingColor: HexColor?
    @State private var showColorOverwriteAlert = false
    
    @Binding var gameMode: GameMode
    @State private var showDropdown = false
    @State private var showSmallScreenAlert = false
    
    @Environment(\.displayScale) var displayScale
    @Environment(\.requestReview) var requestReview
    
    @EnvironmentObject var hapticsManager: HapticsManager
    
    var body: some View {
        ZStack {
            color.color
                .ignoresSafeArea(.all)
            
            VStack {
                HStack(alignment: .top) {
                    Button {
                        reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .bold()
                            .tint(.primary)
                            .frame(width: 40, height: 40)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Guess the Color")
                                .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                                .foregroundStyle(showDropdown ? .primary : color.color.getContrastColor())
                            
                            Image(systemName: "chevron.down")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                                .foregroundStyle(showDropdown ? .primary : color.color.getContrastColor())
                                .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                        }
                        .onTapGesture {
                            withAnimation(.snappy) {
                                showDropdown.toggle()
                            }
                        }
                        
                        if showDropdown {
                            HStack(alignment: .center) {
                                Text("Battle Mode")
                                    .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                                    .foregroundStyle(showDropdown ? .primary : color.color.getContrastColor())
                                
                                Text("new")
                                    .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                                    .padding(.horizontal, 6)
                                    .foregroundStyle(color.color.getContrastColor())
                                    .background(color.color, in: RoundedRectangle(cornerRadius: 8))
                            }
                            .onTapGesture {
                                if UIScreen.main.bounds.height < 700 {
                                    showSmallScreenAlert.toggle()
                                } else {
                                    gameMode = .battle
                                    withAnimation {
                                        showDropdown.toggle()
                                    }
                                }
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Material.regularMaterial.opacity(showDropdown ? 1 : 0), in: RoundedRectangle(cornerRadius: 14))
                    .clipped()
                    
                    Spacer()
                    
                    if !guesses.isEmpty && guessed {
                        let renderer = createRenderer(color: color, challenge: true)
                        if let image = renderer.uiImage {
                            let renderedImage = Image(uiImage: image)
                            ShareLink(
                                item: renderedImage,
                                message: Text("I've just guessed this color in \(guesses.count) tries. Can you do better? pigmento://pigmento.com/guess/\(color.hex.toBase64())"),
                                preview: SharePreview(Text("Challenge with #\(color.hex)"), image: renderedImage)) {
                                    Image(systemName: "square.and.arrow.up")
                                        .bold()
                                        .tint(.primary)
                                        .frame(width: 40, height: 40)
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                                }
                        }
                    } else {
                        Button {
                            showInfo.toggle()
                        } label: {
                            Image(systemName: "info")
                                .bold()
                                .tint(.primary)
                                .frame(width: 40, height: 40)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .scenePadding()
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(guesses, id: \.id) { guess in
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
                                hapticsManager.playHaptics()
                                counter += 1
                                
                                if counter >= 5 && (lastRequestedReview == nil || Date().timeIntervalSince(lastRequestedReview!) > 60 * 60 * 24 * 130) {
                                    requestReview()
                                    lastRequestedReview = Date()
                                }
                            }
                        }
                    } label: {
                        Text(guessed ? "New Game" : "Guess")
                            .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                            .foregroundStyle(color.color.getContrastColor())
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
                            Text("Having trouble figuring out the solution?")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                            
                            HStack {
                                Spacer()
                                VStack(alignment: .center, spacing: 12) {
                                    Text("#\(color.hex)")
                                        .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .blur(radius: solutionBlurRadius)
                                    
                                    Button {
                                        withAnimation {
                                            solutionBlurRadius = 0.0
                                        }
                                    } label: {
                                        Text("Reveal Solution")
                                            .bold()
                                            .foregroundStyle(Color("AccentColor").getContrastColor())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("About")
                                .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                                .opacity(0.6)
                            Text("RGB stands for Red, Green, and Blue. It is a color model that describes how colors can be represented as a combination of these three primary colors. It is an additive color model: the more you add of each color, the closer you get to white.")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                            Text("In this game, your task is to guess the color by adjusting the sliders for the three color components. The selected value for each color is represented in a base-16 number system such that the values range from 0 to F (hexadecimal).")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Support")
                                .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                                .opacity(0.6)
                            
                            Text("If you want to support me, just leave a ⭐️ on the GitHub repo or rate the app on the App Store.")
                                .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                                .padding(.bottom, 8)
                            
                            Button {
                                requestReview()
                            } label: {
                                Text("Rate on App Store")
                                    .bold()
                                    .foregroundStyle(Color("AccentColor").getContrastColor())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))
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
                        
                        Divider()
                        
                        if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String, let build_ = Bundle.main.infoDictionary!["CFBundleVersion"] as? String {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Version")
                                    .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                                    .opacity(0.6)
                                
                                Text("\(version) (\(build_))")
                                    .font(.custom("Kanit-Regular", size: 16, relativeTo: .body))
                            }
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
        .onOpenURL(perform: { url in
            if url.scheme != "pigmento" {
                return
            }
            
            // Currently only supports guess/HEX path.
            let components = url.pathComponents
            
            if components.count != 3 || components[1] != "guess" {
                return
            }
            
            // TODO: Validate the hex component
            let hexEncrypted = components[2]
            let hex = hexEncrypted.fromBase64()!
            
            if guesses.isEmpty {
                color = HexColor(hex: hex)
            } else {
                incomingColor = HexColor(hex: hex)
                showColorOverwriteAlert = true
            }
        })
        .alert("New Color", isPresented: $showColorOverwriteAlert) {
            Button("No") {
                showColorOverwriteAlert = false
            }
            
            Button("Yes") {
                reset()
                color = incomingColor!
                incomingColor = nil
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("You are about to lose your current progress. Do you want to continue?")
        }
        .alert("Unsupported", isPresented: $showSmallScreenAlert) {
            Button("OK") {
                withAnimation {
                    showDropdown.toggle()
                }
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("This mode is unavailable on small screen sizes.")
        }
    }
    
    func reset() {
        color = HexColor()
        guesses = []
        guessed = false
        solutionBlurRadius = 8.0
        red = 7
        green = 7
        blue = 7
    }
    
    private func createColorShare(for color: HexColor, challenge: Bool = false) -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                if challenge {
                    Text("challenge")
                        .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(color.color.getContrastColor())
                        .opacity(0.6)
                }
                
                Text("#\(color.hex)")
                    .font(.custom("Kanit-Regular", size: 24, relativeTo: .title))
                    .foregroundStyle(color.color.getContrastColor())
                    .if(challenge) { view in
                        view.blur(radius: 8.0)
                    }
                    .padding(.bottom)
            }
            .frame(width: 160, height: 200)
            
            if let image = UIImage(named: "AppIcon") {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(color.color)
        // TODO: Fix non-transparent white background on exported image
        // .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func createRenderer(color: HexColor, challenge: Bool = false) -> ImageRenderer<some View> {
        let cs = createColorShare(for: color, challenge: challenge)
        let renderer = ImageRenderer(content: cs)
        renderer.scale = displayScale
        
        return renderer
    }
}

#Preview {
    let hapticsManager = HapticsManager.shared
    
    return GuessTheColor(gameMode: .constant(.guess))
        .environmentObject(hapticsManager)
}
