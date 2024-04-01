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
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.custom("Kanit-Regular", size: 20, relativeTo: .title2))
                .opacity(0.8)
            Slider(value: $value, in: 0...15, step: 1)
                .tint(color)
//            BidirectionalSlider(value: $value)
        }
    }
}

struct BidirectionalSlider: View {
    @Binding var value: Double
    
    private let minValue: Double = -50
    private let maxValue: Double = 50
    private let thumbRadius: CGFloat = 12
    
    var body: some View {
        
        GeometryReader { geometry in
            //--Container ZStack
            ZStack(alignment: .leading){
                //--Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.orange.opacity(0.5))
                    .frame(width: geometry.size.width, height: 8)
                
                //--Center indicator
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.orange.opacity(0.5))
                    .frame(width: 2, height: 40,alignment: .center)
                    .offset(x: geometry.size.width / 2 - 1)
                
                //--Tinted track
                ZStack{
                    let valueChangeFraction = CGFloat(value/(maxValue - minValue))
                    let tintedTrackWidth = geometry.size.width * valueChangeFraction
                    
                    let tintedTrackOffset = min((geometry.size.width / 2) + tintedTrackWidth, geometry.size.width / 2)
                    
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: abs(tintedTrackWidth), height: 8)
                        .offset(x: tintedTrackOffset)
                }
                
                //--Thumb
                Circle()
                    .fill(Color.white)
                    .fill(Color.orange.opacity(0.5))
                    .stroke(Color.orange, lineWidth: 3)
                    .frame(width: thumbRadius * 2)
                
                    .offset(x: CGFloat((maxValue + value)/(maxValue - minValue)) * geometry.size.width - thumbRadius)
                
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ gesture in
                                updateValue(with: gesture, in: geometry)
                            })
                    )
                
            }
            
        }
        .frame(height: 100)
        .padding()
        
    }
    
    //--Update slider value when the thumb is dragging
    private func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let dragPortion = gesture.location.x / geometry.size.width
        let newValue = Double((maxValue - minValue) * dragPortion) - maxValue
        value = min(max(newValue,minValue),maxValue)
    }
}

#Preview {
    StepSlider(label: "red", color: .red, value: .constant(7))
        .scenePadding()
}
