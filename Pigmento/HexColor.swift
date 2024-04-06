//
//  HexColor.swift
//  Pigmento
//
//  Created by Roland Kajatin on 01/04/2024.
//

import CoreTransferable
import Foundation
import SwiftUI

struct HexColor: Codable {
    var hex: String
    var color: Color

    static let options: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]

    init() {
        self.hex = "\(HexColor.options.randomElement()!)\(HexColor.options.randomElement()!)\(HexColor.options.randomElement()!)"
        self.color = HexColor.hexToColor(hex: self.hex)
    }
    
    init(hex: String) {
        self.hex = hex
        self.color = HexColor.hexToColor(hex: self.hex)
    }

    init(red: Double, green: Double, blue: Double) {
        self.hex = "\(HexColor.options[Int(red)])\(HexColor.options[Int(green)])\(HexColor.options[Int(blue)])"
        self.color = HexColor.hexToColor(hex: self.hex)
    }

    func similarity(to target: HexColor) -> Double {
        let red = (Double(HexColor.options.firstIndex(of: String(hex[hex.index(hex.startIndex, offsetBy: 0)]))!) + 1) / Double(HexColor.options.count)
        let green = (Double(HexColor.options.firstIndex(of: String(hex[hex.index(hex.startIndex, offsetBy: 1)]))!) + 1) / Double(HexColor.options.count)
        let blue = (Double(HexColor.options.firstIndex(of: String(hex[hex.index(hex.startIndex, offsetBy: 2)]))!) + 1) / Double(HexColor.options.count)

        let targetRed = (Double(HexColor.options.firstIndex(of: String(target.hex[target.hex.index(target.hex.startIndex, offsetBy: 0)]))!) + 1) / Double(HexColor.options.count)
        let targetGreen = (Double(HexColor.options.firstIndex(of: String(target.hex[target.hex.index(target.hex.startIndex, offsetBy: 1)]))!) + 1) / Double(HexColor.options.count)
        let targetBlue = (Double(HexColor.options.firstIndex(of: String(target.hex[target.hex.index(target.hex.startIndex, offsetBy: 2)]))!) + 1) / Double(HexColor.options.count)

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

extension HexColor: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

fileprivate extension Color {
#if os(macOS)
    typealias SystemColor = NSColor
#else
    typealias SystemColor = UIColor
#endif
    
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
#if os(macOS)
        SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
#else
        guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Pay attention that the color should be convertible into RGB format
            // Colors using hue, saturation and brightness won't work
            return nil
        }
#endif
        
        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: r, green: g, blue: b)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
}
