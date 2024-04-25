//
//  StepSlider.swift
//  Pigmento
//
//  Created by Roland Kajatin on 01/04/2024.
//

import SwiftUI

struct StepSlider: View {
    var label: String
    var color: Color
    var withHaptics: Bool = true
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                .opacity(0.8)
            CustomSlider(value: $value, in_: 0...15, color: color, withHaptics: withHaptics)
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var in_: ClosedRange<Double>
    var step: Double = 1
    var color: Color = .gray
    var withHaptics: Bool

    @EnvironmentObject var hapticsManager: HapticsManager

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.25))
                    .frame(width: geometry.size.width, height: 18)

                // Tinted track
                ZStack{
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.7))
                        .frame(width: CGFloat(value + 1) * (geometry.size.width / (CGFloat(in_.upperBound) + 2)), height: 18)
                        .offset(x: 0)
                }
                
                // Tick marks
                ForEach(0...Int(in_.upperBound) - Int(in_.lowerBound), id: \.self) { i in
                    let x = CGFloat(i + 1) * (geometry.size.width / (CGFloat(in_.upperBound) + 2))
                    Text(HexColor.options[i])
                        .offset(x: x - 6)
                        .font(.custom("Kanit-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(color.getContrastColor())
                        .opacity(0.25)
                }
                
                // Thumb
                Text("\(HexColor.options[Int(value)])")
                    .frame(width: 30, height: 26, alignment: .center)
                    .background(color, in: Capsule())
                    .foregroundStyle(color.getContrastColor())
                    .offset(x: CGFloat(value + 1) * (geometry.size.width / (CGFloat(in_.upperBound) + 2)) - 15)
                    .shadow(radius: 8)
                    .gesture(
                        DragGesture(minimumDistance: geometry.size.width / CGFloat(in_.upperBound))
                            .onChanged({ value in
                                let newValue = ((Double(value.location.x) + 15) / (geometry.size.width / (CGFloat(in_.upperBound) + 2)) - 1)
                                let roundedValue = round(newValue / step) * step
                                let clippedValue = min(max(roundedValue, in_.lowerBound), in_.upperBound)
                                if self.value != clippedValue && withHaptics {
                                    hapticsManager.playHaptics(intensity: 0.4, sharpness: 0.8)
                                }
                                self.value = clippedValue
                            })
                    )
            }
        }
        .frame(height: 26)
    }
}

#Preview {
    let hapticsManager = HapticsManager.shared
    return StepSlider(label: "red", color: .blue, value: .constant(7))
        .scenePadding()
        .environmentObject(hapticsManager)
}
