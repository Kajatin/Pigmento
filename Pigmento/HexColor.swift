//
//  HexColor.swift
//  Pigmento
//
//  Created by Roland Kajatin on 01/04/2024.
//

import SwiftUI
import Foundation

struct HexColor {
    var hex: String
    var color: Color

    let options: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]

    init() {
        self.hex = "\(options.randomElement()!)\(options.randomElement()!)\(options.randomElement()!)"
        self.color = HexColor.hexToColor(hex: self.hex)
    }

    init(red: Double, green: Double, blue: Double) {
        self.hex = "\(options[Int(red)])\(options[Int(green)])\(options[Int(blue)])"
        self.color = HexColor.hexToColor(hex: self.hex)
    }

    func similarity(to target: HexColor) -> Double {
        let red = (Double(options.firstIndex(of: String(hex[hex.index(hex.startIndex, offsetBy: 0)]))!) + 1) / Double(options.count)
        let green = (Double(options.firstIndex(of: String(hex[hex.index(hex.startIndex, offsetBy: 1)]))!) + 1) / Double(options.count)
        let blue = (Double(options.firstIndex(of: String(hex[hex.index(hex.startIndex, offsetBy: 2)]))!) + 1) / Double(options.count)

        let targetRed = (Double(options.firstIndex(of: String(target.hex[target.hex.index(target.hex.startIndex, offsetBy: 0)]))!) + 1) / Double(options.count)
        let targetGreen = (Double(options.firstIndex(of: String(target.hex[target.hex.index(target.hex.startIndex, offsetBy: 1)]))!) + 1) / Double(options.count)
        let targetBlue = (Double(options.firstIndex(of: String(target.hex[target.hex.index(target.hex.startIndex, offsetBy: 2)]))!) + 1) / Double(options.count)

        let distance = sqrt(pow(targetRed - red, 2) + pow(targetGreen - green, 2) + pow(targetBlue - blue, 2))
        let normalizedDistance = distance / sqrt(3.0)

        return 1 - normalizedDistance
    }

    static func hexToColor(hex: String) -> Color {
        // Expand 3-character hex to 6 characters
        let hex = hex.count == 3 ? hex.map { "\($0)\($0)" }.joined() : hex

        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)

        let red = Double((int >> 16) & 0xFF) / 255.0
        let green = Double((int >> 8) & 0xFF) / 255.0
        let blue = Double(int & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}
