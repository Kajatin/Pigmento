//
//  StepSlider.swift
//  Pigmento
//
//  Created by Roland Kajatin on 01/04/2024.
//

import SwiftUI
import CoreHaptics

struct StepSlider: View {
    var label: String
    var color: Color
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                .opacity(0.8)
            CustomSlider(value: $value, in_: 0...15, color: color)
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var in_: ClosedRange<Double>
    var step: Double = 1
    var color: Color = .gray

    @State private var engine: CHHapticEngine?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.25))
                    .frame(width: geometry.size.width, height: 18)

                // Tick marks
                ForEach(1...Int(in_.upperBound) - Int(in_.lowerBound) - 1, id: \.self) { i in
                    let x = CGFloat(i) * (geometry.size.width / CGFloat(in_.upperBound))
                    Rectangle()
                        .fill(color.opacity(0.8))
                        .frame(width: 2, height: 10)
                        .offset(x: x - 1)
                }

                // Tinted track
                ZStack{
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.7))
                        .frame(width: abs(geometry.size.width * CGFloat(value/(in_.upperBound - in_.lowerBound))), height: 18)
                        .offset(x: 0)
                }

                // Thumb
                Capsule()
                    .frame(width: 30, height: 26, alignment: .center)
                    .offset(x: CGFloat(value) * (geometry.size.width / CGFloat(in_.upperBound)) - 15)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .gesture(
                        DragGesture(minimumDistance: geometry.size.width / CGFloat(in_.upperBound))
                            .onChanged({ value in
                                let newValue = Double(value.location.x / geometry.size.width) * in_.upperBound
                                let roundedValue = round(newValue / step) * step
                                if self.value != roundedValue {
                                    playHaptics()
                                }
                                self.value = min(max(roundedValue, in_.lowerBound), in_.upperBound)
                            })
                    )
            }
        }
        .frame(height: 26)
        .onAppear(perform: prepareHaptics)
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        if engine != nil {
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    func playHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        events.append(
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.2)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.8))
            ], relativeTime: 0)
        )

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

#Preview {
    StepSlider(label: "red", color: .red, value: .constant(7))
        .scenePadding()
}
